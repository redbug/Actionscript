/**
* flipBoard Version 1 by Peter Organa. June, 02, 2008
* Visit http://blog.organa.ca for documentation, updates and more free code.
*
*
* Copyright (c) 2008 Peter Organa
* 
* Permission is hereby granted, free of charge, to any person
* obtaining a copy of this software and associated documentation
* files (the "Software"), to deal in the Software without
* restriction, including without limitation the rights to use,
* copy, modify, merge, publish, distribute, sublicense, and/or sell
* copies of the Software, and to permit persons to whom the
* Software is furnished to do so, subject to the following
* conditions:
* 
* The above copyright notice and this permission notice shall be
* included in all copies or substantial portions of the Software.
* 
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
* EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
* OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
* NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
* HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
* WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
* FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
* OTHER DEALINGS IN THE SOFTWARE.
*/
package {
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.MovieClip;
	import flash.events.ErrorEvent;
	import flash.filters.GlowFilter;
	import flash.geom.ColorTransform;
	import flash.text.TextField;
	import ca.organa.flickrGrabber;
	import ca.organa.flipPanel;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.utils.Timer;
	import flash.events.TimerEvent;
	import flash.text.TextField;
	import flash.events.MouseEvent;
	import imageLabel;
	import errorClip;
	public class flipBoard extends MovieClip {
		//The height and width of your stage
		private const DISPLAY_WIDTH:int = 450;
		private const DISPLAY_HEIGHT:int = 360;
		//The Height and width the of the display panels.
		private const SQUARE_WIDTH:int = 30
		private const SQUARE_HEIGHT:int = 30;
		//How many miliseconds between starting the animation cycle on more panels
		private const PICK_TIMING:Number = 60;
		//How many panels are flipped into the on position per timer cycle.
		private const PICK_AMOUNT:Number = 6;
		//How long to wait between images (kicks in once the animation is complete)
		private const IMAGE_TIMING:Number = 5000;
		//When the user clicks how random is circle generated (higher == more random)
		private const DISTANCE_VARIANCE:Number = 100
		//Max and min speeds of the flipping panels.
		private const MAX_FLIP_SPEED:Number = 0.1;
		private const MIN_FLIP_SPEED:Number = 0.05;
		//Do we show titles?
		private const SHOW_TITLES:Boolean = true;
		//
		private var errorTextBox:errorClip;
		private var imageSource:flickrGrabber;
		private var hPanelCount:int;
		private var vPanelCount:int;
		private var panelList:Array;
		private var flipList:Array;
		private var imageTimer:Timer;
		private var pickTimer:Timer;
		private var nextImageReady:Boolean = false;
		private var waitingForNextImage:Boolean = true;
		private var clickMode:Boolean = false;
		private var clickPosition:Point;
		//I'm specifying a bunch of possible search terms here, but you really only need one.
		private var searchTerms:Array = [["Cardigan Welsh Corgi", false], ["Piotr M", true], ["Zoubin Zarin", true], ["Isto-ica", true], ["Robocop", false]];
		private var animationInProgress:Boolean;
		//
		public function flipBoard() {
			var randomTerm:Number = Math.floor(Math.random() * searchTerms.length);
			//
			//YOU NEED YOUR OWN FLICKR API KEY AND SECRET TERM!  Get one here: http://www.flickr.com/services/api/misc.api_keys.html
			//
			imageSource = new flickrGrabber(DISPLAY_WIDTH, DISPLAY_HEIGHT, "GETYOUROWN", "GETYOUROWN", searchTerms[randomTerm][0], searchTerms[randomTerm][1]);
			imageSource.addEventListener("imageReady", loadedImage);
			imageSource.addEventListener("flickrGrabberError", errorImage);
			imageSource.addEventListener("flickrConnectionReady", onFlickrReady);
			//
			imageTimer = new Timer(IMAGE_TIMING, 1);
			imageTimer.addEventListener(TimerEvent.TIMER, prepNextImage);
			//
			pickTimer = new Timer(PICK_TIMING);
			pickTimer.addEventListener(TimerEvent.TIMER, pickFromArray);
			//
			createPanels();
		}
		private function onFlickrReady(evt:Event):void {
			nextImage();
		}
		private function nextImage():void {
			imageSource.loadNextImage();
		}
		private function processImage(clickToNext:Boolean):void {
			waitingForNextImage = false;
			nextImageReady = false;
			var sampleImage:Bitmap = imageSource.image;
			var shrinkRatio:Number = Math.min(DISPLAY_WIDTH/sampleImage.width, DISPLAY_HEIGHT/sampleImage.height);
			if (shrinkRatio < 1) {
				sampleImage.scaleX = sampleImage.scaleY = shrinkRatio;
			}
			
			var roundedWidth:int = Math.floor(sampleImage.width / SQUARE_WIDTH) * SQUARE_WIDTH;
			var roundedHeight:int = Math.floor(sampleImage.height / SQUARE_HEIGHT) * SQUARE_HEIGHT;
			//
			var redrawMatrix:Matrix = new Matrix();
			redrawMatrix.scale(shrinkRatio, shrinkRatio);
			var drawFromBitmapData:BitmapData = new BitmapData(sampleImage.width, sampleImage.height);
			drawFromBitmapData.draw(sampleImage, redrawMatrix, null, null, null, true);
			
			if (SHOW_TITLES){
				var imageInfo:imageLabel = new imageLabel();
				var infoField:TextField = imageInfo.imageText as TextField;
				infoField.text = imageSource.imageTitle;
				if (imageSource.imageAuthor != null && imageSource.imageAuthor != "" && imageSource.imageAuthor != " ") {
					infoField.appendText("\nby " + imageSource.imageAuthor);
				}
				imageInfo.filters = [new GlowFilter(0x000000, 0.6, 4, 4, 4, 1)];
				var infoBitmapData:BitmapData = new BitmapData(infoField.width, infoField.height, true, 0x000000);
				infoBitmapData.draw(imageInfo, null, new ColorTransform(1, 1, 1, 0.7));
				drawFromBitmapData.copyPixels(infoBitmapData, new Rectangle(0, 0, infoBitmapData.width, infoBitmapData.height), new Point(0, roundedHeight - infoBitmapData.height), null, null, true);
			}
			//
			var copyRect:Rectangle = new Rectangle();
			//
			var drawHCount:int = roundedWidth / SQUARE_WIDTH;
			var drawVCount:int = roundedHeight / SQUARE_HEIGHT;
			var xRangeStart:int = Math.floor((hPanelCount - drawHCount) / 2);
			var xRangeEnd:int = hPanelCount-Math.ceil((hPanelCount - drawHCount) / 2)-1;
			var yRangeStart:int = Math.floor((vPanelCount - drawVCount) / 2);
			var yRangeEnd:int = vPanelCount - Math.ceil((vPanelCount - drawVCount) / 2) - 1;
			//
			flipList = new Array();		
			var ii:int;

			for (var i:int = 0; i < vPanelCount; i++) {
				for (ii = 0; ii < hPanelCount; ii++) {
					var activePanel:flipPanel = panelList[i * hPanelCount + ii];
					if (clickToNext) {
						var dx:Number = clickPosition.x - (activePanel.x + SQUARE_WIDTH / 2);
						var dy:Number = clickPosition.y - (activePanel.y + SQUARE_HEIGHT / 2);
						activePanel.distance = Math.sqrt(dx * dx + dy * dy) + (Math.random() * DISTANCE_VARIANCE - DISTANCE_VARIANCE / 2);
					}
					if (ii >= xRangeStart && ii <= xRangeEnd && i >= yRangeStart && i <= yRangeEnd) {
						//I subtract the rangeStart values in case the image is centered.
						//Grab a bit of the bitmap and assign it to the panel as its next value.
						copyRect = new Rectangle((ii-xRangeStart) * SQUARE_WIDTH, (i-yRangeStart)*SQUARE_HEIGHT, SQUARE_WIDTH, SQUARE_HEIGHT);
						var assignBitmapData:BitmapData = new BitmapData(SQUARE_WIDTH, SQUARE_HEIGHT);
						assignBitmapData.copyPixels(drawFromBitmapData, copyRect, new Point(0, 0));
						activePanel.assignBitmap(assignBitmapData);
						//
						activePanel.nextActive = true;
						if (!clickToNext){
							addToRandomList(activePanel);
						} else {
							flipList.push(activePanel);
						}
					} else if (!activePanel.flipToShow) {
						activePanel.nextActive = false;
						if (!clickToNext){
							addToRandomList(activePanel);
						} else {
							flipList.push(activePanel);
						}
					}
				}
			}
			if (clickToNext) {
				flipList.sortOn("distance", Array.NUMERIC);
			}
			animationInProgress = true;
			pickTimer.reset();
			pickTimer.start();
			nextImage();
			stage.addEventListener(MouseEvent.CLICK, forceNext);
			this.addEventListener(Event.ENTER_FRAME, flipOut);		
		}
		private function forceNext(evt:MouseEvent):void {
			if (nextImageReady && !animationInProgress) {
				imageTimer.stop();
				clickPosition = new Point(stage.mouseX, stage.mouseY);
				processImage(true)
				
			}
		}
		private function flipOut(evt:Event):void {
			var panelCount:int = panelList.length;
			var panelsDone:int = 0;
			for (var i:int = 0; i < panelCount; i++) {
				var checkPanel:flipPanel = panelList[i];
				if (checkPanel.active) {
					checkPanel.flipAction();
				}else {
					panelsDone++;
				}
			}
			if (panelsDone == panelCount && flipList.length == 0 ) {
				animationInProgress = false;
				this.removeEventListener(Event.ENTER_FRAME, flipOut);
				imageTimer.reset();
				imageTimer.start();
			}
		}
		private function prepNextImage(evt:TimerEvent):void {
			if (nextImageReady) {
				processImage(false);
			} else {
				waitingForNextImage = true;
			}
		}

		private function loadedImage(evt:Event):void {
			if (waitingForNextImage) {
				processImage(false);
			} else {
				nextImageReady = true;
			}
		}
		private function errorImage(evt:ErrorEvent):void {
			errorTextBox = new errorClip();
			errorTextBox.x = (DISPLAY_WIDTH - errorTextBox.width) / 2;
			errorTextBox.y = (DISPLAY_HEIGHT - errorTextBox.height) / 2;
			addChild(errorTextBox);
			errorTextBox.errorBox.text = evt.text;
		}
		private function createPanels():void {
			panelList = new Array();
			hPanelCount = Math.floor(DISPLAY_WIDTH / SQUARE_WIDTH);
			vPanelCount = Math.floor(DISPLAY_HEIGHT / SQUARE_HEIGHT);
			var hPos:int = 0;
			var vPos:int = 0;
			//
			var halfSquareX:Number = SQUARE_WIDTH / 2;
			var ii:int;
			for (var i:int = 0; i < vPanelCount; i++) {
				for (ii = 0; ii < hPanelCount; ii++) {
					var newPanel:flipPanel = new flipPanel(SQUARE_WIDTH, SQUARE_HEIGHT,MAX_FLIP_SPEED, MIN_FLIP_SPEED);
					newPanel.x = ii * SQUARE_WIDTH + halfSquareX;
					newPanel.y = i * SQUARE_HEIGHT;
					
					panelList.push(newPanel);
					addChild(newPanel);
				}
			}
		}
		private function addToRandomList(newPanel:flipPanel) {
			var randomPick:int = Math.floor(flipList.length * Math.random());
			flipList.splice(randomPick, 0, newPanel);
		}
		//Called from a timer event this function picks X number of panels at random and flips them.
		private function pickFromArray(evt:TimerEvent):void {
			var pickCount:int;
			for (var i:int = 0; i < PICK_AMOUNT && i < flipList.length; i++) {
				var randomPanel:flipPanel = flipList.shift();
				randomPanel.active = true;
			}
			if (flipList.length <= 0) {
				pickTimer.stop();
			}
		}
		//Find the panel specified by the x,y co-ordinate
		private function identifyBlock(xPos:Number, yPos:Number) {
			var arrayPosition:int = Math.floor(yPos / SQUARE_HEIGHT) * hPanelCount;
			arrayPosition += Math.floor(xPos / SQUARE_WIDTH);
			//
			return arrayPosition;
		}
	}
}