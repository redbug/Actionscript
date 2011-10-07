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
	import flash.display.Sprite;
	import flash.filters.ColorMatrixFilter;
	import flash.geom.Point;
	public class flipPanel extends Sprite {
		private var myBitmap:Bitmap;
		private var myBitmapData:BitmapData;
		private var nextBitmapData:BitmapData;
		private var myActive:Boolean = false;
		private var myNextActive:Boolean = false;
		private var flipSpeed:Number;
		public var flipToShow:Boolean = true;
		private var nextImageDisplayed:Boolean = false;
		private var maxFlipSpeed:Number;
		private var minFlipSpeed:Number;
		private var myDist:Number;
		public function flipPanel(setWidth:int, setHeight:int, newMaxFlipSpeed:Number = 0.12, newMinFlipSpeed:Number = 0.07){
			myBitmapData = new BitmapData(setWidth, setHeight, false, 0xFF0000);
			nextBitmapData = new BitmapData(setWidth, setHeight, false, 0xFF0000);
			myBitmap = new Bitmap(myBitmapData);
			myBitmap.x = -(setWidth / 2);
			maxFlipSpeed = newMaxFlipSpeed;
			minFlipSpeed = newMinFlipSpeed;
			this.addChild(myBitmap);
			this.scaleX = 0;
		}
		public function assignBitmap(drawThis:BitmapData):void {
			nextBitmapData.draw(drawThis);
			nextImageDisplayed = false;
		}
		public function flipAction():void {
			if (!nextImageDisplayed && flipToShow) {
				nextImageDisplayed = true;
				myBitmapData.copyPixels(nextBitmapData, nextBitmapData.rect, new Point(0, 0));
			}
			var nextScaleX:Number;
			//Is the panel growing or contracting?
			if (flipToShow) {
				//nextScaleX = this.scaleX + (1-this.scaleX)*flipSpeed;
				nextScaleX = this.scaleX + flipSpeed;
				if (nextScaleX >= 0.97) {
					nextScaleX = 1;
					active = false;
					flipToShow = false;
				} 				
			} else {
				//nextScaleX = this.scaleX + (0 - this.scaleX) * flipSpeed;
				nextScaleX = this.scaleX- flipSpeed;
				if (nextScaleX < 0.03) {
					nextScaleX = 0;
					flipToShow = true;
					active = myNextActive
				}
			}
			var bright:Number = 0.5+nextScaleX/2;
			this.filters = [new ColorMatrixFilter([
				bright, 0, 0, 0, 0,
				0, bright, 0, 0, 0,
				0, 0, bright, 0, 0,
				0, 0, 0, 1, 0])];
			this.scaleX = nextScaleX
		}
		public function set active(activeState:Boolean):void {
			if (activeState){
				flipSpeed = Math.random() * (maxFlipSpeed - minFlipSpeed) + minFlipSpeed;
			}
			myActive = activeState;
		}
		public function set distance(newDistance:Number):void {
			myDist = newDistance;
		}
		public function get distance():Number {
			return myDist;
		}
		public function set nextActive(nextState:Boolean):void {
			myNextActive = nextState;
		}
		public function get active():Boolean {
			return myActive;
		}
	}
}