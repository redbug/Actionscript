package
{
	import Box2D.Collision.b2Manifold;
	import Box2D.Collision.b2WorldManifold;
	import Box2D.Common.Math.b2Vec2;
	import Box2D.Dynamics.Contacts.b2Contact;
	import Box2D.Dynamics.b2ContactImpulse;
	import Box2D.Dynamics.b2ContactListener;
	
	public class PeggleContactListener extends b2ContactListener
	{
		public function PeggleContactListener()
		{
			
		}
		
		override public function BeginContact(contact:b2Contact):void
		{
			super.BeginContact(contact);
			
			var colliderA	:*  = contact.GetFixtureA().GetBody().GetUserData(); 
			var colliderB	:*  = contact.GetFixtureB().GetBody().GetUserData(); 
			
			if(	colliderA is PegActor && colliderB is BallActor ||
				colliderA is BallActor && colliderB is PegActor)
			{
				if(colliderA is PegActor)
				{
					
					var mw:b2WorldManifold = new b2WorldManifold();
					contact.GetWorldManifold(mw);
					
					PegActor(colliderA).hitByBall();
					PegActor(colliderA).setCollisionInfo(	contact.GetFixtureB().GetBody().GetLinearVelocity(), 
															contact.GetFixtureB().GetBody().GetMass(),
															new b2Vec2(mw.m_normal.x * -1, mw.m_normal.y * -1) );
				}else{
					
					var mw:b2WorldManifold = new b2WorldManifold();
					contact.GetWorldManifold(mw);
					
					PegActor(colliderB).hitByBall();
					PegActor(colliderB).setCollisionInfo(	contact.GetFixtureA().GetBody().GetLinearVelocity(),
															contact.GetFixtureA().GetBody().GetMass(),
															mw.m_normal);
				}	
				
			}
			
			//ball hit the bonus chute
			else if (	contact.GetFixtureA().GetUserData() is String &&
						String(contact.GetFixtureA().GetUserData()) == BonusChuteActor.BONUS_TARGET &&
						colliderB is BallActor)
			{			
				BallActor(colliderB).hitBonusChute();
			}
			else if (	contact.GetFixtureB().GetUserData() is String &&
						String(contact.GetFixtureB().GetUserData()) == BonusChuteActor.BONUS_TARGET &&
						colliderA is BallActor)
			{
				BallActor(colliderA).hitBonusChute();
			} 
		}
		
		override public function EndContact(contact:b2Contact):void
		{
			
		}
		
		override public function PreSolve(contact:b2Contact, oldManifold:b2Manifold):void
		{
		
		}
		
		override public function PostSolve(contact:b2Contact, impulse:b2ContactImpulse):void
		{
		
		}
	}
}