package gamelogic.physics;

import box2D.dynamics.B2ContactImpulse;
import box2D.dynamics.contacts.B2Contact;
import box2D.dynamics.B2ContactListener;

class ContactListener extends B2ContactListener {
    override public function postSolve(contact:B2Contact, impulse:B2ContactImpulse):Void {
        var object_a = contact.getFixtureA().getBody().getUserData();
        var object_b = contact.getFixtureB().getBody().getUserData();
    }
}