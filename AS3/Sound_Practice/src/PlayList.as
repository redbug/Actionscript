package {
    import flash.display.Sprite;
    import flash.media.Sound;
    import flash.net.URLRequest;
    import flash.events.Event;
    import flash.media.SoundChannel;
    
    public class PlayList extends Sprite {
        private var _sound:Sound;
        private var _channel:SoundChannel;
        private var _playList:Array;      // the list of songs
        private var _index:int = 0;       // the current song

        public function PlayList(  ) {
            // Create the playlist and start playing
            _playList = ["click.mp3", 
                        "bgMusic_SelectMachine.mp3",
                        "bgMusic_Bet.mp3"];
            playNextSong(  );
        }
        
        private function playNextSong(  ):void
        {
            // If there are still songs in the playlist
            if(_index < _playList.length) {
                // Create a new Sound object, load and play it
                // _playList[_index] contains the name and path of
                // the next song
                _sound = new Sound(  );
                _sound.load(new URLRequest(_playList[_index]));
                _channel = _sound.play(  );

                // Add the listener to the channel

                _channel.addEventListener(Event.SOUND_COMPLETE, onComplete);

                // Increase the counter
                _index++;
            }
        }
        
        public function onComplete(event:Event):void
        {
            playNextSong(  );
        }
    }    
}