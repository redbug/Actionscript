package {
    import flash.display.Sprite;
    import flash.events.Event;
    import flash.media.Sound;
    import flash.media.SoundChannel;
    import flash.net.URLRequest;
    
    public class SoundLevels extends Sprite {
        private var _sound:Sound;
        private var _channel:SoundChannel;
        private var leftBar:Sprite;
        private var rightBar:Sprite;
        
        public function SoundLevels(  ) {
        	leftBar = new Sprite();
        	rightBar = new Sprite();
        	
            addEventListener(Event.ENTER_FRAME, onEnterFrame);
            _sound = new Sound(new URLRequest("war.mp3"));
            _channel = _sound.play(  );
            
            addChild(leftBar);
            addChild(rightBar);
        }
        
        public function onEnterFrame(event:Event):void
        {
            var leftLevel	:Number = _channel.leftPeak * 100;
            var rightLevel	:Number = _channel.rightPeak * 100;
            
            leftBar.graphics.clear(  );
            leftBar.graphics.beginFill(0xcccccc);
            leftBar.graphics.drawRect(10, 10, leftLevel, 10);
            leftBar.graphics.endFill(  );
            
            rightBar.graphics.clear(  );
            rightBar.graphics.beginFill(0xcccccc);
            rightBar.graphics.drawRect(10, 25, rightLevel, 10);
            rightBar.graphics.endFill(  );
            
        }       
    }
}