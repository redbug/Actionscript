package {
    import flash.display.Bitmap;
    import flash.display.BitmapData;
    import flash.display.Sprite;
    import flash.events.Event;
    import flash.media.Sound;
    import flash.media.SoundChannel;
    import flash.media.SoundMixer;
    import flash.net.URLRequest;
    import flash.utils.ByteArray;
    
        
    public class Spectrum extends Sprite {
        private var _sound			:Sound;
        private var _channel		:SoundChannel;
        private var _spectrumGraph	:BitmapData;
                
        public function Spectrum(  ) {
            // Create bitmap for spectrum display
            _spectrumGraph = new BitmapData(256, 60,
                                             true, 
                                             0x00000000);
            var bitmap:Bitmap = new Bitmap(_spectrumGraph);
            this.addChild(bitmap);
            bitmap.x = 10;
            bitmap.y = 10;

            addEventListener(Event.ENTER_FRAME, onEnterFrame);
            _sound 		= new Sound(new URLRequest("war.mp3"));
            _channel 	= _sound.play(  );
        }
        
        public function onEnterFrame(event:Event):void
        {
            // Create the byte array and fill it with data
            var spectrum:ByteArray = new ByteArray();
            SoundMixer.computeSpectrum(spectrum);
            
            // Clear the bitmap
            _spectrumGraph.fillRect(_spectrumGraph.rect,
                                     0x00000000);
            
            // Create the left channel visualization
            for(var i:int=0;i<256;i++) {
                _spectrumGraph.setPixel32(i, 
                              20 + spectrum.readFloat() * 20, 
                              0xffffffff);
            }
            
            // Create the right channel visualization
            for(var i:int=0;i<256;i++) {
                _spectrumGraph.setPixel32(i,
                              40 + spectrum.readFloat() * 20,
                              0xffffffff);
            }
        }       
    }
}