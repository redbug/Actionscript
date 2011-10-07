/**
 * @author Cotton Hou
 */
package
{
	
	import flash.display.Sprite;
	import org.robotlegs.demos.helloflashstrict.HelloFlashSrictContext;
	
	public class Main extends Sprite
	{
		
		protected var context:HelloFlashSrictContext;
		
		public function Main()
		{
			this.context = new HelloFlashSrictContext(this);
		}
		
	}
}