package 
{
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.display.Scene;
	import flash.events.TimerEvent;
	import flash.filters.DisplacementMapFilter;
	import flash.media.Sound;
	import flash.text.TextField;
	import flash.utils.Dictionary;
	import flash.utils.Timer;
	
	import com.igs.acd2.utils.Toolkits;
	import com.igs.acd2.gameFramework.CoreContext;
	import com.igs.acd2.gameFramework.model.scene.BaseScene;
	import com.igs.acd2.gameFramework.model.scene.IScene;

	import mySocket.*;
	
	public class SceneA extends BaseScene
	{
		private const MY_SWF		:Array = ["TelnetSocket_View.swf"];
		private const MY_TXT		:Array = [];
		private const MY_MUSIC		:Array = [];
			
		//---------------------------------------------------------------------
		//  Override following functions for connecting to the core framework:
		//		init()
		//		run()
		//		destroy()
		//		switchTo()		
		//		accessSwf()
		//		accessTxt()
		//		accessMusic()
		//---------------------------------------------------------------------
		
		private var _telnetSocket	:TelnetSocket;
		
		
		
		override public function init():void
		{
			/***********************************************
			 * make a resource list for loading "SWF" files 
			 ***********************************************/
			makeSwfList(MY_SWF);

			/***********************************************
			 * make a resource list for loading "Text" files 
			 ***********************************************/
//			makeTxtList(MY_TXT);
			
			/***********************************************
			 * make a resource list for loading "MP3" files 
			 ***********************************************/
//			makeMusicList(MY_MUSIC);
			
			super.init();
		}	
		
		override public function run():void
		{
			/***************************************
			 * access the resource from a Swf file
			 ***************************************/
			accessSWF();
			
			/***************************************
			 * access the resource from a text file
			 ***************************************/
//			accessTxt();
			
			/***************************************
			 * access the resource from a mp3 file
			 ***************************************/
//			accessMusic();

			
//			var timer:Timer = new Timer(1500, 1);	
//			timer.addEventListener(TimerEvent.TIMER_COMPLETE, timerHandler, false, 0, true);	//removed in timerHandler
//			
//			timer.start();
			

		}
		
		override public function destroy():void
		{
			//-----make sure performing folllowing tasks before calling the parent's destory().------------------------
			//Unregister all event listners (particularly Event.ENTER_FRAME, and mouse and keyboard listener).
			//Stop any currently running intervals (via clearInterval()).
			//Stop any Timer objects(via the Time's class instance method stop()).
			//Stop any sounds from playing.
			//Stop the main timeline if it's currently playing.
			//Stop any movie clips that are currently playing.
			//Close any connected nework object, such as an instances of Loader, URLLoader, Socket, XMLSocket, LocalConnection, NetConnection, and NetStream
			//Nullify all references to Camera or Microphone.
			//--------------------------------------------------------------------------------------------------------
			
			super.destroy();
		}

		override public function switchTo(targetScene:IScene):void
		{
			super.switchTo(targetScene);
		}
		
		override public function accessSWF():void
		{
			var viewSwf:MovieClip = _resManager.get("TelnetSocket_View.swf") as MovieClip;
			_telnetSocket = new TelnetSocket(viewSwf);
			
			addToContextView(viewSwf);
		}	

		override public function accessTxt():void
		{
//			var textField	:TextField			= new TextField();
//			textField.text = Toolkits.parsingTxt( _resManager.get("example.txt") as String );
//			
//			textField.x = 200;
//			textField.y = 100;
//			
//			addToContextView(textField);
		}	
		
		override public function accessMusic():void
		{
//			var _sound:Sound	= _resManager.get("sceneA.mp3") as Sound;
//			
//			_soundManager.registerSound(3, _sound);
//			_soundManager.playSound(3);
		}	
		
		
		private function timerHandler(event:TimerEvent):void
		{
			var timer:Timer = event.target as Timer;
			timer.stop();
			timer.removeEventListener(TimerEvent.TIMER_COMPLETE, timerHandler);
			
			clearContextView();
			
			switchTo( IScene(_sceneManager.get("SceneB")) );
		}
	}
}