	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Loader;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.net.FileFilter;
	import flash.net.FileReference;
	import flash.net.URLRequest;

		/* path Strings */	
		private const urlRequest:String = "http://mira.cs.nccu.edu.tw/pfh/picUpload.php";
		private const urlPic:String =	"./profilePic/";		//profile picture
		private const urlDownloadPic:String = "../profilePic/";
		private const urlThumbPic:String = "./thumbPic/";		//the position related to imageCrop.php 									
		private const urlCrop:String = "../imageCrop.php";
		
	    private var file:FileReference;
	    private var fileFilter:FileFilter;
	    private var _loader:Loader; 
	  	
	  	/* the variables for spotlight */	
	  	private var minRadius:Number;
	  	private var maxRadius:Number;			//長寬中的短邊
	  	
	  	/* the variables for Image crop */	
		private var lightSpot:Sprite;
		private var mcLightPic:Sprite;
		private var mcDarkPic:Sprite;
			
		private var picloader1:Loader;
		private var picloader2:Loader;
		
		private var filename:String;
		private var extension:String;

		public function init():void{
			file = new FileReference();
			fileFilter = new FileFilter("Images(jpg, gif, png)", "*.png;*.gif;*.jpg;");
			_loader = new Loader();
			minRadius = 50;
			lightSpot = new Sprite();		
			mcLightPic = new Sprite();
			mcDarkPic = new Sprite();
			
		}
	    
		
		//***********************************************
		//* browse the picture
		//***********************************************		    
	    public function uploadPic():void{	
	    	try{
				file.addEventListener(Event.SELECT, selectHandler);
				file.addEventListener(DataEvent.UPLOAD_COMPLETE_DATA   , uploadCompleteHandler);
	
				file.browse([fileFilter]);
				file.browse();  
			}catch(illeglOperation:IllegalOperationError){
				trace("hey guy! something wrong!!");
			}
	    }
	    
	    
	    //**********************************************
	    //* select picture and upload it.
	    //**********************************************
	    public function selectHandler(event:Event):void{
	    	filename = file.name;
	    	picPath.text = filename;
	    	
	    	// add codes which request user to confirm the picture selecting.
	    	var request:URLRequest = new URLRequest(urlRequest);
	    	request.method = URLRequestMethod.POST;
 			
			var variables:URLVariables = new URLVariables();
			
			//取得副檔名	
			extension = filename.substr(filename.lastIndexOf(".")+1, filename.length);			
			variables.ext = extension;
			request.data = variables;
							 		    	
	    	try{
	    		file.upload(request);
	    	}catch(error:Error){}		    	
	    }
	    
	    
	    // 上傳縮完圖, 便下載至本地端 
	    public function uploadCompleteHandler(event:DataEvent):void {  			      	
          downloadPic(urlDownloadPic+filename);
          this.crop.enabled = true;
          this.slider.enabled = true;
        }
		
			
		/*******************************************
		 *  show the picture on screen 
		 *******************************************/			
		public function downloadPic(urlPic:String):void{
			var urls:String = new String(urlPic);

			picloader1 = new Loader();
			picloader2 = new Loader();
 			
 			picloader1.load(new URLRequest(urls));
 			picloader2.load(new URLRequest(urls));

			//清除舊圖先, 為了使用者可重新上傳圖	 			
			for(var i:int = 0; i<mcLightPic.numChildren;i++){	
				mcLightPic.removeChildAt(i);
				mcDarkPic.removeChildAt(i);
			}	

 			mcLightPic.addChild(picloader1);
			mcDarkPic.addChild(picloader2);
			
			mcDarkPic.alpha = 0.5;			
			filterPic();
		}


		/*******************************************
		 *  to initialize lightSpot
		 *******************************************/	
		public function filterPic():void {
			mcDarkPic.addChild(lightSpot);

			lightSpot.graphics.lineStyle(1,0x000000);
			lightSpot.graphics.beginFill(0x0000FF);
			lightSpot.graphics.drawCircle(0, 0, minRadius);
			lightSpot.graphics.endFill();

			lightSpot.x = minRadius;
			lightSpot.y = minRadius;
			
			mcLightPic.mask = lightSpot;
			
			mcDarkPic.addEventListener(MouseEvent.MOUSE_DOWN, startMove);
			this.addEventListener(MouseEvent.MOUSE_UP, stopMove); 
			this.addEventListener(MouseEvent.MOUSE_OUT, stopMove);
						
			this.preimage.addChild(mcLightPic);
			this.preimage.addChild(mcDarkPic);
		
			/* 使用者每次上傳圖，都將spotlight還原 */
			lightSpot.width = minRadius*2;
			lightSpot.height = minRadius*2;
			slider.value = 1;
		}
			
			
		/*******************************************
		 *  利用slider來scale spotlight.
		 *******************************************/		
		public function scaleLightSpot():void{			
			var ratio:Number;
			maxRadius = Math.min(picloader1.width,picloader1.height);
			maxRadius /=2;
			
			var step:Number = (maxRadius-minRadius)/100;				 	
			ratio = step * slider.value;
			lightSpot.width = (minRadius+ratio) * 2;	
			lightSpot.height = lightSpot.width;
						
			var r:Rectangle = lightSpot.getBounds(mcLightPic);
			checkBoundry();				
		}


		/*******************************************
		 *  to scale the lightSpot
		 *******************************************/		
		public function cropImage():void{
			if(mcLightPic == null){
				return;
			}
			var r:Rectangle = lightSpot.getBounds(mcLightPic);

  			var len:int = 2*minRadius;
  			var scaleFactor:Number = len/r.width;

			/* 其實就是minRadius */
  			var newWidth:int = r.width * scaleFactor;
  			var newHeight:int = r.height *scaleFactor;

 			var oldBitmap:BitmapData = new BitmapData(picloader1.width, picloader1.height);
			var cropBitmap:BitmapData = new BitmapData(r.width, r.height);
			var scaleBitmap:BitmapData = new BitmapData(newWidth, newHeight);
 			oldBitmap.draw(picloader1);
			
			var scaleMatrix:Matrix = new Matrix();
			scaleMatrix.scale(scaleFactor,scaleFactor);
			
 			cropBitmap.copyPixels(oldBitmap, r, new Point(0,0));
			scaleBitmap.draw(cropBitmap, scaleMatrix,null,null,null,true);
			var bitmap:Bitmap = new Bitmap(scaleBitmap);
  			
  			//清舊圖先.
  			for(var i:int = 0; i<this.precrop.numChildren; i++) 
				this.precrop.removeChildAt(i);
			
			this.precrop.addChild(bitmap);	
			
			sendData(r, scaleFactor);
		}
		
		
		/*******************************************************
		 * send the arguments of cropImage to imageCrop.php
		 *******************************************************/	
		public function sendData(r:Rectangle, scaleFactor:Number):void{
			var request:URLRequest = new URLRequest(urlCrop);
			var variables:URLVariables = new URLVariables();
			
			variables.destPic = urlThumbPic+"t_"+filename;
			variables.srcPic = urlPic+filename;
			variables.recX = r.x;
			variables.recY = r.y;
			variables.width = r.width;
			variables.height = r.height; 
			variables.scaleFactor = scaleFactor;
			variables.extension = extension;
			
			request.data = variables;
			request.method = URLRequestMethod.POST;
			sendToURL(request);
			//navigateToURL(request, "_blank");	   //for debug php codes.
		}
			
			
		public function startMove(evt:MouseEvent):void {
			lightSpot.startDrag(true,mcLightPic.getBounds(this.preimage));
		}


		public function checkBoundry(/*e:MouseEvent*/):void {
			var r:Rectangle = lightSpot.getBounds(mcLightPic);				
			lightSpot.x = boundedX(lightSpot.x);
			lightSpot.y = boundedY(lightSpot.y);
		}


		public function stopMove(e:MouseEvent):void {
			lightSpot.stopDrag();
			checkBoundry();	
		}
		
		
		public function boundedX(inX:Number):Number {
			var r:Rectangle = lightSpot.getBounds(mcLightPic);

			if ( r.left < 0) {
				return 0+lightSpot.width/2;
			}
			if (r.right > mcLightPic.width) {
				return mcLightPic.width-lightSpot.width/2;
			}
			return inX;
		}


		public function boundedY(inY:Number):Number {
			var r:Rectangle = lightSpot.getBounds(mcLightPic);
			if ( r.top < 0) {
				return 0+lightSpot.width/2;
			}
			if (r.bottom > mcLightPic.height) {
				return mcLightPic.height-lightSpot.width/2;
			}
			return inY;
		}
