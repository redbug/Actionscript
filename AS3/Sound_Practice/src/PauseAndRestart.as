package {
    import flash.display.Sprite;
    import flash.media.Sound;
    import flash.media.SoundChannel;
    import flash.net.URLRequest;
    import flash.events.Event;
    import flash.display.Sprite;
    import flash.events.MouseEvent;
    
    public class PauseAndRestart extends Sprite {
        private var _sound:Sound;
        private var _channel:SoundChannel;
        private var _playPauseButton:Sprite;
        private var _playing:Boolean = false;
        private var _position:int;
        
        public function PauseAndRestart(  ) {
            // Create sound and start it
            _sound = new Sound(new URLRequest("war.mp3"));
            _channel = _sound.play(  );
            _playing = true;

            // A sprite to use as a Play/Pause button
            _playPauseButton = new Sprite();
            this.addChild(_playPauseButton);
            _playPauseButton.x = 10;
            _playPauseButton.y = 20;
            _playPauseButton.graphics.beginFill(0xcccccc);
            _playPauseButton.graphics.drawRect(0, 0, 20, 20);
            _playPauseButton.addEventListener(MouseEvent.MOUSE_UP, 
                                             onPlayPause);
        }
        
        public function onPlayPause(event:MouseEvent):void {
            // If playing, stop. Take note of position
            if(_playing) {
                   _position = _channel.position;
                   _channel.stop(  );
            }
            else {
                // If not playing, re-start it at
                // last known position
                _channel = _sound.play(_position);
            }
               _playing = !_playing;
        }
    }
}