package
{
    import flash.display.Sprite;
    import flash.events.Event;
    import flash.text.TextField;
    
    import idv.redbug.robotbody.CoreContext;
    
    [SWF(width="1000", height="700", frameRate="30", backgroundColor="#FFFFFF")]
    public class MTurkPhotoSelection extends Sprite
    {
        protected var _context:CoreContext;
        
        public function MTurkPhotoSelection()
        {
            this._context = new CoreContext(this, SceneA);
        }
    }
}