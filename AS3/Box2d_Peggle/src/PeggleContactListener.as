package
{
	import Box2D.Collision.b2Manifold;
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
					PegActor(colliderA).hitByBall();
				}else{
					PegActor(colliderB).hitByBall();
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