package 
{
	import com.adobe.serialization.json.JSON;
	import com.adobe.serialization.json.JSONParseError;
	import com.adobe.webapis.flickr.PagedPhotoList;
	import com.adobe.webapis.flickr.Photo;
	import com.adobe.webapis.flickr.PhotoTag;
	import com.adobe.webapis.flickr.PhotoUrl;
	import com.genie.photoCollector.agent.ApiAgent;
	import com.genie.photoCollector.agent.flickr.*;
	import com.genie.photoCollector.agent.google.GoogleAgent;
	import com.genie.photoCollector.command.AgentCmd;
	import com.genie.photoCollector.model.PhotoModel;
	
	import fl.controls.Button;
	
	import flash.display.*;
	import flash.events.*;
	import flash.media.Sound;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.net.URLRequestMethod;
	import flash.net.URLVariables;
	import flash.text.StyleSheet;
	import flash.text.TextField;
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
		
        private const NUM_SEARCH_RESULT     :int = 10;  // for each api agent
        
        private const DEBUG                 :Boolean = false;
        
        private const REMOTE_URL            :String = "http://122.248.249.104:3389/"
        private const LOCAL_URL             :String = "http://localhost:8000/"
        
        
        private var _server_url         :String;
        
        private var _restaurantIndex    :int;
        private var _resultRawData      :Array;             // store the search result.            
        private var _restaurantList     :Vector.<Object>;   // restaurnt list from DB
        
        //-------------- API ------------------//
        private var _apiAgent           :ApiAgent;
        private var _flickrAgent        :FlickrAgent;
        private var _googleAgent        :GoogleAgent;
        
        private var _urlLoader          :URLLoader;

        //-------------- UI --------------------//
        private var _infoText_txt       :TextField;
        private var _start_btn          :Button;
        private var _stop_btn           :Button;
        
        
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
            _restaurantIndex = 0;
            
            if( DEBUG ){
                _server_url = LOCAL_URL;
            }else{
                _server_url = REMOTE_URL;
            }
            
			_resManager.progressHandler = progressHandler;
            _resultRawData = new Array();
            
            _urlLoader = new URLLoader();
            _restaurantList = new Vector.<Object>();
            
//            var css:StyleSheet = new StyleSheet();
//            var linkStyle:Object = { 
//                color:"#0000FF"
//            };
//            css.setStyle("a", linkStyle); 

            _infoText_txt = new TextField();
            _infoText_txt.x = 10;
            _infoText_txt.y = 10;
            _infoText_txt.defaultTextFormat = new TextFormat("Arial", "12", 0x000000, false);
            _infoText_txt.width  = 1000;
            _infoText_txt.height = 500;
            _infoText_txt.wordWrap = true;
            _infoText_txt.scrollV = 1;
            _infoText_txt.scrollH = 1;
            _infoText_txt.border = true;
//            _infoText_txt.styleSheet = css;
            _infoText_txt.useRichTextClipboard = true;
            addToContextView( _infoText_txt );
            
            
            _start_btn = new Button();
            _start_btn.x = _infoText_txt.width - _start_btn.width;
            _start_btn.y = _infoText_txt.y + _infoText_txt.height + 20;
            _start_btn.useHandCursor = true;
            _start_btn.buttonMode = true;
            _start_btn.label = "Start";
            _start_btn.enabled = true;
            addToContextView( _start_btn );
            _start_btn.addEventListener( MouseEvent.CLICK, onStart, false, 0, true );
            
            
            _stop_btn = new Button();
            _stop_btn.x = _start_btn.x - _start_btn.width - 10;
            _stop_btn.y = _start_btn.y;
            _stop_btn.useHandCursor = true;
            _stop_btn.buttonMode = true;
            _stop_btn.label = "Stop";
            _stop_btn.enabled = false;
            addToContextView( _stop_btn );
            _stop_btn.addEventListener( MouseEvent.CLICK, onStop, false, 0, true );
            
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

            _flickrAgent = FlickrAgent.instance;
            _googleAgent = GoogleAgent.instance;
            
            _flickrAgent.sgError.add( dumpMessage );
            _flickrAgent.sgError.add( onAPIAgentError );
            _flickrAgent.sgLog.add( dumpMessage );
            
            _googleAgent.sgError.add( dumpMessage );
            _googleAgent.sgError.add( onAPIAgentError );
            _googleAgent.sgLog.add( dumpMessage );
		}

        private function onStart( event:MouseEvent ):void
        {
            _start_btn.enabled = false;
            requestKeyword();
        }
        
        private function onStop( event:MouseEvent ):void
        {
            //stop _urlLoader doesn't change anything, you should implment a stop operation for agent API.
            _urlLoader.close();
            dumpMessage( "Force stopping." );
        }
        
        public function requestKeyword():void
        {
            var urlRequest:URLRequest = new URLRequest( _server_url + 'restaurant/get_list_photo_not_collected/');
            _urlLoader.addEventListener( Event.COMPLETE, onReqKeywordComplete, false, 0, true );
            _urlLoader.addEventListener( IOErrorEvent.IO_ERROR, onLoadingError, false, 0, true );				
            _urlLoader.addEventListener( HTTPStatusEvent.HTTP_STATUS, onStatus, false, 0, true);
            _urlLoader.load(urlRequest);
        }
        
        private function onReqKeywordComplete( evt:Event ):void
        {
            _urlLoader.removeEventListener( Event.COMPLETE, onReqKeywordComplete );
            dumpMessage( "================= Retrieved restaurant list.. ================" );
            
            try{
                var response:Object = JSON.decode(evt.target.data);
            }
            catch( e:JSONParseError){
                dumpMessage( "JSON Decode Error: " + e.message );
            }

            var length:int = 0;
            for each(var param:Object in response)
            {
                _restaurantList.push( param );
                length++;
            }
            dumpMessage( "#restaurant: " + length );
            
            searchNextKeyword();
        }

        public function search():void
        {
            _resultRawData = [];
            var cmd:AsyncCommand = new AsyncCommand(0,
                new AgentCmd( _restaurantList[_restaurantIndex].name, NUM_SEARCH_RESULT, _resultRawData, _googleAgent),
                new AgentCmd( _restaurantList[_restaurantIndex].name, NUM_SEARCH_RESULT, _resultRawData, _flickrAgent)
            );
            cmd.sgCommandComplete.add( sendResult );
            cmd.start();
        }
        
        public function sendResult():void
        {
            dumpMessage( "Post the result of keyword: " + _restaurantList[_restaurantIndex].name + "in JSON" );
            
            var urlRequest:URLRequest = new URLRequest(_server_url + 'photo/update/' + _restaurantList[_restaurantIndex].id+ '/');
            urlRequest.data = JSON.encode( _resultRawData );
            urlRequest.contentType = "application/json";
            urlRequest.method = URLRequestMethod.POST;
            
            _urlLoader.addEventListener(Event.COMPLETE, onSendResultComplete );						
            _urlLoader.load(urlRequest);
        }

        private function onAPIAgentError( errMessage:String ):void
        {
            var urlRequest:URLRequest = new URLRequest(_server_url + 'photo/error/' + _restaurantList[_restaurantIndex].id+ '/');
            urlRequest.method = URLRequestMethod.POST;
            
            _urlLoader.addEventListener(Event.COMPLETE, onSendResultComplete );						
            _urlLoader.load(urlRequest);
        }
        
        private function onSendResultComplete( evt:Event ):void
        {
            dumpMessage( "Response from server: " + evt.target.data );
            
            _restaurantIndex++;
            searchNextKeyword();
        }
        
        private function onLoadingError( evt:IOErrorEvent ):void
        {
            dumpMessage( "request error from: " + evt.text );
        }
        
        private function onStatus( evt:HTTPStatusEvent ):void
        {
//            dumpMessage( "http status: " + evt.status );
        }
        
        private function displayPhotoInfo( photo:PhotoModel ):void
        {
            var info:String = new String();      
            
            info += "title: " + photo.title + "\n";
            info += "urlOwner: " + makeURL( photo.urlOwner, photo.urlOwner ) + "\n";
            info += "urlSource: " + makeURL( photo.urlSource, photo.urlSource ) + "\n";
            info += "urlThumb: " + makeURL( photo.urlThumb, photo.urlThumb ) + "\n";
            info += "width: " + photo.width + "\n";
            info += "height: " + photo.height + "\n";
            info += "description: " + photo.description + "\n";
            info += "tags: " + photo.tags + "\n";
            info += "from: " + photo.from + "\n";
            
            _infoText_txt.htmlText += info + "\n";
            _infoText_txt.htmlText += "======================================";
        }

        public function dumpMessage( errStr:String):void
        {
            _infoText_txt.appendText( errStr + '\n');
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
        
        private function searchNextKeyword():void
        {
            if( _restaurantIndex < _restaurantList.length ){
                dumpMessage( "Searching #" + _restaurantIndex + " keyword: " + _restaurantList[_restaurantIndex].name );
                search();
            }else{
                dumpMessage( "Done!!!" );
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