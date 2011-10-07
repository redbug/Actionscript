package app
{
	import mx.controls.sliderClasses.*;
	public class MySliderThumb extends SliderThumb
	{
		override protected function measure():void{
			super.measure();
			measuredWidth = 15;
			measuredHeight =15;
		}
	}
}