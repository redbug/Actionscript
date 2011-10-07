package
{
    import be.boulevart.google.ajaxapi.search.GoogleSearchResult;
    import be.boulevart.google.ajaxapi.search.images.GoogleImageSearch;
    import be.boulevart.google.ajaxapi.search.images.data.GoogleImage;
    import be.boulevart.google.ajaxapi.search.images.data.types.GoogleImageSafeMode;
    import be.boulevart.google.ajaxapi.search.web.GoogleWebSearch;
    import be.boulevart.google.ajaxapi.search.web.data.GoogleWebItem;
    import be.boulevart.google.events.GoogleAPIErrorEvent;
    import be.boulevart.google.events.GoogleApiEvent;
    
    import br.com.stimuli.loading.BulkLoader;
    import br.com.stimuli.loading.BulkProgressEvent;
    import br.com.stimuli.loading.loadingtypes.LoadingItem;
    
    import com.igs.acd2.utils.MyKeyCode;
    import com.igs.acd2.utils.Toolkits;
    
    import flash.display.Bitmap;
    import flash.display.BitmapData;
    import flash.display.Loader;
    import flash.display.Sprite;
    import flash.events.Event;
    import flash.events.IOErrorEvent;
    import flash.events.KeyboardEvent;
    import flash.net.URLRequest;
    import flash.system.ApplicationDomain;
    import flash.system.LoaderContext;
    import flash.system.Security;
    import flash.text.StyleSheet;
    import flash.text.TextField;
    import flash.text.TextFieldAutoSize;
    import flash.text.TextFieldType;
    import flash.text.TextFormat;
    import flash.ui.Keyboard;
    
    [SWF(width="1000", height="600", frameRate="30", backgroundColor="#FFFFCC")]
    public class Main extends Sprite
    {   
        private const NUM_PHOTO         :int    = 100;     
        
        private var googleImageSearch   :GoogleImageSearch;
        
        private var photoList           :Vector.<GoogleImage>;
        private var imageLoader         :BulkLoader;
        private var photoDisplayPanel   :Sprite;
        
        private var label_txt           :TextField;
        private var searchBar_txt       :TextField;
        private var infoText_txt        :TextField;
        private var loading_txt         :TextField;

        private var cnt_photo           :int;
        
        private var resultInfo          :String;
        
        public function Main()
        {
            cnt_photo = 0;
            
            var css:StyleSheet = new StyleSheet();
            var linkStyle:Object = { 
                color:"#0000FF"
            };
            css.setStyle("a", linkStyle);
            
            imageLoader = new BulkLoader("imageLoader");
            
            imageLoader.addEventListener(BulkLoader.COMPLETE, onAllItemsLoaded);
            imageLoader.addEventListener(BulkLoader.PROGRESS, onAllItemsProgress);
            imageLoader.addEventListener(BulkLoader.SECURITY_ERROR, onSecurityError);
//            imageLoader.start();
            
//            imageLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, onImageReady);
//            imageLoader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, onImageError);

            searchBar_txt = new TextField();
            searchBar_txt.type = TextFieldType.INPUT;
            searchBar_txt.x = 150;
            searchBar_txt.y = 10;
            searchBar_txt.defaultTextFormat = new TextFormat("Arial", "20");
            searchBar_txt.width = 200;
            searchBar_txt.height = 30;
            searchBar_txt.border = true;
            this.addChild( searchBar_txt );

            
            searchBar_txt.addEventListener( KeyboardEvent.KEY_DOWN, onSearchKeyDown, false, 0, true);
            
            
            loading_txt = new TextField();
            loading_txt.x = 380;
            loading_txt.y = 10;
            loading_txt.defaultTextFormat = new TextFormat("Arial", 20, 0xFF0000);
            loading_txt.text = "loading...";
            loading_txt.visible = false;
            loading_txt.selectable = false;
            this.addChild( loading_txt );

            
            label_txt = new TextField();
            label_txt.x = 10;
            label_txt.y = 10;
            label_txt.selectable = false;
            label_txt.defaultTextFormat = new TextFormat("Arial", "20");
            label_txt.text = "Input keyword:";
            label_txt.autoSize = TextFieldAutoSize.LEFT;
            this.addChild( label_txt );


            googleImageSearch = new GoogleImageSearch();
            googleImageSearch.addEventListener(GoogleApiEvent.IMAGE_SEARCH_RESULT, onImgResults);
            googleImageSearch.addEventListener(GoogleAPIErrorEvent.API_ERROR,onAPIError);
            
            
            photoDisplayPanel = new Sprite();
            photoDisplayPanel.x = 10;
            photoDisplayPanel.y = 60;
            photoDisplayPanel.visible = true;
            this.addChild( photoDisplayPanel );

            
            infoText_txt = new TextField();
            infoText_txt.x = 800;
//            infoText_txt.y = 10;
            infoText_txt.defaultTextFormat = new TextFormat("Arial", "12", 0x000000, false);
            infoText_txt.autoSize = TextFieldAutoSize.LEFT;
//            infoText_txt.border = true;
            infoText_txt.styleSheet = css;
            infoText_txt.useRichTextClipboard = true;
            this.addChild( infoText_txt );
        }
        
        private function onSecurityError( evt:Event )
        {
            trace(evt);
        }
        
        private function onAllItemsLoaded( evt:Event )
        {
            trace("done!");
        }
        
        private function onAllItemsProgress( evt:BulkProgressEvent )
        {
        
        }
        
        private function reset()
        {
            cnt_photo = 0;
            photoList = new Vector.<GoogleImage>();
            imageLoader.removeAll();
        }
        
        private function onSearchKeyDown( e:KeyboardEvent )
        {
            switch( e.keyCode ){
                case Keyboard.ENTER:
                    reset();
                    Toolkits.removeAllChildren( photoDisplayPanel );
                    search( 0 );
                    break;
            }
        }
        
        private function search( start:int ):void
        {
            googleImageSearch.search( searchBar_txt.text, start, GoogleImageSafeMode.OFF );
        }
        
        private function onImgResults( e:GoogleApiEvent ):void
        {
            var resultObject:GoogleSearchResult = e.data as GoogleSearchResult;
            
            resultInfo = new String();
            
            resultInfo += "Estimated Number of Results:\n" + resultObject.estimatedNumResults;
//            resultInfo += "Current page index: " + resultObject.currentPageIndex + "\n";
//            resultInfo += "Number of pages: " + resultObject.numPages + "\n";

            infoText_txt.htmlText = resultInfo;

            for each ( var image:GoogleImage in resultObject.results ){
                photoList.push( image );
//                trace(image.thumbUrl);
                cnt_photo++;
            }
            
            //max number is limited to 64 results
            if( cnt_photo < 24 ){
                search( cnt_photo )
            }
            else{
                loadPhotoList();
            }
            
//            trace("#photo: ", cnt_photo);
            
//            infoText_txt.htmlText = resultStr;
            
        }
        
        private function loadPhotoList():void
        {
            var len:int = photoList.length;
            var key:String;
            
            for(var i:int = 0; i < len; ++i){
//                trace(photoList[i].thumbUrl);
                imageLoader.add( photoList[i].thumbUrl, { id:i, type:BulkLoader.TYPE_IMAGE});
                imageLoader.get( String( i )  ).addEventListener( BulkLoader.COMPLETE, onOneImageLoaded, false, 0, true );
            }
            imageLoader.start();
        }
        
        private function onOneImageLoaded( evt:Event ):void
        {
            var item:LoadingItem = evt.target as LoadingItem;
            item.removeEventListener( BulkLoader.COMPLETE, onOneImageLoaded );
   
            var photo:Photo = new Photo( item.content, photoList[ int( item.id ) ] );
            photo.x = 150 * ( int( item.id ) % 5 );
            photo.y = 120 * int( int( item.id ) / 5 );
            photoDisplayPanel.addChild( photo );
        }

        private function onAPIError(evt:GoogleAPIErrorEvent):void{
            trace("An API error has occured: " + evt.responseDetails, "responseStatus was: " + evt.responseStatus);
        }
    }

}
