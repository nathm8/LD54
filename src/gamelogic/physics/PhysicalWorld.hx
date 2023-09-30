package gamelogic.physics;

import utilities.MessageManager;
import box2D.common.math.B2Vec2;
import box2D.dynamics.B2World;

class PhysicalWorld {
    static final physicsScale = 1.0;
    public static var gameWorld = new B2World(new B2Vec2(0, 0), true);

    public static function reset() {
        gameWorld = new B2World(new B2Vec2(0, 0), true);
        gameWorld.setContactListener(new ContactListener());
        gameWorld.setContactFilter(new ContactFilter());
    }

    public static function update(dt: Float) {
        gameWorld.step(dt, 3, 3);
        gameWorld.clearForces();
        MessageManager.send(new PhysicsStepDoneMessage());
    }
}