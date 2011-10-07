package
{
	import Box2D.Dynamics.b2Body;
	
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.geom.Point;
	
	public class Actor extends EventDispatcher
	{
		protected var _body			:b2Body;
		protected var _constume		:DisplayObject;
		protected var _parent		:DisplayObjectContainer;
		
		public function Actor(parent:DisplayObjectContainer, body:b2Body, constume:DisplayObject)
		{
			super();
			_parent		= parent;
			_body		= body;
			_body.SetUserData(this);
			_constume	= constume;
			
			updateConstume();
			
		}
		
		public function update():void
		{
			if(_body.GetType() != b2Body.b2_staticBody){
				updateConstume();
			}
			
			updateSpecificChild();
		}
		
		public function destory():void
		{
			cleanUpBeforeRemoving();
			_parent.removeChild(_constume);
			PhysicVars.instance.world.DestroyBody(_body);
			
		}
		
		public function getSpritePosition():Point
		{
			return new Point( _constume.x, _constume.y );
		}
		
		
		protected function cleanUpBeforeRemoving():void
		{
			//override by subclasses.
		}
		
		protected function updateSpecificChild():void
		{
			//override by subclasses. 
		}
		
		private function updateConstume():void
		{
			_constume.x			= _body.GetPosition().x * PhysicVars.PIXEL_TO_METER;
			_constume.y			= _body.GetPosition().y * PhysicVars.PIXEL_TO_METER;
			_constume.rotation	= _body.GetAngle() * 180 / Math.PI;
		}
		
	}
}