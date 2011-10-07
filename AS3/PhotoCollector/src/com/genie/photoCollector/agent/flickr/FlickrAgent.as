/*******************************************
 * author	: Redbug
 * e-mail	: l314kimo@gmail.com
 * blog		: http://redbug0314.blogspot.com
 * purpose	:		
 *******************************************/

package com.genie.photoCollector.agent.flickr{
	import com.adobe.webapis.flickr.*;
	import com.adobe.webapis.flickr.Photo;
	import com.adobe.webapis.flickr.events.FlickrResultEvent;
	import com.genie.photoCollector.agent.ApiAgent;
	import com.genie.photoCollector.model.PhotoModel;
	import com.genie.photoCollector.proxy.*;
	
	import flash.display.Bitmap;
	import flash.display.Loader;
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.net.URLRequest;
	import flash.system.LoaderContext;
	import flash.system.Security;
	
	import org.osflash.signals.DeluxeSignal;
	import org.osflash.signals.Signal;
	import org.osflash.signals.natives.NativeSignal;
    
    public class FlickrAgent extends ApiAgent
    {
        private static var _instance    :FlickrAgent;
        
        private const API_KEY           :String = "951cdc97f89d9507d0eaab00c7f9c40d";
        private const API_SECRET        :String = "f9aadc2577c31930";
        
		private const FLICKR_URL        :String = "flickr.com";
		private const CROSSDOMAIN_URL   :String = "http://api.flickr.com/crossdomain.xml";
        private const EXTRAS_OPTION     :String= "description,owner_name,tags,views,url_sq,url_t,url_s,url_m,url_z,url_l,url_o";
        
        private var _api                :FlickrService;
        
        private var _sgAuthGetFrob      :NativeSignal;
        private var _sgPhotosSearch     :NativeSignal;
        
		public function FlickrAgent( enforcer:SingletonEnforcer )
        {
            
		}
        
        public static function get instance():FlickrAgent
        {
            if( _instance == null)
            {
                _instance = new FlickrAgent( new SingletonEnforcer() );
                _instance.initialize();
            }
            
            return  _instance;
        }
        
        private function initialize():void
        {
            _agentId = ApiAgent.ID_FLICKR;
            
            Security.allowDomain( FLICKR_URL );
            Security.loadPolicyFile( CROSSDOMAIN_URL );
            _api = new FlickrService( API_KEY );
            _api.secret = API_SECRET;
            
            _sgAuthGetFrob = new NativeSignal( _api, FlickrResultEvent.AUTH_GET_FROB, FlickrResultEvent );
            _sgPhotosSearch = new NativeSignal( _api, FlickrResultEvent.PHOTOS_SEARCH, FlickrResultEvent ); 
            
            _sgAuthGetFrob.addOnce( onConnectReady );
            _sgPhotosSearch.add( onSearchComplete );
        }
        
        override public function reset():void
        {
            super.reset();
        }

        override public function destroy():void
        {
            super.destroy();
            
            _api = null;
            
            _sgAuthGetFrob.removeAll();
            _sgAuthGetFrob = null;
            
            _sgPhotosSearch.removeAll();
            _sgPhotosSearch = null;
            
            _instance = null;
        }
        
        override public function connect():void
        {
            if( _isConnected ){
                _sgConnectComplete.dispatch( _agentId );
            }else{
                _api.auth.getFrob();
            }
        }

        override public function onConnectReady( event:Event=null ):void
        {
            var flickrResultEvt:FlickrResultEvent = event as FlickrResultEvent;
            
            if (flickrResultEvt.success) {
                _isConnected = true;
                _sgConnectComplete.dispatch( _agentId );        
            } else {
                onConnectError();
            }
        }
        
        override public function onConnectError( event:Event=null ):void 
        {
            _sgError.dispatch( "flickrGrabberError -- " + "Connect Failed: Error obtaining Frob from flickr!");
        }
        
        override public function search( keyword:String, numResult:int ):void
        {
            var keywordEncoded:String = encodeURI( keyword );
            _sgLog.dispatch( "keyword (URL encoded) : " + keywordEncoded ); 
            /*
             * The possible values of sorting parameter are:
             * date-posted-asc, date-posted-desc, date-taken-asc, date-taken-desc, interestingness-desc, interestingness-asc, and relevance. 
             */
            _api.photos.search("", keywordEncoded, "any", keywordEncoded, null, null, null, null, -1, EXTRAS_OPTION, numResult, 1, "relevance");
        }
        
		override public function onSearchComplete( event:Event=null ):void {
            var pagedPhotoList  :PagedPhotoList = FlickrResultEvent(event).data.photos as PagedPhotoList;
            var photoModel      :PhotoModel;
            var photoList       :Array = pagedPhotoList.photos;
            
            //resort the photo list by the views property
            photoList.sortOn("views", Array.NUMERIC|Array.DESCENDING)
            
            for each( var photo:Photo in photoList )
            {
                //show the view times of the photo
//              trace("views", photo.views);
                
                photoModel = new PhotoModel();

                photoModel.title = photo.title;
                photoModel.urlOwner = "http://www.flickr.com/photos/" + photo.ownerId + "/" + photo.id;
                photoModel.urlSource = photo.extras.url_z;
                //photoModel.urlThumb = photo.extras.url_t;
                photoModel.urlThumb = photo.extras.url_s;
                
                //TODO: width and height of photo should be get from getSize() operation.
                photoModel.width = 640;
                photoModel.height = 480;
                
                photoModel.description = photo.description;
                photoModel.tags = photo.tags.join();
                photoModel.from = "F";
                
//                trace( photoModel );
                _photoList.push( photoModel );
            }
            
            _sgSearchComplete.dispatch( _photoList, _agentId );
            reset();
		}
        
        //TODO: you should check if flickr lib supports any error event for searching failed. 
        override public function onSearchError( event:Event=null ):void
        {
            
        }
        
	}
}

class SingletonEnforcer{}