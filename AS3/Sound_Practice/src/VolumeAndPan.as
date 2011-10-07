package
{
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.media.Sound;
	import flash.media.SoundChannel;
	import flash.media.SoundTransform;
	import flash.net.URLRequest;
	import flash.text.TextField;
	
	public class VolumeAndPan extends Sprite
	{
		var incr_sp:Sprite;
		var decr_sp:Sprite;
		var left_sp:Sprite;
		var right_sp:Sprite;			
			
			
		var incr_txt:TextField;
		var decr_txt:TextField;
		
		var _sound:Sound;
		var _channel:SoundChannel;
		var _transform:SoundTransform;
		
		public function VolumeAndPan()
		{
			incr_sp		= new Sprite();
			decr_sp		= new Sprite();
			left_sp		= new Sprite();
			right_sp	= new Sprite();					 
					 
			incr_sp.graphics.beginFill(0x333333);
			incr_sp.graphics.drawRect(0,0,10,10);
			incr_sp.graphics.endFill();	
			
			decr_sp.graphics.beginFill(0xffff33);
			decr_sp.graphics.drawRect(0,0,10,10);
			decr_sp.graphics.endFill();		 

			left_sp.graphics.beginFill(0xaa333b);
			left_sp.graphics.drawRect(0,0,10,10);
			left_sp.graphics.endFill();	
			
			right_sp.graphics.beginFill(0x3bb33c);
			right_sp.graphics.drawRect(0,0,10,10);
			right_sp.graphics.endFill();	

			incr_txt	= new TextField();
			decr_txt	= new TextField();
			
			incr_txt.selectable = false;
			decr_txt.selectable = false;
			
			incr_txt.text = "+";
			decr_txt.text = "-";
						
			incr_sp.x = 100;
			incr_sp.y = 100;
			
			decr_sp.x = 150;
			decr_sp.y = 100;
			
			left_sp.x = 100;
			left_sp.y = 150;
			
			right_sp.x = 150;
			right_sp.y = 150;
			
			incr_txt.x = incr_sp.x;
			incr_txt.y = incr_sp.y - 15;
			
			decr_txt.x = decr_sp.x;
			decr_txt.y = decr_sp.y - 15;

			this.addChild(incr_txt);
			this.addChild(decr_txt);
						
			this.addChild(incr_sp);
			this.addChild(decr_sp);
			this.addChild(left_sp);
			this.addChild(right_sp);
			
			incr_sp.addEventListener(MouseEvent.CLICK, incrVolume);
			incr_sp.addEventListener(MouseEvent.MOUSE_OVER, showButton);
			
			decr_sp.addEventListener(MouseEvent.CLICK, decrVolume);
			decr_sp.addEventListener(MouseEvent.MOUSE_OVER, showButton);
			
			left_sp.addEventListener(MouseEvent.CLICK, panLeft);
			left_sp.addEventListener(MouseEvent.MOUSE_OVER, showButton);
			
			right_sp.addEventListener(MouseEvent.CLICK, panRight);
			right_sp.addEventListener(MouseEvent.MOUSE_OVER, showButton);
			
			_sound = new Sound(new URLRequest("war.mp3"));
			_channel = _sound.play();
			_transform = new SoundTransform();
			_transform.volume = 0.5;	
			_channel.soundTransform = _transform;		
		}
		
		private function showButton(event:MouseEvent):void
		{
			Sprite(event.currentTarget).buttonMode = true;
		}
		
		private function incrVolume(event:MouseEvent):void
		{
			_transform.volume += 0.1;
			_channel.soundTransform = _transform;	
		}
		
		private function decrVolume(event:MouseEvent):void
		{	
			_transform.volume -= 0.1;
			_channel.soundTransform = _transform;	
		}


		private function panLeft(event:MouseEvent):void
		{	
			_transform.pan = -1,0;
			_channel.soundTransform = _transform;	
		}
		
		private function panRight(event:MouseEvent):void
		{	
			_transform.pan = 1,0;
			_channel.soundTransform = _transform;	
		}

	}
}