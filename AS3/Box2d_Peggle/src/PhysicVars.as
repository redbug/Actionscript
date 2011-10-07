package
{
	import Box2D.Common.Math.b2Vec2;
	import Box2D.Dynamics.b2World;

	public class PhysicVars
	{
		private static var _instance	:PhysicVars;				//singleton
		
		public static const PIXEL_TO_METER		:Number = 30;
		public static const GRAVITY_IN_METER	:Number = 9.8;
		
		private var _world			:b2World;
		private var _gravity		:b2Vec2;
		private var _allowSleeping	:Boolean;
		
		
		public function PhysicVars(enforcer:SingletonEnforcer)
		{
			_gravity 		= new b2Vec2(0, GRAVITY_IN_METER);
			_allowSleeping 	= true;
			_world = new b2World(_gravity, _allowSleeping);
		}
		
		public static function get instance():PhysicVars
		{
			if(_instance == null)
			{
				_instance = new PhysicVars(new SingletonEnforcer());
			}
			
			return _instance;
		}		
		
		public function get world():b2World
		{
			return _world;
		}

		public function set world(value:b2World):void
		{
			_world = value;
		}

	}
}

class SingletonEnforcer{}