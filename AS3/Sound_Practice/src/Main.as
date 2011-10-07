package {
    import flash.display.Sprite;
    import flash.media.Sound;
    
    public class Main extends Sprite {
        private var _sound:Sound;
        
        public function Main(  ) {
        	//addChild(new LoadingProgress());
        	//new PlayList();
        	//addChild(new PlayProgress());
        	//addChild(new PauseAndRestart());
        	//addChild(new SoundLevels());
        	//addChild(new Spectrum());
        	//addChild(new VolumeAndPan());
        	addChild(new CookBookPlayer());
        }
    }
}