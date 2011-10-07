package
{
	import flash.events.Event;
	
	public class PegEvent extends Event
	{
		public static const LIT_UP			:String = "pegLitUp";
		public static const DONE_FADING_OUT	:String = "doneFadingOut";
		
		public function PegEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
		
		public override function clone():Event
		{
			return new PegEvent(type, bubbles, cancelable);
		}
		
		public override function toString():String
		{
			return formatToString(	"PegEvent", "type", "bubbles", "cancelable", "eventPhase");
		}
	}
}