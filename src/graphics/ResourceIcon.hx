package graphics;

import utilities.Vector2D;
import utilities.MessageManager;
import gamelogic.Resource.ResourceType;
import h2d.Object;
import h2d.Bitmap;
import h2d.Interactive;

class ResourceIcon {
    public var sprite: Bitmap;
    public var type: ResourceType;
    var color: h3d.Vector;

    public function new(p: Object, t: ResourceType, pos: Vector2D, underground=false) {
        type = t;
        if (type == Triangle) {
            sprite = new Bitmap(hxd.Res.img.Triangle.toTile().center(), p);
            color = new h3d.Vector(0.8,0,0,1);
        } else if (type == Square){
            sprite = new Bitmap(hxd.Res.img.Square.toTile().center(), p);
            color = new h3d.Vector(0,0.8,0,1);
        } else {
            sprite = new Bitmap(hxd.Res.img.Circle.toTile().center(), p);
            color = new h3d.Vector(0,0,0.8,1);
        }
        sprite.color = color;
        sprite.x = pos.x; sprite.y = pos.y;
        if (underground)
            sprite.scale(0.5);
        else {
            var interactive = new Interactive(49, 49, sprite);
            interactive.x -= 49/2;
            interactive.y -= 49/2;
            interactive.onClick = (e: hxd.Event) -> MessageManager.sendMessage(new DumpInventoryMessage(this));
            interactive.cursor  = Button;
        }
    }

    public function remove() {
        sprite.remove();
    }

    public function brighten() {
        sprite.color = color;
    }

    public function darken() {
        sprite.color = new h3d.Vector(0.8,0.8,0.8,1);
    }

}