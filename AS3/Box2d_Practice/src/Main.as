package {
	import Box2D.Collision.*;
	import Box2D.Collision.Shapes.*;
	import Box2D.Common.Math.*;
	import Box2D.Dynamics.*;
	import Box2D.Dynamics.Joints.*;
	
	import flash.display.*;
	import flash.events.Event;
	import flash.utils.getTimer;
	
	[SWF(width="1012", height="705", frameRate="30", backgroundColor="#FFFFFF")]
	public class Main extends Sprite {
		
		public static const PIXEL_TO_METER:Number = 30;
		
		private var _world			:b2World;
		private var _shape			:Shape;
		
		private var _delayForNextCraftIn:int;
		
		public function Main():void {
			
			_shape = new Shape();
			this.addChild(_shape);
			
			//			var car:Car = new Car(this);
			//			addChild(car);
			
			_delayForNextCraftIn = 0;
			
			setupWorld();
			
			createWallandFloor();
			
			setupDebugDraw();
			
			addEventListener(Event.ENTER_FRAME, update);
		}
		
		private function setupDebugDraw():void
		{
			var fallingCrateSprite		:Sprite = new Sprite();
			
			this.addChild(fallingCrateSprite);
			
			var debugDrawer:b2DebugDraw = new b2DebugDraw();
			debugDrawer.SetSprite(fallingCrateSprite);
			debugDrawer.SetDrawScale(PIXEL_TO_METER);
			debugDrawer.SetFlags(b2DebugDraw.e_centerOfMassBit);
//			debugDrawer.AppendFlags(b2DebugDraw.e_pairBit);
			debugDrawer.AppendFlags(b2DebugDraw.e_aabbBit);
//			debugDrawer.AppendFlags(b2DebugDraw.e_controllerBit);
			debugDrawer.AppendFlags(b2DebugDraw.e_shapeBit);
			
			debugDrawer.SetLineThickness(2);
			debugDrawer.SetFillAlpha(0.6);
//			debugDrawer.SetFlags(1);
			_world.SetDebugDraw(debugDrawer);
		}
		
		
		private function update(event:Event):void
		{
var start:Number = getTimer();		
			_world.Step( 1 / stage.frameRate, 10, 10);
var elapse:Number = getTimer() - start;
trace("elapse:",elapse,"ms");
			if(_delayForNextCraftIn-- <= 0 && _world.GetBodyCount() < 20){
				addRandomCrate();
				_delayForNextCraftIn = 5;
				
				_shape.graphics.clear();
				_shape.graphics.lineStyle(randomInt(10, 20), 0x33bbff, randomInt(0.1, 1), false, LineScaleMode.NORMAL, CapsStyle.ROUND, JointStyle.ROUND, 1 );
				_shape.graphics.moveTo(650,100);
				_shape.graphics.lineTo(randomInt(670, 800),randomInt(55, 100));
				_shape.graphics.lineTo(700, 120);
				_shape.graphics.curveTo(randomInt(200, 450), randomInt(200, 500), 900, 500);
				
			}else if (_world.GetBodyCount() >= 80){
				removeEventListener(Event.ENTER_FRAME, update);
			}
			
			_world.DrawDebugData();
			_world.ClearForces();
		}
		
		//Returns a number in the range of lowVal to highVal, inclusive
		private function randomInt(lowVal:int, highVal:int):int
		{
			if(lowVal <= highVal)
			{
				return lowVal + Math.floor(Math.random() * (highVal - lowVal + 1)); 
			}else{
				throw new Error("OOPs, lowVal can't not less than or equal to highVal");
			}
		}
		
		private function addRandomCrate():void
		{
			var fixtureDef			:b2FixtureDef	= new b2FixtureDef();
			
			var fallingCrateShape	:b2PolygonShape	= new b2PolygonShape();
			var fallingCrateBodyDef	:b2BodyDef		= new b2BodyDef();
			//			var fallingCrateBody	:b2Body;
			
			fallingCrateShape.SetAsBox( randomInt(5, 40) / PIXEL_TO_METER, randomInt(5, 40) / PIXEL_TO_METER);
			fallingCrateBodyDef.position.Set( randomInt(15, 530) / PIXEL_TO_METER, randomInt(-100, -10) / PIXEL_TO_METER);
			fallingCrateBodyDef.angle = randomInt(0, 360) * Math.PI / 180;
			fallingCrateBodyDef.type = b2Body.b2_dynamicBody;
			
			var fallingCrateBody	:b2Body  = _world.CreateBody(fallingCrateBodyDef);
			
			fixtureDef.shape 			= fallingCrateShape;
			fixtureDef.friction 		= 0.8;
			fixtureDef.density 			= 0.7;
			fixtureDef.restitution 		= 0.3;
			
			
			fallingCrateBody.CreateFixture(fixtureDef);
			
		}
		
		
		private function createWallandFloor():void
		{
			var fixtureDef		:b2FixtureDef	= new b2FixtureDef();
			
			//floor	
			var floorShape		:b2PolygonShape = new b2PolygonShape();
			var floorBodyDef	:b2BodyDef		= new b2BodyDef();
			var floorBody		:b2Body;
			
			floorShape.SetAsBox(20, 1);
			floorBodyDef.position.Set( 0 / PIXEL_TO_METER, 600 / PIXEL_TO_METER);
			floorBody = _world.CreateBody(floorBodyDef);
			
			fixtureDef.shape 		= floorShape;
			fixtureDef.friction 	= 0.5;
			fixtureDef.density 		= 0.0;
			fixtureDef.restitution	= 0.3;
			
			floorBody.CreateFixture(fixtureDef);
			
			
			//wall
			var wallShape		:b2PolygonShape = new b2PolygonShape();
			var wallBodyDef		:b2BodyDef		= new b2BodyDef();
			var leftWallBody	:b2Body;
			var rightWallBody	:b2Body;
			
			var vertexes		:Vector.<b2Vec2>;
			
			vertexes = new Vector.<b2Vec2>();
			vertexes[0] = new b2Vec2(0 / PIXEL_TO_METER, 0 / PIXEL_TO_METER);
			vertexes[1] = new b2Vec2(20 / PIXEL_TO_METER, 0 / PIXEL_TO_METER);
			vertexes[2] = new b2Vec2(20 / PIXEL_TO_METER, 600 / PIXEL_TO_METER);
			vertexes[3] = new b2Vec2(0 / PIXEL_TO_METER, 600 / PIXEL_TO_METER);
			
			wallShape.SetAsVector(vertexes);
			
			fixtureDef.shape 		= wallShape;
			fixtureDef.friction 	= 0.5;
			fixtureDef.density 		= 0.0;
			fixtureDef.restitution	= 0.3;
			
			
			//left wall			
			wallBodyDef.position.Set(0 / PIXEL_TO_METER, 0 / PIXEL_TO_METER);
			leftWallBody = _world.CreateBody(wallBodyDef);
			leftWallBody.CreateFixture(fixtureDef);
			
			//right wall
			wallBodyDef.position.Set(600 / PIXEL_TO_METER, 0 / PIXEL_TO_METER);
			rightWallBody = _world.CreateBody(wallBodyDef);
			rightWallBody.CreateFixture(fixtureDef);
			
		}
		
		private function setupWorld():void
		{
			var gravity				:b2Vec2 = new b2Vec2(0, 9.8);
			var ignoringSleeping	:Boolean = true;
			
			_world = new b2World(gravity, ignoringSleeping);
			
			trace("The world has " + _world.GetBodyCount() + " bodys");
		}
		
		
	}	
}
