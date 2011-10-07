package
{
	import Box2D.Collision.Shapes.b2CircleShape;
	import Box2D.Collision.Shapes.b2PolygonShape;
	import Box2D.Common.Math.b2Vec2;
	import Box2D.Dynamics.b2Body;
	import Box2D.Dynamics.b2BodyDef;
	import Box2D.Dynamics.b2FixtureDef;
	import Box2D.Dynamics.b2World;
	
	import br.com.stimuli.loading.BulkLoader;
	
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	
	[SWF(width="800", height="600", frameRate="30", backgroundColor="#FFFFCC")]
	public class PeggleNew extends Sprite
	{
		private const SHOOTER_POINT		:Point	= new Point(stage.stageWidth * 0.5, 10);
		private const LAUNCH_SPEED		:Number	= 400; 
		private const NUM_GOAL_PEGS		:int = 1;
		
		
		private var _world			:b2World;
		private var _camera			:MyCamera
		private var _bulkLoader		:BulkLoader;
		private var _timeMaster		:TimeMaster;
		private var _director		:Director;
		private var _aimingLine		:AimingLine;
		private var _shooter		:Shooter;
		
		private var _actors			:Vector.<Actor>;
		private var _actorsToRemove	:Vector.<Actor>;
		private var _pegsLitUp		:Vector.<Actor>;
		private var _goalPegs		:Vector.<Actor>;
		
		private var _currentBall	:BallActor;
		
		
		public function PeggleNew()
		{
			_world 			= PhysicVars.instance.world;
			_camera			= new MyCamera();
			_timeMaster		= new TimeMaster(stage.frameRate);
			_director		= new Director(_camera, _timeMaster);
			_aimingLine		= new AimingLine(PhysicVars.GRAVITY_IN_METER);
			
			this.addChild(_camera);
			_camera.addChild(_aimingLine);
			_aimingLine.showLine(new Point(250, 30), new Point(-3, 2), LAUNCH_SPEED); 
			
			//			_camera.zoomTo(new Point(this.stage.stageWidth >> 1, this.stage.stageHeight >> 1));
			
			_actors			= new Vector.<Actor>();
			_actorsToRemove = new Vector.<Actor>();
			_pegsLitUp		= new Vector.<Actor>();
			_goalPegs		= new Vector.<Actor>();
			
			_bulkLoader = new BulkLoader("sceneLoader");
			_bulkLoader.add("Peggle_View.swf");
			_bulkLoader.addEventListener(BulkLoader.COMPLETE, onAllItemsLoaded);	
			
			_bulkLoader.start();
			
		}
		
		public function reallyRemoveActors():void
		{
			for each (var actor:Actor in _actorsToRemove)
			{
				actor.destory();
				
				var index:int = _actors.indexOf(actor);
				
				if(_actors.indexOf(actor) != -1)
				{
					_actors.splice(index, 1);
				}
			}
			
			_actorsToRemove = new Vector.<Actor>();
			
		}
		
		public function safelyRemoveActors(actorToRemove:Actor):void
		{
			if(_actorsToRemove.indexOf(actorToRemove) == -1)
			{
				_actorsToRemove.push(actorToRemove);
			}
		}
		
		
		private function onAllItemsLoaded(evt:Event) : void{
			//			makeBall();
			makePegs();
			makeWalls();
			makeRamps();
			makeBonusChute();
			makeShooter();
			
			_world.SetContactListener(new PeggleContactListener);
			addEventListener(Event.ENTER_FRAME, update);
			
			stage.addEventListener(MouseEvent.CLICK, launchBall);
			stage.addEventListener(MouseEvent.MOUSE_MOVE, showAimline);
			
		}
		
		private function ballOffScreenHandler(event:BallEvent):void
		{
			trace("Ball is off screen");
			
			var ballToRemove	:BallActor = event.target as BallActor;
			
			ballToRemove.removeEventListener(BallEvent.BALL_OFF_SCREEN, ballOffScreenHandler);
			safelyRemoveActors(ballToRemove);
			
			_currentBall = null;
			
			//			for each (var peg:PegActor in _pegsLitUp){
			for (var i:int = 0; i < _pegsLitUp.length; ++i){
				var pegToRemove:PegActor = _pegsLitUp[i] as PegActor;
				pegToRemove.fadeOut(i);
				//				safelyRemoveActors(peg);
				//				peg.fadeOut();
			}
			
			_pegsLitUp = new Vector.<Actor>();
			
			showAimline();
		}
		
		private function ballHitBonusChuteHandler(event:BallEvent):void
		{
			trace("Ball is hit the bonus chute");
			
			var ballToRemove	:BallActor = event.target as BallActor;
			ballToRemove.removeEventListener(BallEvent.BALL_HIT_BONUS, ballHitBonusChuteHandler);
			
			ballOffScreenHandler(event);
		}
		
		private function pegLitUpHandler(event:PegEvent):void
		{
			var peg:PegActor = event.target as PegActor;
			peg.removeEventListener(PegEvent.LIT_UP, pegLitUpHandler);
			
			if( _pegsLitUp.indexOf(peg) == -1){
				_pegsLitUp.push( peg );
			}	
			
			
			var goalPegIndex:int = _goalPegs.indexOf(peg); 
			if( goalPegIndex != -1)
			{
				_goalPegs.splice(goalPegIndex, 1);
			}
			
		}
		
		private function launchBall(event:MouseEvent):void
		{
			if(_currentBall == null)
			{
				var launchPoint:Point = _shooter.getLaunchPosition();
				var velocity:Point = new Point(mouseX, mouseY).subtract(launchPoint);
				velocity.normalize(LAUNCH_SPEED);	// unit vector * speed = velocity
				
				var ball:BallActor;
				ball = new BallActor(_camera, launchPoint, velocity); 
				ball.addEventListener(BallEvent.BALL_OFF_SCREEN, ballOffScreenHandler);
				ball.addEventListener(BallEvent.BALL_HIT_BONUS, ballHitBonusChuteHandler);
				_actors.push(ball);
				
				_currentBall = ball;
				_aimingLine.hide();
			}
			
		}	
		
		
		private function makeBall():void
		{
			var ball:BallActor;
			
			for(var i:int = 0; i < 2; ++i){
				ball = new BallActor(_camera, new Point(-100 + Math.random() * 600), new Point(50 + Math.random() * 150, -100 - Math.random() * 100));
				ball.addEventListener(BallEvent.BALL_OFF_SCREEN, ballOffScreenHandler);
				_actors.push( ball );
			}
		}		
		
		private function makePegs():void
		{
			var horizontalSpace	:int		= 40;
			var verticalSpace	:int		= 50;
			var isIndent		:Boolean	= false;
			var boundries		:Rectangle	= new Rectangle(100, 100, 600, 300);
			
			var startX			:int;
			
			var peg			:PegActor;
			var pegs		:Vector.<Actor> = new Vector.<Actor>();
			
			for(var pegY:int = boundries.top; pegY < boundries.bottom; pegY += verticalSpace){
				
				startX = (isIndent)? 15: 0;
				isIndent = !isIndent;
				
				for(var pegX:int = boundries.left + startX; pegX < boundries.right; pegX += horizontalSpace){
					peg = new PegActor(_camera, new Point(pegX, pegY), PegActor.STATE_NORMAL);
					peg.addEventListener(PegEvent.LIT_UP, pegLitUpHandler);
					peg.addEventListener(PegEvent.DONE_FADING_OUT, destroyPegNow);
					_actors.push( peg );
					pegs.push( peg );
				} 
				
			}
			
			if(pegs.length < NUM_GOAL_PEGS){
				
				throw (new Error("Not enough pegs to set up a level"));
				
			}else{
				
				for( var i:int = 0; i < NUM_GOAL_PEGS; ++i){
					var randomNum	:int			= Math.floor( Math.random() * pegs.length );
					var goalPeg		:PegActor		= pegs[randomNum] as PegActor;
					
					pegs.splice(randomNum, 1);
					
					goalPeg.type = PegActor.STATE_GOAL;
					_goalPegs.push(goalPeg);
				}
				
			}
		}
		
		private function makeWalls():void
		{
			var width	:int = 5;	
			var height	:int = stage.stageHeight;
			
			var wallShape	:b2PolygonShape		= new b2PolygonShape();
			
			var vertexes	:Vector.<b2Vec2>	= Vector.<b2Vec2>([	new b2Vec2(0 / PhysicVars.PIXEL_TO_METER,		0 / PhysicVars.PIXEL_TO_METER), 
				new b2Vec2(width / PhysicVars.PIXEL_TO_METER,	0 / PhysicVars.PIXEL_TO_METER), 
				new b2Vec2(width/ PhysicVars.PIXEL_TO_METER,	height / PhysicVars.PIXEL_TO_METER), 
				new b2Vec2(0/ PhysicVars.PIXEL_TO_METER,		height / PhysicVars.PIXEL_TO_METER)]);			
			
			
			
			wallShape.SetAsVector( vertexes, vertexes.length );
			
			var polygons	:Vector.<b2PolygonShape> = new Vector.<b2PolygonShape>();
			polygons.push(wallShape);
			
			
			var leftWallActor		:ArbitraryStaticActor	= new ArbitraryStaticActor(_camera, new Point(0,0), polygons);
			var rightWallActor		:ArbitraryStaticActor	= new ArbitraryStaticActor(_camera, new Point(stage.stageWidth - width,0), polygons); 
			
			_actors.push(leftWallActor);
			_actors.push(rightWallActor);
			
		}
		
		private function makeRamps():void
		{
			var w1	:int	= 50;
			var h1	:int	= 70;
			
			var w2	:int	= 7;
			var h2	:int	= 5;
			
			var rampShape	:b2PolygonShape		= new b2PolygonShape();
			var rampActor	:ArbitraryStaticActor;
			
			/*********************************
			 * make ramps on the left wall.
			 *********************************/
			var vertexes	:Vector.<b2Vec2>	= Vector.<b2Vec2>([	new b2Vec2(0 / PhysicVars.PIXEL_TO_METER,			0 / PhysicVars.PIXEL_TO_METER), 
				new b2Vec2(w2 / PhysicVars.PIXEL_TO_METER,			-h2 / PhysicVars.PIXEL_TO_METER), 
				new b2Vec2((w1 + w2) / PhysicVars.PIXEL_TO_METER,	(h1 - h2) / PhysicVars.PIXEL_TO_METER),
				new b2Vec2(w1/ PhysicVars.PIXEL_TO_METER,			h1 / PhysicVars.PIXEL_TO_METER)]);			
			
			rampShape.SetAsVector( vertexes, vertexes.length );
			
			var polygons	:Vector.<b2PolygonShape> = new Vector.<b2PolygonShape>();
			polygons.push(rampShape);
			
			
			for(var i:int = 0 ; i < 4; ++i)
			{
				rampActor = new ArbitraryStaticActor(_camera, new Point(0, ( i + 1 ) * 100), polygons);
				_actors.push(rampActor);
			}
			
			
			
			/*********************************
			 * make ramps on the right wall.
			 *********************************/
			var vertexes	:Vector.<b2Vec2>	= Vector.<b2Vec2>([	new b2Vec2(0 / PhysicVars.PIXEL_TO_METER,			0 / PhysicVars.PIXEL_TO_METER), 
				new b2Vec2(-w1 / PhysicVars.PIXEL_TO_METER,			h1 / PhysicVars.PIXEL_TO_METER), 
				new b2Vec2(-(w1 + w2) / PhysicVars.PIXEL_TO_METER,	(h1 - h2) / PhysicVars.PIXEL_TO_METER),
				new b2Vec2(-w2/ PhysicVars.PIXEL_TO_METER,			-h2 / PhysicVars.PIXEL_TO_METER)]);			
			
			rampShape.SetAsVector( vertexes, vertexes.length );
			
			var polygons	:Vector.<b2PolygonShape> = new Vector.<b2PolygonShape>();
			polygons.push(rampShape);
			
			
			for(var i:int = 0 ; i < 4; ++i)
			{
				rampActor = new ArbitraryStaticActor(_camera, new Point(stage.stageWidth, ( i + 1 ) * 100), polygons);
				_actors.push(rampActor);
			}
			
		}	
		
		private function makeBonusChute():void
		{
			var bonusChuteActor:BonusChuteActor = new BonusChuteActor(_camera, 100, stage.stageWidth-100, stage.stageHeight - 50);
			
			_actors.push(bonusChuteActor);
			
		}
		
		//make sure that this function only be called after resource has been loaded completely. 
		private function makeShooter():void
		{
			_shooter = new Shooter();
			_camera.addChild(_shooter);
			_shooter.x = SHOOTER_POINT.x;
			_shooter.y = SHOOTER_POINT.y;
		}
		
		private function update(event:Event):void
		{
			_world.Step( _timeMaster.getTimeStep(), 10, 10);
			
			for each (var actor:Actor in _actors){
				actor.update();
			}
			
			
			checkForZoomIn();
			
			//			_world.ClearForces();
			
			reallyRemoveActors();
		}
		
		private function checkForZoomIn():void
		{
			if(_goalPegs.length >= 1 && _currentBall != null)
			{
				for(var i:int = 0 ; i < _goalPegs.length ; ++i)
				{
					var finalPeg:PegActor = _goalPegs[i] as PegActor;
					var p1:Point = finalPeg.getSpritePosition();
					var p2:Point = _currentBall.getSpritePosition();
					
					//TOD: Stop the weird flickering
					if(distSqr(p1, p2) < 75 * 75)
					{
						_director.zoomInTo(p1);
					}else{
						_director.backToNormal();
					}
				}
				
			}else if( _goalPegs.length == 0)
			{
				_director.backToNormal();
			}
			
			
		}
		
		private function destroyPegNow(event:PegEvent):void
		{
			var targetPeg:PegActor = event.currentTarget as PegActor;
			targetPeg.removeEventListener(PegEvent.DONE_FADING_OUT, destroyPegNow);
			
			safelyRemoveActors(targetPeg);
		}
		
		private function showAimline(event:MouseEvent = null):void
		{
			if(_currentBall == null){
				var launchPoint:Point = _shooter.getLaunchPosition();
				var direction:Point = new Point(mouseX, mouseY).subtract(launchPoint);
				
				_aimingLine.showLine(launchPoint, direction, LAUNCH_SPEED);
			}
		}
		
		private function distSqr(p1:Point, p2:Point):int
		{
			var dx:int = p2.x - p1.x;
			var dy:int = p2.y - p1.y;
			
			return 	dx * dx + dy * dy;
		}
		
	}
}