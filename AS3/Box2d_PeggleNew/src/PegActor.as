package
{
	import Box2D.Collision.Shapes.b2CircleShape;
	import Box2D.Collision.Shapes.b2Shape;
	import Box2D.Common.Math.b2Vec2;
	import Box2D.Dynamics.b2Body;
	import Box2D.Dynamics.b2BodyDef;
	import Box2D.Dynamics.b2Fixture;
	import Box2D.Dynamics.b2FixtureDef;
	import Box2D.Dynamics.b2World;
	
	import com.greensock.TweenLite;
	
	import flash.display.*;
	import flash.geom.Point;
	
	public class PegActor extends Actor
	{
		public static const STATE_NORMAL	:int	= 1;
		public static const STATE_GOAL		:int	= 2;
		
		public static const DIAMETER		:int	= 19;
		
		private var _beenHit					:Boolean;
		private var _type						:int;
		private var _turnNormalWhenSafe			:Boolean;
//		private var _ballVel					:b2Vec2;
		private var _ballForceToApply			:b2Vec2;
		
		public function PegActor(parent:DisplayObjectContainer, iniLocation:Point, type:int)
		{
			_beenHit			= false;
			_turnNormalWhenSafe	= false;
			
			_type = type;
			
			var peg_mc:MovieClip = new PegSprite();
			
			peg_mc.scaleX = DIAMETER / peg_mc.width;
			peg_mc.scaleY = DIAMETER / peg_mc.height;
			parent.addChild(peg_mc);
			
			var world			:b2World			= PhysicVars.instance.world;
			var pegShape		:b2CircleShape		= new b2CircleShape();
			var fixtureDef		:b2FixtureDef		= new b2FixtureDef();
			var pegBodyDef		:b2BodyDef			= new b2BodyDef();
			var pegBody			:b2Body;			
			
			pegShape.SetRadius( (DIAMETER >> 1) / PhysicVars.PIXEL_TO_METER );
			fixtureDef.density		= 0;
			fixtureDef.friction		= 0;
			fixtureDef.restitution	= 0.45;
			fixtureDef.shape		= pegShape;
			
			pegBodyDef.position.Set(iniLocation.x / PhysicVars.PIXEL_TO_METER, iniLocation.y / PhysicVars.PIXEL_TO_METER );
			pegBodyDef.type = b2Body.b2_staticBody;
			
			pegBody = world.CreateBody(pegBodyDef);
			pegBody.CreateFixture(fixtureDef);
			
			super(parent, pegBody, peg_mc);
			
			updateState();
			
		}
		
		override protected function updateSpecificChild():void
		{
			if(_turnNormalWhenSafe == true)
			{
				_turnNormalWhenSafe = false;
				turnToNormal();
			}
		
		}
		
		
		public function hitByBall():void
		{
			if(!_beenHit){
				_beenHit = true;
				updateState();
				
				dispatchEvent(new PegEvent(PegEvent.LIT_UP));
				
				_turnNormalWhenSafe = true;
				
//				turnToNormal();
			}
		}
		
		public function setCollisionInfo(ballVel:b2Vec2, ballMass:Number, collisionNormal:b2Vec2):void
		{
//			_ballForceToApply = ballVel.Copy();
			
			//force = m * a;
			_ballForceToApply = collisionNormal.Copy();
			_ballForceToApply.Multiply(ballVel.Length());
			_ballForceToApply.Multiply(ballMass);
			
			//caculate the magnitude of the normal componet of the ball velocity.
			var dotProduct	:Number = ( ballVel.x * collisionNormal.x ) + (ballVel.y * collisionNormal.y );
			var cosTheta	:Number = dotProduct / ( ballVel.Length() * collisionNormal.Length()); 
			
			_ballForceToApply.Multiply(cosTheta);
			
		}
		
		private function turnToNormal():void
		{	
			for (var shape:b2Fixture = _body.GetFixtureList(); shape != null; shape = shape.GetNext())
			{
				shape.SetDensity(1.0);
				_body.SetType(b2Body.b2_dynamicBody);
			}
			
			_body.ApplyImpulse(_ballForceToApply, _body.GetWorldCenter());
//			_body.SetLinearVelocity(_ballVel);
//			_body.SetAwake(true);
			
			
		}
		
		private function updateState():void
		{
			var constume_mc	:MovieClip = _constume as MovieClip;
			
			switch(_type){
				
				case STATE_NORMAL:
					
					if(_beenHit){
						constume_mc.gotoAndStop(2);
					}else{
						constume_mc.gotoAndStop(1);
					}
					
					break;
				
				case STATE_GOAL:
					
					if(_beenHit){
						constume_mc.gotoAndStop(4);	
					}else{
						constume_mc.gotoAndStop(3);
					}
					
					break;
				
				default:
					throw new Error("a state error in PegActor");
			}
		
		}
		
		public function fadeOut(pegNumber:int):void
		{
			TweenLite.to(_constume, 0.3, {alpha:0, delay: 0.08 * pegNumber, onComplete: destory} );
		}
		
		public function informDoneFadingOut():void
		{
			dispatchEvent( new PegEvent(PegEvent.DONE_FADING_OUT));
		}
		
		
		public function set type( type:int ):void
		{
			_type = type;
			updateState();
		}
	}
}