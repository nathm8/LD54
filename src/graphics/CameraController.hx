package graphics;

import h2d.Object;
import h2d.Scene;
import gamelogic.Planet;
import gamelogic.Updateable;
import h2d.Camera;
import utilities.MessageManager;
import utilities.Vector2D;
import graphics.TweenManager;

function average(a: Array<Float>) : Float {
    var out = 0.0;
    for (f in a)
        out += f;
    out /= a.length;
    return out;
}

enum Focus {
    Planet;
    Bot;
    System;
}

class CameraController implements Updateable implements MessageListener {
    var target: Object;
    public var camera: Camera;
    var focus = Planet;

    public function new(s: Scene, p: Planet) {
        camera = new Camera(s);
        camera.layerVisible = (layer) -> layer == 0;
        target = p.graphics;
        // camera.follow = target.graphics;
        // camera.followRotation = true;
        camera.anchorX = 0.5;
        camera.anchorY = 0.5;
        MessageManager.addListener(this);

        // camera.x = 500;
        // camera.y = 1150;
        // camera.scaleX = 0.17;
        // camera.scaleY = 0.17;
        // camera.layerVisible = (layer) -> layer == 0 || layer == -2;
    }

    public function update(dt: Float) {
        if (focus == Planet) {
            var p = target.getAbsPos().getPosition();
            camera.x = p.x;
            camera.y = p.y - 50;
            camera.rotation = -target.rotation;
            camera.layerVisible = (layer) -> layer == 0;
            // camera.rotation = -target.graphics.rotation - Math.PI + Math.PI/6;
        } else if (focus == System) {
            camera.x = 500;
            camera.y = 1150;
            camera.scaleX = 0.17;
            camera.scaleY = 0.17;
            camera.layerVisible = (layer) -> layer == 0 || layer == 2;
        } else {
            var p = target.getAbsPos().getPosition();
            camera.x = p.x;
            camera.y = p.y - 50;
            // camera.rotation = -target.rotation;
        }
    }

    public function receiveMessage(msg:Message):Bool {
        if (Std.isOfType(msg, SystemViewMessage)) {
            TweenManager.add(new CameraZoomTween(camera, 1.0, 0.17, 0, 3));
            TweenManager.add(new CameraMoveTween(camera, new Vector2D(camera.x, camera.y), new Vector2D(500, 1150), 0, 3));
            TweenManager.add(new CameraRotateTween(camera, camera.rotation, 0, 0, 3));
            focus = System;
        } if (Std.isOfType(msg, BotViewMessage)) {
            target = cast(msg, BotViewMessage).object;
            var t = cast(msg, BotViewMessage).transitTime;
            var planet = cast(msg, BotViewMessage).planet.graphics;
            TweenManager.add(new CameraZoomTween(camera, 0.17, 1.0, 0, 0.25));
            var p = target.getAbsPos().getPosition();
            TweenManager.add(new CameraMoveTween(camera, new Vector2D(500, 1150), new Vector2D(p.x, p.y), 0, 0.25));
            TweenManager.add(new DelayedCallTween(() -> focus = Bot, 0, 0.25));
            TweenManager.add(new DelayedCallTween(() -> focus = Planet, 0, t));
            TweenManager.add(new DelayedCallTween(() -> target = planet, 0, t));
        } if (Std.isOfType(msg, PlanetViewMessage)) {
            var planet = cast(msg, PlanetViewMessage).planet.graphics;
            target = planet;
            var p = target.getAbsPos().getPosition();
            TweenManager.add(new CameraZoomTween(camera, 0.17, 1.0, 0, 3));
            TweenManager.add(new CameraMoveTween(camera, new Vector2D(camera.x, camera.y), new Vector2D(p.x, p.y), 0, 3));
            TweenManager.add(new CameraRotateTween(camera, camera.rotation, -target.rotation, 0, 3));
            TweenManager.add(new DelayedCallTween(() -> focus = Planet, 0, 3));
        }
        return false;
    }    
    
}