package 
{
	import flash.display.*;
	import flash.events.MouseEvent;
	import flash.media.Sound;
	
	import org.robotlegs.mvcs.Actor;

	import com.igs.acd2.gameFramework.CoreContext;
	import com.igs.acd2.gameFramework.model.scene.BaseScene;
	import com.igs.acd2.gameFramework.model.scene.IScene;

	
	public class SceneB extends BaseScene
	{

		private const MY_SWF		:Array = ["Grid_Prize.swf"];
		private const MY_TXT		:Array = [];
		private const MY_MUSIC		:Array = ["sceneB.mp3"];
		
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
		
		override public function init():void
		{
			/***********************************************
			 * make a resource list for loading "SWF" files 
			 ***********************************************/
			makeSwfList(MY_SWF);
			
			/***********************************************
			 * make a resource list for loading "Text" files 
			 ***********************************************/
			makeTxtList(MY_TXT);
			
			/***********************************************
			 * make a resource list for loading "MP3" files 
			 ***********************************************/
			makeMusicList(MY_MUSIC);
			
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
			accessTxt();
			
			/***************************************
			 * access the resource from a mp3 file
			 ***************************************/
			accessMusic();
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
			var gridSwf:MovieClip = _resManager.get("Grid_Prize.swf") as MovieClip;
			var poker_btn:SimpleButton = gridSwf.getChildByName("gridPrize_btn") as SimpleButton;
			
			poker_btn.visible = true;
			poker_btn.x = 150;
			poker_btn.y = 300;
			
			poker_btn.addEventListener(MouseEvent.CLICK, readyToSwitch);
			
			addToContextView(poker_btn);
		}	
		
		override public function accessTxt():void
		{

		}	
		
		override public function accessMusic():void
		{
			var _sound:Sound	= _resManager.get("sceneB.mp3") as Sound;
			
			_soundManager.registerSound(3, _sound);
			_soundManager.playSound(3);
		}	
		
		
		private function readyToSwitch(event:MouseEvent):void
		{
			var target:SimpleButton = event.target as SimpleButton;
			target.removeEventListener(MouseEvent.CLICK, readyToSwitch);
			
			clearContextView();
			switchTo( IScene(_sceneManager.get("SceneA")) );
		}	
	}
}