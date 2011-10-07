package mySocket 
{
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import flash.utils.ByteArray;
	
//	import socket.Telnet;
	
	public class TelnetSocket extends Sprite 
	{
        private var _telnetClient:Telnet;

		private var _swf				:MovieClip;
		
		private var _portNumber_txt		:TextField;
		private var _serverName_txt		:TextField;		
		private var _response_txt		:TextField;
		private var _command_txt		:TextField;
		private var _connect_mc			:MovieClip;
		private var _send_mc			:MovieClip;
		
		
		public function TelnetSocket(swf:MovieClip) {
			_swf = swf;
			setupUI();
		}
		
		private function connect(e:MouseEvent):void {
			_telnetClient = new Telnet(_serverName_txt.text, int(_portNumber_txt.text), _response_txt);
		}
		private function sendCommand(e:MouseEvent):void {
			var ba:ByteArray = new ByteArray();
			ba.writeMultiByte(_command_txt.text + "\n", "UTF-8");
//			telnetClient.writeBytesToSocket(ba);
			_command_txt.text = "";
		}
		private function setupUI():void {
			
			_portNumber_txt	= _swf.getChildByName("portNumber_txt") as TextField;
			_serverName_txt = _swf.getChildByName("serverName_txt") as TextField;
			_response_txt	= _swf.getChildByName("response_txt") as TextField;
			_command_txt	= _swf.getChildByName("command_txt") as TextField;
			_connect_mc		= _swf.getChildByName("connect_mc") as MovieClip;
			_send_mc		= _swf.getChildByName("send_mc") as MovieClip;
			
			_connect_mc.buttonMode = true;
			_send_mc.buttonMode = true;
			
			
			_connect_mc.addEventListener(MouseEvent.CLICK, connect)	
			_send_mc.addEventListener(MouseEvent.CLICK, sendCommand);
		}		
	}
}