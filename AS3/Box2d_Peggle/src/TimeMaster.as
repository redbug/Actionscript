package
{
	import com.greensock.TweenLite;
	
	public class TimeMaster
	{
		private var _frameRate			:Number;
		private var _frameRate_orgin	:Number;
		
		
		public function TimeMaster(designatedFrameRate:Number)
		{
			_frameRate_orgin = _frameRate = designatedFrameRate;
		}
		
		public function get frameRate():Number
		{
			return _frameRate;
		}
		
		public function set frameRate(frameRate:Number):void
		{
			_frameRate = frameRate; 
		}
		
		public function getTimeStep():Number
		{
			return (1.0 / frameRate);
		}
		
		public function slowDown():void
		{
			TweenLite.to(this, 0.5, {frameRate: _frameRate_orgin * 2});
//			_frameRate = _frameRate_orgin * 2;
		}
		
		public function backToNormal():void
		{
			TweenLite.to(this, 0.5, {frameRate: _frameRate_orgin});
//			_frameRate = _frameRate_orgin; 
		}
		
	}
}