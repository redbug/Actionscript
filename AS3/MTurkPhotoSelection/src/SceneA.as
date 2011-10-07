/*******************************************
 * author	: Redbug
 * e-mail	: l314kimo@gmail.com
 * blog		: http://redbug0314.blogspot.com
 * purpose	:		
 *******************************************/

package 
{
    import br.com.stimuli.loading.BulkLoader;
    import br.com.stimuli.loading.loadingtypes.LoadingItem;
    
    import com.adobe.serialization.json.JSON;
    import com.adobe.serialization.json.JSONParseError;
    import com.genie.mturk.photo.PhotoModel;
    import com.genie.mturk.photo.PhotoPageManager;
    import com.genie.mturk.photo.PhotoSprite;
    
    import fl.controls.Button;
    
    import flash.display.*;
    import flash.errors.IOError;
    import flash.events.*;
    import flash.external.ExternalInterface;
    import flash.filters.DropShadowFilter;
    import flash.media.Sound;
    import flash.net.URLLoader;
    import flash.net.URLRequest;
    import flash.net.URLRequestMethod;
    import flash.net.URLVariables;
    import flash.text.StyleSheet;
    import flash.text.TextField;
    import flash.text.TextFieldAutoSize;
    import flash.text.TextFormat;
    import flash.ui.Keyboard;
    import flash.utils.Dictionary;
    import flash.utils.Timer;
    
    import idv.redbug.robotbody.CoreContext;
    import idv.redbug.robotbody.commands.AsyncCommand;
    import idv.redbug.robotbody.model.scene.BaseScene;
    import idv.redbug.robotbody.model.scene.IScene;
    import idv.redbug.robotbody.util.Toolkits;
    
    import org.osflash.signals.events.GenericEvent;
    
    
	public class SceneA extends BaseScene
	{
		private const MY_SWF		:Array = [];
		private const MY_TXT		:Array = [];
		private const MY_MUSIC		:Array = [];
		private const MY_XML		:Array = [];

        private const NUM_PHOTO_PER_PAGE :int   = 4;

        private const DEBUG                 :Boolean = false;
        
        private const REMOTE_URL            :String = "http://0.0.0.0:3389/"
        private const LOCAL_URL             :String = "http://localhost:8000/"

        private var server_url            :String;
        
        //Loader
        private var _urlLoader           :URLLoader;
        private var _imageLoader         :BulkLoader;
        
        // UI
        private var _photoDisplayPanel   :Sprite;
        private var _controlPanel        :Sprite;
        private var _next_btn            :Button;
        private var _previous_btn        :Button;
        private var _submit_btn          :Button;
        private var _currentPage_txt     :TextField;
        
        //property
        private var _restaurantId        :String;
        private var _hitId               :String;
        private var _assignmentId        :String;
        
        //photoe list
        private var _photoModelList      :Vector.<PhotoModel>;
        private var _thumbBitmapList     :Vector.<DisplayObject>;
        private var _photoSpriteList     :Vector.<Sprite>;
        private var _selectedList        :Vector.<Boolean>;
        
        //photo page manager
        private var _photoPageManager   :PhotoPageManager;
        
        private var _numPhotos          :int;
        
        private function progressHandler( itemName:String, percentLoaded:String ):void
        {

        }
        
        
		//---------------------------------------------------------------------
		//  Override following functions for using the core framework of Robotbody:
		//		init()
		//		run()
		//		destroy()
		//		switchTo()		
		//		accessSWF()
		//		accessTXT()
		//		accessMP3()
		//		accessXML()
		//---------------------------------------------------------------------
		
		override public function init():void
		{
            if( DEBUG ){
                server_url = LOCAL_URL;
            }else{
                server_url = REMOTE_URL;
            }
            
			_resManager.progressHandler = progressHandler;
            
            _urlLoader = new URLLoader();
            
            _imageLoader = new BulkLoader("imageLoader");
            
            _imageLoader.addEventListener(BulkLoader.COMPLETE, onAllItemsLoaded);
            _imageLoader.addEventListener(BulkLoader.ERROR, onBulkLoaderError);
            _imageLoader.addEventListener(BulkLoader.HTTP_STATUS, onHTTPStatusError);
            
//            _imageLoader.addEventListener(BulkLoader.PROGRESS, onAllItemsProgress);
            
            var stageWidth:int = _sceneManager.stage.stageWidth;
            
            _photoDisplayPanel = new Sprite();
            _photoDisplayPanel.x = 50;
            _photoDisplayPanel.y = 60;
            _photoDisplayPanel.visible = true;
            addToContextView( _photoDisplayPanel );

            
            var y:int = 450;            
            var width:int = 300;
            var height:int = 80;
            
            _controlPanel = new Sprite();
            _controlPanel.y = y;
            _controlPanel.x = ( stageWidth >> 1 ) - 150;
//            _controlPanel.buttonMode = true;
//            _controlPanel.useHandCursor	= true;
            
            _controlPanel.graphics.lineStyle( 2, 0x3399FF, 0.8 );
            _controlPanel.graphics.beginFill( 0xffffff, 0.3 )
            _controlPanel.graphics.drawRoundRect(0, 0, width, height, 30, 30);
            _controlPanel.graphics.endFill();
            
            var shadow:DropShadowFilter = new DropShadowFilter();  
  
            shadow.color = 0x000000;  
            shadow.blurY = 8;  
            shadow.blurX = 8;  
            shadow.angle = 100;  
            shadow.alpha = .8;  
            shadow.distance = 3;
            var filtersArray:Array = new Array(shadow);  
              
            _controlPanel.filters = filtersArray;  
            
            
            _controlPanel.addEventListener( MouseEvent.MOUSE_DOWN, onStratDragging, false, 0, true );				
            _controlPanel.addEventListener( MouseEvent.MOUSE_UP, onStopDragging, false, 0, true );
            _controlPanel.addEventListener( MouseEvent.CLICK, onPanelClick, false, 0, true );
            
            
            _currentPage_txt = new TextField();
            _currentPage_txt.autoSize = TextFieldAutoSize.CENTER;
            _currentPage_txt.x = ( _controlPanel.width - _currentPage_txt.width ) >> 1;
            _currentPage_txt.y = 15;
            _controlPanel.addChild( _currentPage_txt );
            
            _previous_btn = new Button();
            _previous_btn.x = _currentPage_txt.x - _previous_btn.width - 20;
            _previous_btn.y = _currentPage_txt.y;
            _previous_btn.useHandCursor = true;
            _previous_btn.buttonMode = true;
            _previous_btn.label = "previous";
            _previous_btn.enabled = true;
            _controlPanel.addChild( _previous_btn );
            
            
            _next_btn = new Button();
            _next_btn.x = _currentPage_txt.x + _currentPage_txt.width + 20;
            _next_btn.y = _currentPage_txt.y;
            _next_btn.useHandCursor = true;
            _next_btn.buttonMode = true;
            _next_btn.label = "next";
            _next_btn.enabled = true;
            _controlPanel.addChild( _next_btn );
            
            
            _submit_btn = new Button();
            _submit_btn.x = ( _controlPanel.width - _submit_btn.width ) >> 1;
            _submit_btn.y = _currentPage_txt.y + 30;
            _submit_btn.useHandCursor = true;
            _submit_btn.buttonMode = true;
            _submit_btn.label = "submit";
            _submit_btn.enabled = false;
            _controlPanel.addChild( _submit_btn );
            
            
			/***********************************************
			 * make a resource list for loading "SWF" files 
			 ***********************************************/
			super.makeSWFList(MY_SWF);

			/***********************************************
			 * make a resource list for loading "Text" files 
			 ***********************************************/
			super.makeTXTList(MY_TXT);
			
			/***********************************************
			 * make a resource list for loading "MP3" files 
			 ***********************************************/
			super.makeMP3List(MY_MUSIC);

			/***********************************************
			 * make a resource list for loading "XML" files 
			 ***********************************************/
			super.makeXMLList(MY_XML);
			
			super.init();
		}	
		
		override public function run():void
		{
			/***************************************
			 * access the resource from a Swf file
			 ***************************************/
			accessSWF();
			
			/***************************************
			 * access the resource from a text file
			 ***************************************/
			accessTXT();
			
			/***************************************
			 * access the resource from a mp3 file
			 ***************************************/
			accessMP3();
			
			/***************************************
			 * access the resource from a xml file
			 ***************************************/
			accessXML();
            
            getHitIdFromHTML();
		}

        private function onPanelClick( event:MouseEvent ):void
        {
            //trace("click");
        }
        
        private function getHitIdFromHTML():void
        {
            var queryObject:Object = Toolkits.getQueryStringFromHTML();
            _hitId = queryObject.hitId;
            _assignmentId = queryObject.assignmentId;
            
            if( _assignmentId == "ASSIGNMENT_ID_NOT_AVAILABLE" ){
                
                var stageWidth:int = _sceneManager.stage.stageWidth;
                var previewMask:Sprite = new Sprite();
                 
                previewMask.graphics.beginFill( 0x111111, 0.3 );
                previewMask.graphics.drawRoundRect(0, 0, 600, 50, 50, 50);     
                previewMask.graphics.endFill();
                previewMask.x = ( stageWidth - previewMask.width ) >> 1;
                previewMask.y = 0;
                
                
                var preview_txt:TextField = new TextField();
                preview_txt.autoSize = TextFieldAutoSize.LEFT;
                preview_txt.text = "Preview";
                var textFormat:TextFormat = new TextFormat( "Arial", 36, 0xdeddee, true );
                preview_txt.setTextFormat( textFormat );
                previewMask.addChild( preview_txt );
                preview_txt.x = ( previewMask.width - preview_txt.width ) >> 1;
                
                addToContextView( previewMask );
                
                
                _next_btn.enabled = false;
                _previous_btn.enabled = false;
                _submit_btn.enabled = false;
                
            }
            
            requestPhotoList( _hitId );            
        }
        
        private function requestPhotoList( hitId:String ):void
        {
            var urlRequest:URLRequest = new URLRequest( server_url + 'photo/get_list_all/' + hitId + '/');
            _urlLoader.addEventListener( Event.COMPLETE, onPhotoListComplete, false, 0, true );
            _urlLoader.addEventListener( IOErrorEvent.IO_ERROR, onPhotoListError, false, 0, true );				
            _urlLoader.addEventListener( HTTPStatusEvent.HTTP_STATUS, onHTTPStatusError, false, 0, true);
            
            _urlLoader.load(urlRequest);
        }
        
        private function onPhotoListComplete( evt:Event ):void
        {
            trace("======================== onPhotoListComplete ============================");
            _urlLoader.removeEventListener( Event.COMPLETE, onPhotoListComplete );

            try{
                
                var response:Object = JSON.decode(evt.target.data);
                var photoList:Object = response.photoList;
//trace("response: ", response );                    
                _restaurantId = response.target.id;
                
                var numPhoto:int = photoList.length;
                
//var numPhoto:int = 5;
                
                var thumbURLList:Vector.<String> = new Vector.<String>( numPhoto );
                _photoModelList = new Vector.<PhotoModel>( numPhoto );
                _thumbBitmapList = new Vector.<DisplayObject>( numPhoto );
                _photoSpriteList = new Vector.<Sprite>( numPhoto );
                _selectedList = new Vector.<Boolean>( numPhoto );
                _numPhotos = numPhoto;
                
                
                for( var i:int = 0; i < numPhoto; ++i )
                {
                    thumbURLList[i] = photoList[i].urlThumb;
                    _photoModelList[i] = new PhotoModel( photoList[i] );
                }

                loadTumbnail( thumbURLList );
            }
            catch( e:JSONParseError){
                trace( "JSON Decode Error: " + e.message);
            }
            
        }
        
        private function onPhotoListError( evt:Event ):void
        {
            trace( evt, evt.target.data );
        }
        
        private function onSubmit( event:MouseEvent ):void
        {
            _submit_btn.enabled = false;
            
            var str:String = new String();
            
            for each( var photo:PhotoModel in _photoModelList )
            {
                str += photo.contentType + ' ';
            }
            
//            trace( "result:", str);
            
            
            var result      :Object = new Object();
            var selectedList:Array = [];
            
            var photoObj:Object;
            for each( var p:PhotoModel in _photoModelList )
            {
                photoObj = new Object(); 
                photoObj.id = p.id;
                photoObj.contentType = p.contentType;
                
                selectedList.push( photoObj );
            }
            result.selectedList = selectedList;
            result.rId = _restaurantId;
            result.assignmentId = _assignmentId;
            
            var urlRequest:URLRequest = new URLRequest( server_url + 'restaurant/update_photo_by_turk/');
            urlRequest.data = JSON.encode( result );
            urlRequest.contentType = "application/json";
            urlRequest.method = URLRequestMethod.POST;
            
            _urlLoader.addEventListener(Event.COMPLETE, onSubmitComplete, false ,0, true );
            _urlLoader.load(urlRequest);
        }
        
        private function onSubmitComplete( event:Event ):void
        {
            trace( "result from server:", event.target.data );
            ExternalInterface.call( "callBackFromFlash" );
        }
        
        private function onSubmitToMturkComplete( event:Event ):void
        {
            trace("submit mturk successful!!");
        }
        
        private function updateCurrentPage():void
        {
            _currentPage_txt.text = _photoPageManager.currentPage + " / " + _photoPageManager.totalPage;
        }
        
        private function isDone( index:int ):void
        {
            if( !_selectedList[ index ] ){
                trace("selected");
                _selectedList[ index ] = true;
                _numPhotos--;
                
                if( _numPhotos == 0 ){
                    _submit_btn.enabled = true;
                }
            }
        }
        
        private function onAllItemsLoaded( evt:Event ):void
        {
            trace("done!");
            addToContextView( _controlPanel );
//            addToContextView( _currentPage_txt );
//            addToContextView( _previous_btn );
//            addToContextView( _next_btn );
//            addToContextView( _submit_btn );
                
            _photoPageManager = new PhotoPageManager( _photoDisplayPanel, _photoSpriteList, NUM_PHOTO_PER_PAGE );
            _photoPageManager.sgPageUpdate.add( updateCurrentPage );
            
            _photoPageManager.nextPage();
            
            _next_btn.addEventListener( MouseEvent.CLICK, _photoPageManager.nextPage, false, 0, true );
            _previous_btn.addEventListener( MouseEvent.CLICK, _photoPageManager.previousPage, false, 0, true );
            _submit_btn.addEventListener( MouseEvent.CLICK, onSubmit, false, 0, true );
        }

        private function onStratDragging( event:MouseEvent ):void
        {
            trace('startDraging');
            event.currentTarget.startDrag();
            event.stopImmediatePropagation();
        }
        
        private function onStopDragging( event:MouseEvent ):void
        {
            trace('stopDraging');
            event.currentTarget.stopDrag();
            event.stopImmediatePropagation();
        }
        
        private function onBulkLoaderError( evt:ErrorEvent ):void
        {
            var item:LoadingItem = evt.target as LoadingItem;
            trace (item.errorEvent is SecurityErrorEvent); 
            trace (item.errorEvent is IOError); 
            trace (evt); // outputs more information 
        }
        
        private function onHTTPStatusError( evt:HTTPStatusEvent ):void
        {
            trace( "status:", evt.status );
        }
        
        private function loadTumbnail( thumbURLList:Vector.<String> ):void
        {
            var numPhoto:int = thumbURLList.length;
            
            for(var i:int = 0; i < numPhoto; ++i){
trace( thumbURLList[i] ); 
                _imageLoader.add( thumbURLList[i], { id:i, type:BulkLoader.TYPE_IMAGE} );
                _imageLoader.get( String( i )  ).addEventListener( BulkLoader.COMPLETE, onOneImageLoaded, false, 0, true );
            }
            _imageLoader.start();
        }
        
        private function onOneImageLoaded( evt:Event ):void
        {
            var item:LoadingItem = evt.target as LoadingItem;
            item.removeEventListener( BulkLoader.COMPLETE, onOneImageLoaded );
            
            var index:int = int( item.id );
            
            var photoSprite:PhotoSprite = new PhotoSprite( item.content, _photoModelList[ index ], index)
            photoSprite.sgSelected.add( isDone );

trace( _photoModelList[ index ].id, "has loaded." )            
            
            _thumbBitmapList[ index ] = item.content;
            _photoSpriteList[ index ] = photoSprite; 
        }
        
        private function makeURL( url:String, value:String):String
        {
            if(url != ""){
                return "<u><a href='" + url + "' >" + value + "</a></u>";
            }
            else{
                return "This url doesn't exist!!"; 
            }
        }
        
		override public function destroy():void
		{
			//-----make sure performing folllowing tasks before calling the parent's destory().------------------------
			//Unregister all event listners (particularly Event.ENTER_FRAME, and mouse and keyboard listener).
			//Stop any currently running intervals (via clearInterval()).
			//Stop any Timer objects(via the Time's class instance method stop()).
			//Stop any sounds from playing.
			//Stop the main timeline if it's currently playing.
			//Stop any movie clips that are currently playing.
			//Close any connected nework object, such as an instances of Loader, URLLoader, Socket, XMLSocket, LocalConnection, NetConnection, and NetStream
			//Nullify all references to Camera or Microphone.
			//--------------------------------------------------------------------------------------------------------
			
			super.destroy();
		}

		override public function switchTo(targetScene:IScene):void
		{
			super.switchTo(targetScene);
		}
		
		override public function accessSWF():void
		{
		}	

		override public function accessTXT():void
		{
		}	
		
		override public function accessMP3():void
		{
		}
		
		override public function accessXML():void
		{
			
		}
		
		override public function onKeyDown(event:KeyboardEvent):void
		{
			
			switch(event.keyCode){				
				case Keyboard.F3: 
					_sceneManager.switchPerformancePanel();
					break;
			}
			
		}
		
		override public function onClick(event:MouseEvent):void
		{
			
		}
	}
}
