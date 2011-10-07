/*******************************************
 * author	: Redbug
 * e-mail	: l314kimo@gmail.com
 * blog		: http://redbug0314.blogspot.com
 * purpose	:		
 *******************************************/

package com.genie.photoCollector.agent.google
{
    import be.boulevart.google.ajaxapi.search.GoogleSearchResult;
    import be.boulevart.google.ajaxapi.search.images.GoogleImageSearch;
    import be.boulevart.google.ajaxapi.search.images.data.GoogleImage;
    import be.boulevart.google.events.GoogleAPIErrorEvent;
    import be.boulevart.google.events.GoogleApiEvent;
    
    import com.genie.photoCollector.agent.ApiAgent;
    import com.genie.photoCollector.model.PhotoModel;
    import com.genie.photoCollector.proxy.IProxy;
    
    import flash.events.Event;
    
    import org.osflash.signals.Signal;
    import org.osflash.signals.natives.NativeSignal;

    public class GoogleAgent extends ApiAgent
    {
        private static var _instance    :GoogleAgent;
        
        private var _cnt_photo              :int;
        private var _numRequireResult       :int;      //max number is limited to 64 results
        private var _keyword                :String;
        
        private var _api                    :GoogleImageSearch;
        
        private var _sgAPIError             :NativeSignal;
        private var _sgImageSearchResult    :NativeSignal;
        
        public function GoogleAgent( enforcer:SingletonEnforcer )
        {
            
        }

        public static function get instance():GoogleAgent
        {
            if( _instance == null)
            {
                _instance = new GoogleAgent( new SingletonEnforcer() );
                _instance.initialize();
            }
            
            return  _instance;
        }
        
        private function initialize():void
        {
            _agentId = ApiAgent.ID_GOOGLE;
            
            _api = new GoogleImageSearch();
            
            _sgAPIError = new NativeSignal( _api, GoogleAPIErrorEvent.API_ERROR, GoogleAPIErrorEvent ); 
            _sgImageSearchResult = new NativeSignal( _api, GoogleApiEvent.IMAGE_SEARCH_RESULT, GoogleApiEvent );
            
            _sgAPIError.add( onSearchError );
            _sgImageSearchResult.add( onSearchComplete );   
        }
        
        override public function reset():void
        {
            super.reset();
            _cnt_photo = 0;
        }
        
        override public function destroy():void
        {
            super.destroy();
            
            _api = null;
            
            _sgAPIError.removeAll();
            _sgAPIError = null;
            
            _sgImageSearchResult.removeAll();
            _sgImageSearchResult = null;
            
            _instance = null;
        }
        
        override public function connect():void
        {
            onConnectReady();
        }
        
        override public function onConnectReady( event:Event=null ):void
        {
            _sgConnectComplete.dispatch( _agentId );
        }
        
        override public function onConnectError( event:Event=null ):void
        {
        
        }
        
        override public function search( keyword:String, numResult:int ):void
        {
            _keyword = keyword;
            _numRequireResult = numResult;
            search_helper( keyword, 0 );          
        }
        
        private function search_helper( keyword:String, start:int ):void
        {
            _api.search( keyword, start );
        }
        
        override public function onSearchComplete( event:Event=null ):void
        {
            var resultObject    :GoogleSearchResult = GoogleApiEvent(event).data as GoogleSearchResult;
            var photoModel      :PhotoModel;
            
            
            var estimatedNumResults:int = resultObject.estimatedNumResults;
            _numRequireResult = ( estimatedNumResults < _numRequireResult )? estimatedNumResults: _numRequireResult; 
            
            for each ( var image:GoogleImage in resultObject.results )
            {
                photoModel = new PhotoModel();
                
                photoModel.title = image.title;
//                photoModel.title = image.titleNoFormatting;
                photoModel.urlOwner = image.originalContextUrl;
                photoModel.urlSource = image.unescapedUrl;
                photoModel.urlThumb = image.thumbUrl;
                photoModel.width = int( image.width );
                photoModel.height = int( image.height );
                photoModel.description = image.contentNoFormatting;
                photoModel.tags = "";
                photoModel.from = "G";
                
//                trace( photoModel );
                _photoList.push( photoModel );
                _cnt_photo++;
                
                if( _cnt_photo == _numRequireResult){
                    break;
                }
            }
            
            if( _cnt_photo < _numRequireResult){
                search_helper( _keyword, _cnt_photo);
            }
            else{
                _sgSearchComplete.dispatch( _photoList, _agentId );
                reset();
            }
        }

        override public function onSearchError( event:Event=null ):void{
            var googleAPIErrEvt :GoogleAPIErrorEvent = event as GoogleAPIErrorEvent;
            
            _sgError.dispatch( "An API error has occured: " + googleAPIErrEvt.responseDetails, "responseStatus was: " + googleAPIErrEvt.responseStatus);
        }
        
    }
}

class SingletonEnforcer{}