package
{
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.text.TextField;

	import com.igs.acd2.utils.*;
	import com.igs.acd2.gameFramework.CoreContext;
	
	[SWF(width="550", height="400", frameRate="30", backgroundColor="#FFFFFF")]
	public class Main extends Sprite
	{
		protected var _context:CoreContext;
		
		public function Main()
		{
			this._context = new CoreContext(this, SceneA, SceneB);
		}
	}
}