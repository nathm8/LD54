package graphics;

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
    var target: Planet;
    public var camera: Camera;
    // var focus = System;
    var focus = Planet;

    public function new(s: Scene, p: Planet) {
        camera = new Camera(s);
        camera.layerVisible = (layer) -> layer == 0;
        target = p;
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
            var p = target.graphics.getAbsPos().getPosition();
            camera.x = p.x;
            camera.y = p.y - 50;
            camera.rotation = -target.graphics.rotation;
            // camera.rotation = -target.graphics.rotation - Math.PI + Math.PI/6;
        } else if (focus == System) {
            camera.x = 500;
            camera.y = 1150;
            camera.scaleX = 0.17;
            camera.scaleY = 0.17;
            camera.layerVisible = (layer) -> layer == 0 || layer == 2;
        } else {

        }
    }

    public function receiveMessage(msg:Message):Bool {
        if (Std.isOfType(msg, SystemViewMessage)) {
            TweenManager.add(new CameraZoomTween(camera, 1.0, 0.17, 0, 3));
            TweenManager.add(new CameraMoveTween(camera, new Vector2D(camera.x, camera.y), new Vector2D(500, 1150), 0, 3));
            TweenManager.add(new CameraRotateTween(camera, camera.rotation, 0, 0, 3));
            focus = System;
        }
        return false;
    }    
    
}