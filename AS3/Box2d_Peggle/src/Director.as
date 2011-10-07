package
{
	import flash.geom.Point;
	import flash.media.Camera;
	import flash.utils.getTimer;

	public class Director
	{
		
		private var _camera					:MyCamera;
		private var _timeMaster				:TimeMaster; 
		private var _isZoomIn				:Boolean;
		private var _minimumTimeToZoomOut	:int;
		
		public function Director(camera:MyCamera, timeMaster:TimeMaster)
		{
			_camera = camera;
			_timeMaster = timeMaster;
			
			_isZoomIn = false;
			_minimumTimeToZoomOut = 0;
		}
		
		public function zoomInTo(targetPoint:Point):void
		{
			if(! _isZoomIn){
				_isZoomIn = true;
				_camera.zoomInTo(targetPoint);
				_timeMaster.slowDown();	
				
				_minimumTimeToZoomOut = getTimer() + 1000;
			}
		}
		
		public function backToNormal():void
		{
			if(_isZoomIn){
				if(getTimer() >= _minimumTimeToZoomOut){
					_isZoomIn = false;
					_camera.zoomOut();
					_timeMaster.backToNormal();
				}
			}
		}
		
	}
}