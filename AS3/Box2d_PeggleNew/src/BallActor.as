package
{
	import Box2D.Collision.Shapes.b2CircleShape;
	import Box2D.Common.Math.b2Vec2;
	import Box2D.Dynamics.b2Body;
	import Box2D.Dynamics.b2BodyDef;
	import Box2D.Dynamics.b2Fixture;
	import Box2D.Dynamics.b2FixtureDef;
	import Box2D.Dynamics.b2World;
	
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.Sprite;
	import flash.geom.Point;

	public class BallActor extends Actor
	{
		private const DIAMETER		:int		= 12;	 
		
		public function BallActor(parent:DisplayObjectContainer, iniLocation:Point, iniVelocity:Point)
		{
			var ballSprite		:Sprite = new BallSprite();
			ballSprite.scaleX	= DIAMETER / ballSprite.width;
			ballSprite.scaleY	= DIAMETER / ballSprite.height;
			parent.addChild(ballSprite);
			
			var world			:b2World			= PhysicVars.instance.world;
			var ballShape		:b2CircleShape		= new b2CircleShape();
			var fixtureDef		:b2FixtureDef		= new b2FixtureDef();
			var ballBodyDef		:b2BodyDef			= new b2BodyDef();
			var ballBody		:b2Body;
			
			ballShape.SetRadius( ( DIAMETER >> 1 ) / PhysicVars.PIXEL_TO_METER );
			fixtureDef.density = 1.5;
			fixtureDef.friction = 0.0;
			fixtureDef.restitution = 0.45;
			fixtureDef.shape = ballShape;
			
			ballBodyDef.position.Set(iniLocation.x / PhysicVars.PIXEL_TO_METER, iniLocation.y / PhysicVars.PIXEL_TO_METER);
			ballBodyDef.type = b2Body.b2_dynamicBody;
			ballBodyDef.bullet = true;
			
			ballBody = world.CreateBody(ballBodyDef);
			ballBody.CreateFixture(fixtureDef);
			ballBody.SetLinearVelocity( new b2Vec2(iniVelocity.x / PhysicVars.PIXEL_TO_METER, iniVelocity.y / PhysicVars.PIXEL_TO_METER));
			
			super(parent, ballBody, ballSprite);
		}
		
		public function hitBonusChute():void
		{
			dispatchEvent(new BallEvent(BallEvent.BALL_HIT_BONUS));
		}	
		
		
		override protected function updateSpecificChild():void
		{
			super.updateSpecificChild();
			
			if(_constume.y > _constume.stage.stageHeight)
			{
				dispatchEvent(new BallEvent(BallEvent.BALL_OFF_SCREEN));
			}
		
			
		}
		
	}
}