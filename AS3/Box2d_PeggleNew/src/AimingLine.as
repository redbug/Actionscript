package
{
	import flash.display.Sprite;
	import flash.geom.Point;
	
	public class AimingLine extends Sprite
	{
		private var _gravityInMeter:Number;
		
		public function AimingLine(gravityInMeter:Number)
		{
			_gravityInMeter = gravityInMeter;
		}
		
		public function showLine(startPoint:Point, direction:Point, velocityInPixels:Number):void
		{
			//This is going to be the vector that our ball will be travelling in, in pixel
			var velocityVect:Point = direction.clone();
			
			//Our velocity is the correct length, in pixels per second
			velocityVect.normalize(velocityInPixels);
		
			var gravityInPixels:Number = _gravityInMeter * PhysicVars.PIXEL_TO_METER;
			
			var stepPoint:Point = startPoint.clone();
			
			this.graphics.clear();
			this.graphics.lineStyle(12, 0x00ff00, .4);
			this.graphics.moveTo(stepPoint.x, stepPoint.y);
			
			//The steps per second that we're going to draw.
			var granularity:Number = 20;
			for(var i:int = 0; i < granularity; ++i)
			{
				velocityVect.y += gravityInPixels / granularity;
				
				stepPoint.x += velocityVect.x / granularity;
				stepPoint.y += velocityVect.y / granularity;
				
				this.graphics.lineTo(stepPoint.x, stepPoint.y);
			}
		}
		
		public function hide():void
		{
			this.graphics.clear();
		}
		
	}
}