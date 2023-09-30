package gamelogic;

import h2d.Bitmap;
import utilities.Vector2D;

class Mine implements Updateable implements Placeable {
    
    var sprite: Bitmap;
    var planet: Planet;
    var active = false;

    public function new(p: Planet) {
        planet = p;
        sprite = new Bitmap(hxd.Res.img.Mine.toTile().center());
        p.graphics.addChildAt(sprite, 0);
        sprite.alpha = 0.5;
    }

    public function setPosition(v: Vector2D) {
        sprite.x = v.x;
        sprite.y = v.y;
        sprite.rotation = v.angle() + Math.PI/2;
    }

    public function place() {
        active = true;
        sprite.alpha = 1;
    }

    public function update(dt: Float) {
        if (!active) return;
    }
}