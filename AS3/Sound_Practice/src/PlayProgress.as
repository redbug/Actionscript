package {
    import flash.display.Sprite;
    import flash.events.Event;
    import flash.media.Sound;
    import flash.media.SoundChannel;
    import flash.net.URLRequest;

    public class PlayProgress extends Sprite {
        private var _sound			:Sound;
        private var _channel		:SoundChannel;
        private var _loadingBar1	:Sprite;
        private var _loadingBar2	:Sprite;
        private var _loadingBar3	:Sprite;
        
        public function PlayProgress() {
        	_loadingBar1 = new Sprite();
        	_loadingBar2 = new Sprite();
        	_loadingBar3 = new Sprite();
        	
            addEventListener(Event.ENTER_FRAME, onEnterFrame);
            _sound = new Sound(new URLRequest("war.mp3"));
            _channel = _sound.play(  );
            
            this.addChild(_loadingBar1);
            this.addChild(_loadingBar2);
            this.addChild(_loadingBar3);
        }
        
        public function onEnterFrame(event:Event):void
        {
            var barWidth:int = 200;
            var barHeight:int = 5;
            
            var loaded	:int 	= 	_sound.bytesLoaded;
            var total	:int 	= 	_sound.bytesTotal;
            
            var length	:int 	= 	_sound.length;
            var position:int 	= 	_channel.position;
            
            // Draw a background bar
            _loadingBar1.graphics.clear(  );
            _loadingBar1.graphics.beginFill(0xFFFFFF);
            _loadingBar1.graphics.drawRect(10, 10, barWidth, barHeight);
            _loadingBar1.graphics.endFill(  );

            if(total > 0) {
                // The percent of the sound that has loaded
                var percentBuffered:Number = loaded / total;

                // Draw a bar that represents the percent of 
                // the sound that has loaded
                _loadingBar2.graphics.beginFill(0xCCCCCC);
                _loadingBar2.graphics.drawRect(10, 10, 
                                  barWidth * percentBuffered,
                                  barHeight);
                _loadingBar2.graphics.endFill(  );
                
                // Correct the sound length calculation
                length /= percentBuffered;
                
                  // The percent of the sound that has played
                  var percentPlayed:Number = position / length;

                // Draw a bar that represents the percent of 
                // the sound that has played
                _loadingBar3.graphics.beginFill(0x666666);
                _loadingBar3.graphics.drawRect(10, 10, 
                                  barWidth * percentPlayed,
                                  barHeight);
                _loadingBar3.graphics.endFill(  );
            }
        }
    }    
}