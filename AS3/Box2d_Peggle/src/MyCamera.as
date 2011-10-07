package
{
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.Point;
	import com.greensock.TweenLite;
	
	public class MyCamera extends Sprite
	{
		
		private const ZOOM_IN_AMOUNT	:Number = 1.5;
		
		public function MyCamera()
		{
//			this.addEventListener(Event.ENTER_FRAME, moveUp);	
		}
		
		public function moveUp(event:Event = null):void
		{
			this.y--;
		}
		
		public function zoomInTo(targetPoint:Point):void
		{
//			this.scaleX = ZOOM_IN_AMOUNT;
//			this.scaleY = ZOOM_IN_AMOUNT;
			
			//calculate the center point of the stage.
			var cX:Number = this.stage.stageWidth >> 1;
			var cY:Number = this.stage.stageHeight >> 1;
			
			//calculate the target point that has been scaled.
			var pX:Number = targetPoint.x *  ZOOM_IN_AMOUNT;
			var pY:Number = targetPoint.y *  ZOOM_IN_AMOUNT;
			
			//caculate the translation of the point of origin.
//			this.x = cX - pX;
//			this.y = cY - pY;
			var targetX:int = cX - pX;
			var targetY:int = cY - pY;
			
			TweenLite.to(this, 1.0, {x:targetX, y:targetY, scaleX:ZOOM_IN_AMOUNT, scaleY:ZOOM_IN_AMOUNT} );
			
		}
		
		public function zoomOut():void
		{
			TweenLite.to(this, 1.0, {x:0, y:0, scaleX:1.0, scaleY:1.0} );
//			this.scaleX = 1;
//			this.scaleY = 1;
//			
//			this.x = 0;
//			this.y = 0;
		}	
		
		
	}
}