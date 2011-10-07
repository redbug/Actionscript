package
{
    import com.adobe.webapis.events.ServiceEvent;
    import com.adobe.webapis.flickr.PagedPhotoList;
    import com.adobe.webapis.flickr.Photo;
    import com.adobe.webapis.flickr.PhotoTag;
    import com.adobe.webapis.flickr.PhotoUrl;
    import com.adobe.webapis.flickr.events.FlickrResultEvent;
    import com.adobe.webapis.flickr.methodgroups.Photos;
    
    import flash.display.DisplayObjectContainer;
    import flash.display.MovieClip;
    import flash.display.Sprite;
    import flash.events.*;
    import flash.text.StyleSheet;
    import flash.text.TextField;
    import flash.text.TextFieldAutoSize;
    import flash.text.TextFieldType;
    import flash.text.TextFormat;
    import flash.ui.Keyboard;
    
    [SWF(width="1000", height="600", frameRate="30", backgroundColor="#FFFFCC")]
    public class FlickrPhotoFetcher extends Sprite
    {
        private var fetcher                 :flickrGrabber;
        private var searchBar_txt           :TextField;
        private var label_txt               :TextField;
        private var infoText_txt            :TextField;
        private var loading_txt             :TextField;
        private var photoDisplayPanel       :Sprite;
        
        private var isLoading               :Boolean;
        
        public function FlickrPhotoFetcher()
        {
            var css:StyleSheet = new StyleSheet();
            var linkStyle:Object = { 
                color:"#0000FF"
            };
            css.setStyle("a", linkStyle); 
            
            isLoading = false;
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
            
            searchBar_txt = new TextField();
            searchBar_txt.type = TextFieldType.INPUT;
            searchBar_txt.x = 150;
            searchBar_txt.y = 10;
            searchBar_txt.defaultTextFormat = new TextFormat("Arial", "20");
            searchBar_txt.width = 200;
            searchBar_txt.height = 30;
            searchBar_txt.border = true;
            this.addChild( searchBar_txt );
            
            searchBar_txt.addEventListener(KeyboardEvent.KEY_DOWN, onSearchKeyDown, false, 0, true);
        
            infoText_txt = new TextField();
            infoText_txt.x = 600;
            infoText_txt.y = 60;
            infoText_txt.defaultTextFormat = new TextFormat("Arial", "12", 0x000000, false);
            infoText_txt.width  = 350;
            infoText_txt.height = 400;
            infoText_txt.border = true;
            infoText_txt.styleSheet = css;
            infoText_txt.useRichTextClipboard = true;
            this.addChild( infoText_txt );
            
            photoDisplayPanel = new Sprite();
            photoDisplayPanel.x = 10;
            photoDisplayPanel.y = 60;
            photoDisplayPanel.visible = true;
            this.addChild( photoDisplayPanel );
            
            this.stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown, false, 0, true);
        }
        
        private function onKeyDown(evt:KeyboardEvent):void
        {
            if(evt.keyCode == Keyboard.ENTER)
            {
                if( !isLoading ){
                    isLoading = true;
                    loading_txt.visible = true;
                    fetcher.loadNextImage();
                }
            }
        }
        
        private function onSearchKeyDown(evt:KeyboardEvent):void
        {
            if(evt.keyCode == Keyboard.ENTER)
            {
                searchBar_txt.type="dynamic";
                searchBar_txt.background=true;
                searchBar_txt.backgroundColor=0xeeeeee;
                searchBar_txt.border=false;
                searchBar_txt.selectable=false;
                searchBar_txt.removeEventListener(KeyboardEvent.KEY_DOWN, onSearchKeyDown);
                
                isLoading = true;
                loading_txt.visible = true;
                
                fetcher = new flickrGrabber(400, 400, "951cdc97f89d9507d0eaab00c7f9c40d", "f9aadc2577c31930", encodeURI(searchBar_txt.text), false);
                
                fetcher.addEventListener("imageReady", onLoadedImage);
                fetcher.addEventListener("flickrGrabberError", onErrorImage);
                fetcher.addEventListener(FlickrResultEvent.PHOTOS_SEARCH, onFlickrReady, false, 0, true);
            }
            
            evt.stopImmediatePropagation();
        }
        
        private function onLoadedImage( evt:Event ):void
        {   
            if( photoDisplayPanel.numChildren != 0 ){
                photoDisplayPanel.removeChildAt(0);   
            }
            var info    :String = new String();
            var photo   :Photo = fetcher.photoInfo;

            info +=  "id: " +  photo.id;
            info +=  "\nownerId: " + photo.ownerId;
            info +=  "\nownerName: " + "<u><a href='" + "http://www.flickr.com/photos/" + photo.ownerId + "' >" + photo.ownerName + "</a></u>";
            info +=  "\nownerRealName: " + photo.ownerRealName;
            info +=  "\nownerLocation: " + photo.ownerLocation;
            info +=  "\ntitle: " + photo.title;
//            trace( "notes: ", photo.notes );      //notes ( floating rectangle message ) on photos
            info +=  "\nisPublic: " + photo.isPublic;
            info +=  "\nlicense: " + photo.license;
            info +=  "\ndateTaken: " + photo.dateTaken;
            info +=  "\ndateAdded: " + photo.dateAdded;
            info +=  "\noriginalFormat: " + photo.originalFormat;
            info +=  "\ndescription: " + photo.description;

            var tags:String = new String();
            var cnt:int = 1;
            for each( var tag:PhotoTag in photo.tags)
            {
                tags += "#" + tag.raw + "，"
                
                if( cnt % 3 == 0 ){
                    tags += "\n";
                }
                cnt++;
            }
            info +=  "\ntags:\n" + tags;
            
            var urls:String = new String();
            for each( var url:PhotoUrl in photo.urls)
            {
                urls += "<u><a href='" + url.url + "' >" + url.url + "</a></u>";   
            }
            info += "\nurls:\n" + urls;
            
            infoText_txt.htmlText = info;
            
            photoDisplayPanel.addChild( fetcher.image );
            
            isLoading = false;
            loading_txt.visible = false;
        }
        
        private function onErrorImage(evt:Event):void
        {
            trace( "Error Message: ", ErrorEvent(evt).text );   
        }
        
        private function onFlickrReady(evt:ServiceEvent):void
        {
            var photoList:PagedPhotoList = evt.data.photos as PagedPhotoList;
            var info:String = new String();
            info += "page: " + photoList.page;
            info += "\npages: " + photoList.pages; 
            info += "\nperPage: " + photoList.perPage;
            info += "\ntotal: " + photoList.total;
            
            
            var photo:Photo
            for each( var p:* in photoList.photos )
            {
                photo = Photo( p );
                
                info +=  "id: " +  photo.id;
                info +=  "\nownerId: " + photo.ownerId;
                info +=  "\nownerName: " + "<u><a href='" + "http://www.flickr.com/photos/" + photo.ownerId + "' >" + photo.ownerName + "</a></u>";
                info +=  "\nownerRealName: " + photo.ownerRealName;
                info +=  "\nownerLocation: " + photo.ownerLocation;
                info +=  "\ntitle: " + photo.title;
                //            trace( "notes: ", photo.notes );      //notes ( floating rectangle message ) on photos
                info +=  "\nisPublic: " + photo.isPublic;
                info +=  "\nlicense: " + photo.license;
                info +=  "\ndateTaken: " + photo.dateTaken;
                info +=  "\ndateAdded: " + photo.dateAdded;
                info +=  "\noriginalFormat: " + photo.originalFormat;
                info +=  "\ndescription: " + photo.description;
                
                if( photo.extras ){
                    info +=  "\nviews: " + photo.extras.views;
                    info +=  "\nurl_sq: " + photo.extras.url_sq;
                    info +=  "\nurl_t: " + photo.extras.url_t;
                    info +=  "\nurl_s: " + photo.extras.url_s;
                    info +=  "\nurl_m: " + photo.extras.url_m;
                    info +=  "\nurl_z: " + photo.extras.url_z;
                    info +=  "\nurl_l: " + photo.extras.url_l;
                    info +=  "\nurl_o: " + photo.extras.url_o;
                }
                
                var tags:String = new String();
                var cnt:int = 1;
                for each( var tag:String in photo.tags)
                {
                    tags += tag + " "
                    
                    if( cnt % 3 == 0 ){
                        tags += "\n";
                    }
                    cnt++;
                }
                info +=  "\ntags:\n" + tags;
                
//                var urls:String = new String();
//                for each( var url:PhotoUrl in photo.urls)
//                {
//                    urls += "<u><a href='" + url.url + "' >" + url.url + "</a></u>";   
//                }
//                info += "\nurls:\n" + urls;
                
                info +=  "\nreference: " + "<u><a href='" + "http://www.flickr.com/photos/" + photo.ownerId + "/"+ photo.id + "' >" + "reference" + "</a></u>";

                info += "\n====================================================";
                
            }
            
            infoText_txt.htmlText = info;

            fetcher.loadNextImage();
        }
    }
}