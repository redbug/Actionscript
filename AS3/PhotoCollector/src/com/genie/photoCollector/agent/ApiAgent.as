/*******************************************
 * author	: Redbug
 * e-mail	: l314kimo@gmail.com
 * blog		: http://redbug0314.blogspot.com
 * purpose	:		
 *******************************************/

package com.genie.photoCollector.agent
{
    import com.genie.photoCollector.model.PhotoModel;
    import com.genie.photoCollector.proxy.*;
    
    import flash.events.Event;
    
    import org.osflash.signals.Signal;
    
    public class ApiAgent implements IProxy
    {
        public static const ID_FLICKR     :int = 0;
        public static const ID_GOOGLE     :int = 1;
        
        protected var _photoList          :Vector.<PhotoModel>;
        
        protected var _sgConnectComplete  :Signal;
        protected var _sgSearchComplete   :Signal;
        protected var _sgError            :Signal;  //all api agent dispatch the error event to upper level
        protected var _sgLog              :Signal;  //all api agent dispatch the print out message to upper level
        
        protected var _isConnected        :Boolean;
        protected var _agentId            :int;
        
        public function ApiAgent()
        {
            _isConnected = false;
            
            _sgSearchComplete = new Signal( Vector.<PhotoModel>, int );
            _sgConnectComplete = new Signal( int );
            _sgError = new Signal( String );
            _sgLog = new Signal( String );
            
            reset();
        }
        
        public function reset():void
        {
            _photoList = new Vector.<PhotoModel>();
        }
        
        public function destroy():void
        {
            _sgSearchComplete.removeAll();
            _sgSearchComplete = null;
            
            _sgConnectComplete.removeAll();
            _sgConnectComplete = null;
            
            _sgError.removeAll();
            _sgError = null;
            
            _sgLog.removeAll();
            _sgLog = null;
            
            _photoList = null;
        }
        
        public function getAgentName():String
        {
            switch( _agentId ){
                case ApiAgent.ID_FLICKR:
                    return "Flickr";
                    break;
                case ApiAgent.ID_GOOGLE:
                    return "Google Image";
                    break;
                default:
                    return "Unknown agent";
            }
        }
        
        //connect to API
        public function connect():void
        {
            
        }
        
        public function onConnectReady( event:Event=null ):void
        {
        
        }
        
        public function onConnectError( event:Event=null ):void
        {
        
        }
        
        //Send searching query to API
        public function search( keyword:String, numResult:int ):void
        {
        
        }
        public function onSearchComplete( event:Event=null ):void
        {
        
        }
        
        public function onSearchError( event:Event=null ):void
        {
        
        }
        
        
        //--------------- Signal ----------------------//
        
        public function get sgSearchComplete():Signal
        {
            return _sgSearchComplete;
        }
        
        public function set sgSearchComplete(value:Signal):void
        {
            _sgSearchComplete = value;
        }
        
        public function get sgConnectComplete():Signal
        {
            return _sgConnectComplete;
        }
        
        public function set sgConnectComplete(value:Signal):void
        {
            _sgConnectComplete = value;
        }

        public function get sgError():Signal
        {
            return _sgError;
        }

        public function set sgError(value:Signal):void
        {
            _sgError = value;
        }

        public function get sgLog():Signal
        {
            return _sgLog;
        }

        public function set sgLog(value:Signal):void
        {
            _sgLog = value;
        }


    }
}