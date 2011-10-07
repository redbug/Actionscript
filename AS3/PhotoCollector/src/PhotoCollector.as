package
{
    import flash.display.Sprite;
    import flash.events.Event;
    import flash.text.TextField;
    
    import idv.redbug.robotbody.CoreContext;
    
    [SWF(width="1200", height="600", frameRate="30", backgroundColor="#FFFFCC")]
    public class PhotoCollector extends Sprite
    {
        protected var _context:CoreContext;
        
        public function PhotoCollector()
        {
            this._context = new CoreContext(this, SceneA);
        }
    }
}