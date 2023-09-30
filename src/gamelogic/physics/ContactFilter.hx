package gamelogic.physics;

import box2D.dynamics.B2Fixture;
import box2D.dynamics.B2ContactFilter;

class ContactFilter extends B2ContactFilter {
    override function shouldCollide(fixtureA:B2Fixture, fixtureB:B2Fixture):Bool {
        var user_data_a = fixtureA.getUserData();       
        var user_data_b = fixtureB.getUserData();       
        return true;
    }
}