package
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.filters.BitmapFilterQuality;
	import flash.filters.BlurFilter;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.utils.ByteArray;
	
	import mx.core.BitmapAsset;
	
	[SWF(width="1012", height="705", frameRate="30", backgroundColor="#FFFFCC")]
	public class Main extends Sprite
	{
		[Embed(source="ex.jpg")]
		private var Photo:Class;
		
		public function Main()
		{
			ex6();
		}
		
		public function ex6():void
		{
			var photo:BitmapAsset	= new Photo();
			var blurFilter:BlurFilter = new BlurFilter(0, 0, BitmapFilterQuality.MEDIUM);
			var bitmapdata:BitmapData = photo.bitmapData;
			bitmapdata.applyFilter(bitmapdata, bitmapdata.rect, new Point(0,0), blurFilter);
			addChild(photo);
		}
		
		public function ex5():void
		{
			var blueSquare:BitmapData	= new BitmapData(20, 20, false, 0xFF0000FF);
			var greenSquare:BitmapData	= new BitmapData(30, 30, false, 0xFF00FF00);
			
			var rectRegion:Rectangle = new Rectangle(5, 5, 10, 10);
			
			var greenPixels:ByteArray = greenSquare.getPixels(rectRegion);
			greenPixels.position = 0;
			
//			blueSquare.setPixels(rectRegion, greenPixels);
			blueSquare.copyPixels(greenSquare, rectRegion, new Point(5, 5));
			
			var blueBmp:Bitmap	= new Bitmap(blueSquare);
			var greenBmp:Bitmap	= new Bitmap(greenSquare);
			
			addChild(blueBmp);
			addChild(greenBmp);
			
			greenBmp.x = 40;
		}
		
		public function ex4():void
		{
			var imgData:BitmapData = new BitmapData(20, 20, true, 0x00FFFFFF);
			trace(imgData.getPixel32(0,0));
		}
		
		public function ex3():void
		{
			var imgData1:BitmapData		= new BitmapData(20, 20, true, 0x330000FF);
			trace(imgData1.getPixel32(0, 0));
			
			var imgData2:BitmapData		= new BitmapData(20, 20, false, 0x330000FF);
			trace(imgData2.getPixel32(0, 0));
		}
		
		public function ex2():void
		{
			var photo:BitmapAsset	= new Photo();
			addChild(photo);
			trace(photo.bitmapData.getPixel(0,0).toString(16));
		}
		
		public function ex1():void
		{
			var imgData	:BitmapData	= new BitmapData(20, 20, false, 0xFF00FF00);
			imgData.fillRect(new Rectangle(5,5,10,10), 0xFF0000FF);
			
			var bmp1		:Bitmap		= new Bitmap(imgData);
			this.addChild(bmp1);
			
			var bmp2		:Bitmap		= new Bitmap(imgData);
			bmp2.rotation	= 045;
			bmp2.x			= 50;
			bmp2.scaleX		= 2;
			bmp2.scaleY		= 2;
			addChild(bmp2);
		}
	}
}