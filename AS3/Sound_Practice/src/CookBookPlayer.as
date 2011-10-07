package {
    import flash.display.Sprite;
    import flash.display.Stage;
    import flash.display.StageAlign;
    import flash.display.StageScaleMode;
    import flash.text.TextField;
    import flash.events.Event;
    import flash.events.MouseEvent;
    import flash.events.TimerEvent;
    import flash.media.Sound;
    import flash.media.SoundChannel;
    import flash.media.SoundTransform;
    import flash.net.URLRequest;
    import flash.text.TextFormat;
    import flash.utils.Timer;
        
    public class CookBookPlayer extends Sprite {
        private var _channel:SoundChannel;
        private var _displayText:TextField;
        private var _sound:Sound;
        private var _panControl:PanControl;
        private var _playing:Boolean = false;
        private var _playPauseButton:Sprite;
        private var _position:int = 0;
        private var _spectrumGraph:SpectrumGraph;
        private var _volumeControl:VolumeControl;
        
        public function CookBookPlayer() {
            // Stage alignment
//            this.stage.scaleMode = flash.display.StageScaleMode.NO_SCALE;
//            this.stage.align = flash.display.StageAlign.TOP_LEFT;
            
            // Enter frame listener
            var timer:Timer = new Timer(20);
            timer.addEventListener(TimerEvent.TIMER, onTimer);
            timer.start(  );
            _playing = true;
            
            // Display a text field
            _displayText = new TextField(  );
            addChild(_displayText);
            _displayText.x = 10;
            _displayText.y = 17;
            _displayText.width = 256;
            _displayText.height = 14;

            // Create a sound object
            _sound = new Sound(new URLRequest("war.mp3"));
            _sound.addEventListener(Event.ID3, onID3);
            _channel = _sound.play(  );
            
            // Create a bitmap for spectrum display
            _spectrumGraph = new SpectrumGraph(  );
            _spectrumGraph.x = 10;
            _spectrumGraph.y = 33;
            addChild(_spectrumGraph);
            
            // Create the Play and Pause buttons
            _playPauseButton = new PlayButton(  );
            _playPauseButton.x = 10;
            _playPauseButton.y = 68;
            addChild(_playPauseButton);
            _playPauseButton.addEventListener(MouseEvent.MOUSE_UP, 
                                             onPlayPause);
            
            // Create volume and pan controls
            _volumeControl = new VolumeControl(  );
            _volumeControl.x = 45;
            _volumeControl.y = 68;
            addChild(_volumeControl);
            _volumeControl.addEventListener(Event.CHANGE, 
                                           onTransform);

            _panControl = new PanControl(  );
            _panControl.x = 164;
            _panControl.y = 68;
            addChild(_panControl);
            _panControl.addEventListener(Event.CHANGE,
                                        onTransform);
        }
        
        public function onTransform(event:Event):void
        {
            // Get volume and pan data from controls
            // and apply to a new SoundTransform object
            _channel.soundTransform = new SoundTransform(
                                         _volumeControl.volume, 
                                         _panControl.pan);
        }
        
        public function onPlayPause(event:MouseEvent):void
        {
            // If playing, stop and record that position
            if(_playing) {
                _position = _channel.position;
                _channel.stop(  );
            }
            else {
                // Else, restart at the saved position
                _channel = _sound.play(_position);
            }
            _playing = !_playing;
        }
        
        public function onID3(event:Event):void {
            // Display selected id3 tags in the text field
            _displayText.text = _sound.id3.artist + " : " + 
                               _sound.id3.songName;
            _displayText.setTextFormat(
                        new TextFormat("_typewriter", 8, 0));
        }
        
        public function onTimer(event:TimerEvent):void {
            var barWidth:int = 256;
            var barHeight:int = 5;
            
            var loaded:int = _sound.bytesLoaded;
            var total:int = _sound.bytesTotal;
            
            var length:int = _sound.length;
            var position:int = _channel.position;
            
            // Draw a background bar
            graphics.clear(  );
            graphics.beginFill(0xFFFFFF);
            graphics.drawRect(10, 10, barWidth, barHeight);
            graphics.endFill(  );

            if(total > 0) {
                // The percent of the sound that has loaded
                var percentBuffered:Number = loaded / total;

                // Draw a bar that represents the percent of 
                // the sound that has loaded
                graphics.beginFill(0xCCCCCC);
                graphics.drawRect(10, 10, 
                                  barWidth * percentBuffered,
                                  barHeight);
                graphics.endFill(  );
                
                // Correct the sound length calculation
                length /= percentBuffered;
                
                // The percent of the sound that has played
                var percentPlayed:Number = position / length;
                // Draw a bar that represents the percent of 
                // the sound that has played
                graphics.beginFill(0x666666);
                graphics.drawRect(10, 10, 
                                  barWidth * percentPlayed,
                                  barHeight);
                graphics.endFill(  );
                
                _spectrumGraph.update(  );
            }
            
            
        }
    }    
}

// "helper classes"
// (This is an outside package, but it's available to classes 
// in the same file)
import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.filters.DropShadowFilter;
import flash.geom.Rectangle;
import flash.media.SoundMixer;
import flash.utils.ByteArray;

class PlayButton extends Sprite {
    public function PlayButton(  ) {
        // Draw the Play/Pause graphic
        graphics.beginFill(0xcccccc);
        graphics.drawRoundRect(0, 0, 20, 16, 4, 4);
        graphics.endFill(  );
        graphics.beginFill(0x333333);
        graphics.moveTo(4, 4);
        graphics.lineTo(8, 8);
        graphics.lineTo(4, 12);
        graphics.lineTo(4, 4);
        graphics.drawRect(10, 4, 2, 8);
        graphics.drawRect(14, 4, 2, 8);
        graphics.endFill(  );
        
    }
}
class SpectrumGraph extends Sprite {
    private var _spectrumBMP:BitmapData;
    
    public function SpectrumGraph(  )
    {
        // Bitmap to draw spectrum data in
        _spectrumBMP = new BitmapData(256, 30, 
                                     true, 0x00000000);
        var bitmap:Bitmap = new Bitmap(_spectrumBMP);
        bitmap.filters = [new DropShadowFilter(3, 45, 0, 1, 
                                               3, 2, .3, 3)];
        addChild(bitmap);
    }
    
    public function update(  ):void
    {
        // Get spectrum data
        var spectrum:ByteArray = new ByteArray(  );
        SoundMixer.computeSpectrum(spectrum);
        
        // Draw to bitmap
        _spectrumBMP.fillRect(_spectrumBMP.rect, 0xff666666);
        _spectrumBMP.fillRect(new Rectangle(1, 1, 254, 28),
                             0x00000000);
        for(var i:int=0;i<256;i++) {
            _spectrumBMP.setPixel32(i, 
                                   10 + spectrum.readFloat(  ) * 10,
                                   0xff000000);
        }
        for(var i:int=0;i<256;i++) {
            _spectrumBMP.setPixel32(i, 
                                   20 + spectrum.readFloat(  ) * 10,
                                   0xff000000);
        }
    }
}

class VolumeControl extends Sprite {
    public var volume:Number = 1.0;
    
    public function VolumeControl(  )
    {
        addEventListener(MouseEvent.CLICK, onClick);
        draw(  );
    }
    
    public function onClick(event:MouseEvent):void
    {
        // When user clicks the bar, set the volume
        volume = event.localX / 100;
        draw(  );
        dispatchEvent(new Event(Event.CHANGE));
    }
    
    private function draw(  ):void {
        // Draw a bar and the current volume position
        graphics.beginFill(0xcccccc);
        graphics.drawRect(0, 0, 102, 16);
        graphics.endFill(  );
        
        graphics.beginFill(0x000000);
        graphics.drawRect(volume * 100, 0, 2, 16);
    }
}

class PanControl extends Sprite {
    public var pan:Number = 0;
    
    public function PanControl(  )
    {
        addEventListener(MouseEvent.CLICK, onClick);
        draw(  );
    }
    
    public function onClick(event:MouseEvent):void
    {
        // When the user clicks bar, set pan
        pan = event.localX / 50 - 1;
        draw(  );
        dispatchEvent(new Event(Event.CHANGE));
    }

    private function draw(  ):void {
        // Draw the bar and current pan position
        graphics.beginFill(0xcccccc);
        graphics.drawRect(0, 0, 102, 16);
        graphics.endFill(  );
        
        graphics.beginFill(0x000000);
        graphics.drawRect(50 + pan * 50, 0, 2, 16);
    }
}
