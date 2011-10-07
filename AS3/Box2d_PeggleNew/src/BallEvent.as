package
{
	import flash.events.Event;
	
	public class BallEvent extends Event
	{
		public static const BALL_OFF_SCREEN	:String	=	"ballOffScreen";
		public static const BALL_HIT_BONUS	:String =	"ballHitBonus";
		
		public function BallEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
		
		public override function clone():Event
		{
			return new BallEvent(type, bubbles, cancelable);
		}
		
		public override function toString():String
		{
			return formatToString(	"BallEvent", "type", "bubbles", "cancelable", "eventPhase");
		}
		
	}
}