package
{
	import Box2D.Collision.Shapes.*;
	import Box2D.Common.Math.b2Vec2;
	import Box2D.Dynamics.*;
	
	import flash.display.*;
	import flash.geom.Point;
	
	public class ArbitraryStaticActor extends Actor
	{
		public function ArbitraryStaticActor(parent:DisplayObjectContainer, iniLocation:Point, polygons:Vector.<b2PolygonShape>)
		{
			var body		:b2Body = createBody(iniLocation, polygons);
			var constume	:Sprite = createSprite(parent, iniLocation, polygons);
			
			parent.addChild(constume);
			
			super(parent, body, constume);
		}
		
		
		private function createSprite(parent:DisplayObjectContainer, iniLocation:Point, polygons:Vector.<b2PolygonShape>):Sprite
		{
			var newSprite:Sprite = new Sprite();
			newSprite.graphics.lineStyle(1, 0x00BB00);
			
//			var numShape	:int;
			var vertexes	:Vector.<b2Vec2>;
			var firstVertex	:b2Vec2;
			var lastVertex	:b2Vec2 = null;
			
			
			for each(var polygonShape:b2PolygonShape in polygons)
			{
//				numShape = polygonShape.GetVertexCount();
				vertexes = polygonShape.GetVertices();
				firstVertex = vertexes[0];	
			
				newSprite.graphics.moveTo(	firstVertex.x * PhysicVars.PIXEL_TO_METER, 
											firstVertex.y * PhysicVars.PIXEL_TO_METER);
				newSprite.graphics.beginFill(0x00BB00);
				
				for each (var vertex:b2Vec2 in vertexes)
				{
					if(lastVertex != null){

						newSprite.graphics.lineTo(	vertex.x * PhysicVars.PIXEL_TO_METER, 
													vertex.y * PhysicVars.PIXEL_TO_METER);
					}
					lastVertex = vertex;
				}
				
				if(firstVertex != lastVertex){
					newSprite.graphics.lineTo(	firstVertex.x * PhysicVars.PIXEL_TO_METER,
												firstVertex.y * PhysicVars.PIXEL_TO_METER);
				}
				
				newSprite.graphics.endFill();

			}
			
			newSprite.x = iniLocation.x;
			newSprite.y = iniLocation.y;
			
			return newSprite;
		}
			
		
		private function createBody(iniLocation:Point, polygons:Vector.<b2PolygonShape>):b2Body
		{
			var fixtureDef			:b2FixtureDef	= new b2FixtureDef();
			var bodyDef				:b2BodyDef		= new b2BodyDef();
			var body				:b2Body;
			
			bodyDef.position.Set(iniLocation.x / PhysicVars.PIXEL_TO_METER, iniLocation.y / PhysicVars.PIXEL_TO_METER);
			bodyDef.type = b2Body.b2_staticBody;
			body = PhysicVars.instance.world.CreateBody(bodyDef);
			
			for each (var polygonShape:b2PolygonShape in polygons)
			{
				fixtureDef.shape 			= polygonShape;
				fixtureDef.density 			= 0.3;
				fixtureDef.friction 		= 0.2;
				fixtureDef.restitution 		= 0.3;
				body.CreateFixture(fixtureDef);
			}
			
			return body;
		
		}	
		
		
	}
}