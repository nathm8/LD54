package gamelogic;

import utilities.MessageManager.MessageListener;
import utilities.MessageManager;
import utilities.MessageManager.ResourceClickedMessage;
import h2d.Bitmap;
import h2d.Interactive;
import h2d.Graphics;

enum ResourceType{
    Triangle;
    Square;
    Circle;
}

class Resource implements MessageListener {
    var type: ResourceType;
    public var id: Int;
    static var idMax = 0;
    var sprite: Bitmap;
    public var planet: Planet;
    public var side: Int;

    public function new(t: ResourceType, p: Planet, s: Int) {
        id = idMax;
        idMax += 1;
        type = t;
        planet = p;
        side = s;
        if (type == Triangle) {
            sprite = new Bitmap(hxd.Res.img.Triangle.toTile().center(), planet.graphics);
            sprite.color = new h3d.Vector(0.8,0,0,1);
        } else if (type == Square){
            sprite = new Bitmap(hxd.Res.img.Square.toTile().center(), planet.graphics);
            sprite.color = new h3d.Vector(0,0.8,0,1);
        } else {
            sprite = new Bitmap(hxd.Res.img.Circle.toTile().center(), planet.graphics);
            sprite.color = new h3d.Vector(0,0,0.8,1);
        }
        var p = planet.getResourcePositionOnSide(s);
        sprite.x = p.x;
        sprite.y = p.y;
        sprite.rotation = planet.getAngleOnSide(s);

        var interactive     = new Interactive(49, 49, sprite);
        interactive.onClick = (e: hxd.Event) -> MessageManager.sendMessage(new ResourceClickedMessage(this));
        interactive.cursor  = Button;

        MessageManager.addListener(this);
    }

    public function receiveMessage(msg:Message):Bool {
        return false;
    }

}