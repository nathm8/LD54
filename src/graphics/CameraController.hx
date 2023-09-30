package graphics;

import h2d.Scene;
import gamelogic.Planet;
import gamelogic.Updateable;
import h2d.Camera;

function average(a: Array<Float>) : Float {
    var out = 0.0;
    for (f in a)
        out += f;
    out /= a.length;
    return out;
}

class CameraController  implements Updateable {
    var target: Planet;
    public var camera: Camera;

    public function new(s: Scene, p: Planet) {
        camera = new Camera(s);
        camera.layerVisible = (layer) -> layer == 0;
        target = p;
        // camera.follow = target.graphics;
        // camera.followRotation = true;
        camera.anchorX = 0.5;
        camera.anchorY = 0.5;
    }

    public function update(dt: Float) {
        var p = target.graphics.getAbsPos().getPosition();
        camera.x = p.x;
        camera.y = p.y - 50;
        camera.rotation = -target.graphics.rotation;
    }
    
}