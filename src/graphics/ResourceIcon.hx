package graphics;

import utilities.Vector2D;
import gamelogic.Resource.ResourceType;
import h2d.Object;
import h2d.Bitmap;

class ResourceIcon {
    public var sprite: Bitmap;

    public function new(p: Object, type: ResourceType, pos: Vector2D) {
        if (type == Triangle) {
            sprite = new Bitmap(hxd.Res.img.Triangle.toTile().center(), p);
            sprite.color = new h3d.Vector(0.8,0,0,1);
        } else if (type == Square){
            sprite = new Bitmap(hxd.Res.img.Square.toTile().center(), p);
            sprite.color = new h3d.Vector(0,0.8,0,1);
        } else {
            sprite = new Bitmap(hxd.Res.img.Circle.toTile().center(), p);
            sprite.color = new h3d.Vector(0,0,0.8,1);
        }
        sprite.x = pos.x; sprite.y = pos.y;
    }

    public function remove() {
        sprite.remove();
    }

}