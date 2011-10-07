package {
	import com.adobe.webapis.flickr.*;
	import com.adobe.webapis.flickr.Photo;
	import com.adobe.webapis.flickr.events.FlickrResultEvent;
	
	import flash.display.Bitmap;
	import flash.display.Loader;
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.net.URLRequest;
	import flash.system.LoaderContext;
	import flash.system.Security;

    public class flickrGrabber extends EventDispatcher {
		private const FLICKR_URL        :String = "flickr.com";
		private const CROSSDOMAIN_URL   :String = "http://api.flickr.com/crossdomain.xml";
		private const NUM_PER_PAGE      :int = 100;
        //url_sq:Square, url_t:Thumbnail, url_s:Small, url_m:Medium 500, url_z:Medium 640, url_l:Large , url_o:Original
        private var extrasOption        :String= "description,owner_name,tags,views,url_sq,url_t,url_s,url_m,url_z,url_l,url_o";
        
        private var imageLoader         :Loader

        private var flickrService       :FlickrService;
		private var activeUser          :User;
        private var userData            :User;
        private var activePhoto         :Photo;
        private var photoList           :PagedPhotoList
        private var _photoInfo          :Photo

        private var doUserSearch        :Boolean;
        private var otherDataRecieved   :Boolean;
        
        private var constrainWidth      :Number;
		private var constainHeight      :Number;
		private var photoPosition       :Number = 0;
		
        private var flickrSource        :String;
		private var searchType          :String;

        /**
		 * flickrGrabber constructor.  All arguments except the last are required.
		 * 
		 *
		 * @param parentWidth The miminum width of images to be returned.
		 * 
		 * @param parentHeight The miminum height of images to be returned.
		 * 
		 * @param api The Flickr API Key.  
		 * 
		 * @param secret The shared secret key
		 * 
		 * @param flickrSearchTerm Search Flickr for this term
		 * 
		 * @param searchByUser Is the search for a user name.
		 */
		public function flickrGrabber(parentWidth:Number, parentHeight:Number, api:String, secret:String, flickrSearchTerm:String, searchByUser:Boolean = false) {
			constrainWidth = parentWidth;
			constainHeight = parentHeight;
			flickrSource = flickrSearchTerm
			doUserSearch = searchByUser;
			
			imageLoader = new Loader();
			imageLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, onImageReady);
			imageLoader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, onImageError);
			
			Security.allowDomain(FLICKR_URL);
			Security.loadPolicyFile(CROSSDOMAIN_URL);
			
			flickrService = new FlickrService(api);
				
			flickrService.addEventListener(FlickrResultEvent.AUTH_GET_FROB, hGetFrob);
			flickrService.addEventListener(FlickrResultEvent.PHOTOS_GET_SIZES, recievePhotoSize);
//            flickrService.addEventListener(FlickrResultEvent.PHOTOS_GET_SIZES, );
			flickrService.addEventListener(FlickrResultEvent.PEOPLE_GET_INFO, recieveUserInfo);
			flickrService.addEventListener(FlickrResultEvent.PEOPLE_FIND_BY_USERNAME, userSearchResults);
			flickrService.addEventListener(FlickrResultEvent.PEOPLE_GET_PUBLIC_PHOTOS, recievePhotoList);			
			flickrService.addEventListener(FlickrResultEvent.PHOTOS_SEARCH , recievePhotoList);
            flickrService.addEventListener(FlickrResultEvent.PHOTOS_GET_INFO , recievePhotoInfo);
            
			flickrService.secret = secret;
			
			flickrService.auth.getFrob();
		}
        
		private function hGetFrob(evt:FlickrResultEvent):void {
			if (evt.success) {
				if (doUserSearch){
					flickrService.people.findByUsername(flickrSource);
				}else {
                    //The possible values are: date-posted-asc, date-posted-desc, date-taken-asc, date-taken-desc, interestingness-desc, interestingness-asc, and relevance.
					flickrService.photos.search("", flickrSource, "any", flickrSource, null, null, null, null, -1, extrasOption, NUM_PER_PAGE, 1, "relevance");
				}
			} else {
				reportError("Error obtaining Frob from flickr");
			}
		}
        
		private function userSearchResults(evt:FlickrResultEvent):void {
			if (evt.success) {
				activeUser = evt.data.user;
				flickrService.people.getPublicPhotos(activeUser.nsid);
			} else {
				reportError("Count not find specified user name");
			}
		}
        
		private function recievePhotoList(evt:FlickrResultEvent):void {
			photoList = evt.data.photos as PagedPhotoList;
			if (photoList.total > 0){
//				dispatchEvent(new Event("flickrConnectionReady", false));
                dispatchEvent( evt );
                
//                for( var photo in photoList.photos){
//                    
//                }
                    
                
			} else {
				reportError("No results recieved for user/search");
			}
		}
		public function loadNextImage() {
            trace("photoPosition:", photoPosition)
            trace("total:", photoList.photos.length);
            if(photoPosition == photoList.photos.length-1) {
                trace( "No any other picture!" );
                return;
            }
            
			activePhoto = photoList.photos[photoPosition]; 
			otherDataRecieved = false;
			flickrService.people.getInfo(activePhoto.ownerId);
			flickrService.photos.getSizes(activePhoto.id);
            
            if (photoPosition+1 > photoList.photos.length-1) {
//				photoPosition = 0;
			} else {
				photoPosition ++
			}
		}
		private function recieveUserInfo(evt:FlickrResultEvent):void {
			userData = evt.data.user as User;
			checkReadyStatus();
		}
        
		private function recievePhotoSize(evt:FlickrResultEvent):void {
			if (evt.success){
				var sizeArr:Array = evt.data.photoSizes;
				var sizeObject:PhotoSize;
				//Pull the photo that is closest to the target size.
				for (var i:int = 0; i < sizeArr.length; i++) {
					sizeObject = sizeArr[i];	
					if (sizeObject.width > constrainWidth || sizeObject.height > constainHeight) {
						break;
					}
				}
				imageLoader.load(new URLRequest(sizeObject.source), new LoaderContext(true));
                
			} else {
				reportError("Photo sizes were not recieved");
			}
		}
        
        
        private function recievePhotoInfo(evt:FlickrResultEvent){
            if (evt.success){
                photoInfo = evt.data.photo;
                dispatchEvent( new Event("imageReady") );
            } else {
                reportError("Photo info were not recieved");
            }
        }
        
		private function checkReadyStatus( evt:Event=null ) {
			if (otherDataRecieved) {
//				dispatchEvent(new Event("imageReady"));
                flickrService.photos.getInfo(activePhoto.id);
			} else {
				otherDataRecieved = true;
			}
		}

        private function onImageReady(evt:Event):void {
			try {
				var imageAlias:Bitmap = imageLoader.content as Bitmap;
			} catch (e:Error) {
				reportError("Returned image was not a proper bitmap: " + imageLoader.loaderInfo.url);
			}
			checkReadyStatus();
		}
		private function onImageError(evt:IOErrorEvent):void {
			reportError("Error loading image: " + imageLoader.loaderInfo.url);
		}
        
        public function get imageInfo():Photo {
            return activePhoto;
        }
        
		public function get image():Bitmap {
			return imageLoader.content as Bitmap;
		}
		public function get imageTitle():String {
			return activePhoto.title;
		}
		public function get imageAuthor():String {
			return userData.fullname;
		}
		private function reportError(errorString:String):void {
			dispatchEvent(new ErrorEvent("flickrGrabberError", false, false, errorString));
		}

        public function get photoInfo():Photo
        {
            return _photoInfo;
        }

        public function set photoInfo(value:Photo):void
        {
            _photoInfo = value;
        }

	}
}