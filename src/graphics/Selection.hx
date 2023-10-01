package graphics;

import h2d.Bitmap;
import h2d.Object;
import graphics.TweenManager;

class Selection {
    var sprite: Bitmap;

    public function new(p: Object) {
        sprite = new Bitmap(hxd.Res.img.Selection.toTile().center(), p);
        TweenManager.add(new ScaleBounceTween(sprite, 0.5, 1.5, 0, 4));
    }

    public function remove() {
        sprite.remove();
    }
}