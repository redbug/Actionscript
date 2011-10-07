package
{
	import Box2D.Collision.Shapes.b2PolygonShape;
	import Box2D.Common.Math.b2Vec2;
	import Box2D.Dynamics.b2Body;
	import Box2D.Dynamics.b2BodyDef;
	import Box2D.Dynamics.b2FixtureDef;
	import Box2D.Dynamics.b2World;
	
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.Sprite;
	
	public class BonusChuteActor extends Actor
	{
		public static const BONUS_TARGET	:String	= "BonusTarget";
		public static const TRAVEL_SPEED	:int	= 2;
		
		
		private var _bounds		:Array;
		private var _yPos		:int;
		private var _direction	:int;		//positve: move right; negative: move left
		
		
		public function BonusChuteActor(parent:DisplayObjectContainer, leftBounds:int, rightBounds:int, yPos:int)
		{
			_bounds = [leftBounds, rightBounds];
			_yPos = yPos;
			_direction = 1;
			
			var sprite:Sprite = new BonusChuteSprite();
			parent.addChild(sprite);
			
			
			var vertexes		:Vector.<b2Vec2>;
			var polygonShape	:b2PolygonShape; 
			
			//left ramp shape
			polygonShape = new b2PolygonShape();
			var leftRampFixture	:b2FixtureDef		= new b2FixtureDef();
			
			vertexes = Vector.<b2Vec2>([	new b2Vec2(-74 / PhysicVars.PIXEL_TO_METER,			9 / PhysicVars.PIXEL_TO_METER), 
											new b2Vec2(-60 / PhysicVars.PIXEL_TO_METER,			-6 / PhysicVars.PIXEL_TO_METER), 
											new b2Vec2(-60 / PhysicVars.PIXEL_TO_METER,			9 / PhysicVars.PIXEL_TO_METER)]);
			
			polygonShape.SetAsVector( vertexes, vertexes.length );
			
			leftRampFixture.shape		= polygonShape;
			leftRampFixture.friction	= 0.1;
			leftRampFixture.restitution	= 0.6;
			leftRampFixture.density		= 1;
			
			
			
			//right ramp shape
			polygonShape = new b2PolygonShape();
			var rightRampFixture	:b2FixtureDef		= new b2FixtureDef();
			
			vertexes = Vector.<b2Vec2>([	new b2Vec2(58 / PhysicVars.PIXEL_TO_METER,			-6 / PhysicVars.PIXEL_TO_METER), 
											new b2Vec2(72 / PhysicVars.PIXEL_TO_METER,			9 / PhysicVars.PIXEL_TO_METER), 
											new b2Vec2(58 / PhysicVars.PIXEL_TO_METER,			9 / PhysicVars.PIXEL_TO_METER)]);

			polygonShape.SetAsVector( vertexes, vertexes.length );
			
			rightRampFixture.shape			= polygonShape;
			rightRampFixture.friction		= 0.1;
			rightRampFixture.restitution	= 0.6;
			rightRampFixture.density		= 1;
			

			
			
			//centerRectangle shape
			polygonShape = new b2PolygonShape();
			var centerRectangleFixture	:b2FixtureDef	= new b2FixtureDef();
			
			vertexes = Vector.<b2Vec2>([	new b2Vec2(-60 / PhysicVars.PIXEL_TO_METER,			-6 / PhysicVars.PIXEL_TO_METER), 
											new b2Vec2(58 / PhysicVars.PIXEL_TO_METER,			-6 / PhysicVars.PIXEL_TO_METER), 
											new b2Vec2(58 / PhysicVars.PIXEL_TO_METER,			9 / PhysicVars.PIXEL_TO_METER),
											new b2Vec2(-60 / PhysicVars.PIXEL_TO_METER,			9 / PhysicVars.PIXEL_TO_METER)]);
			
			polygonShape.SetAsVector( vertexes );
			
			centerRectangleFixture.shape			= polygonShape;
			centerRectangleFixture.friction			= 0.1;
			centerRectangleFixture.restitution		= 0.6;
			centerRectangleFixture.density			= 1;
			centerRectangleFixture.isSensor			= true;
			centerRectangleFixture.userData			= BONUS_TARGET;
			
			var body		:b2Body;
			var bodyDef		:b2BodyDef		= new b2BodyDef();
			var world		:b2World 		= PhysicVars.instance.world;
			
			bodyDef.position.Set(	((leftBounds + rightBounds) >> 1) 	/ PhysicVars.PIXEL_TO_METER, 
									yPos								/ PhysicVars.PIXEL_TO_METER);
	
			bodyDef.type = b2Body.b2_dynamicBody;
			bodyDef.fixedRotation = true;
			
			body = world.CreateBody(bodyDef);
			
			body.CreateFixture(leftRampFixture);
			body.CreateFixture(rightRampFixture);
			body.CreateFixture(centerRectangleFixture);
			
			
			// anti-gravity
			var gravityOffset:b2Vec2 = world.GetGravity().Copy();
			gravityOffset.Multiply( - 1 * body.GetMass() );
			
			body.ApplyForce( gravityOffset, body.GetWorldCenter());
			
			super(parent, body, sprite);
		}
		
		override protected function updateSpecificChild():void
		{
			if(_constume.x >= _bounds[1]){
				_direction = -1;
			}
			else if(_constume.x <= _bounds[0]){
				_direction = 1;
			}
			
			_body.SetLinearVelocity(new b2Vec2( _direction * 2, 0));
			
			super.updateSpecificChild();
			
		}	
		
	}
}