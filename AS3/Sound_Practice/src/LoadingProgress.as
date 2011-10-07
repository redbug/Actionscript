package {
    import flash.display.Sprite;
    import flash.events.Event;
    import flash.media.Sound;
    import flash.net.URLRequest;
    
    public class LoadingProgress extends Sprite {
        private var _sound			:Sound;
        private var _loadingBar1	:Sprite;
        private var _loadingBar2	:Sprite;
        
        public function LoadingProgress() {
        	_loadingBar1 = new Sprite();
        	_loadingBar2 = new Sprite();
        	
            addEventListener(Event.ENTER_FRAME, onEnterFrame);
            _sound = new Sound(new URLRequest("war.mp3"));
            _sound.play();
            
            this.addChild(_loadingBar1);
            this.addChild(_loadingBar2);
        }
        
        private function onEnterFrame(event:Event):void
        {
            var barWidth		:int = 200;
            var barHeight		:int = 5;
            var loaded			:int = _sound.bytesLoaded;
            var total			:int = _sound.bytesTotal;
            
            if(total > 0) {
                // Draw a background bar
                _loadingBar1.graphics.clear();
                _loadingBar1.graphics.beginFill(0xFFFFFF);
                _loadingBar1.graphics.drawRect(10, 10, barWidth, barHeight);
                _loadingBar1.graphics.endFill();

                // The percent of the sound that has loaded
                var percent:Number = loaded / total;

                // Draw a bar that represents the percent of 
                // the sound that has loaded
                _loadingBar2.graphics.beginFill(0xCCCCCC);
                _loadingBar2.graphics.drawRect(10, 10, barWidth * percent, barHeight);
                _loadingBar2.graphics.endFill();
            }
        }
    }    
}