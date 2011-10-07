package
{
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.geom.Point;
	import flash.text.TextField;
	
	public class Shooter extends MovieClip
	{
		private const BALL_OFFSET:Point = new Point(70,0);
		
		
		public function Shooter()
		{
			this.addEventListener(Event.ENTER_FRAME, alignToMouse);			
		}
		
		public function alignToMouse(event:Event):void
		{
			var mouseAngle:Number = Math.atan2(	this.stage.mouseY - this.y, 
												this.stage.mouseX - this.x) * 180 / Math.PI;
			this.rotation = mouseAngle;
		}
		
		public function getLaunchPosition():Point
		{
			return localToGlobal(BALL_OFFSET);
		}
		
	}
}