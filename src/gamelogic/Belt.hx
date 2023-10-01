package gamelogic;

import h2d.Bitmap;
import h2d.Interactive;
import gamelogic.Resource.ResourceType;
import utilities.Vector2D;
import utilities.MessageManager;

class Belt implements Placeable implements MessageListener {
    public var sprite: Bitmap;
    public var arrowL: Bitmap;
    public var arrowR: Bitmap;
    public var planet: Planet;
    public var side: Int;
    public var cost = [Triangle => false, Circle => true, Square => false];

    public function new(p: Planet) {
        planet = p;
        sprite = new Bitmap(hxd.Res.img.Belt.toTile().center(), p.graphics);
        sprite.scale(0.75);
        arrowL = new Bitmap(hxd.Res.img.BeltArrow.toTile().center(), sprite);
        arrowL.alpha = 0.5;
        arrowL.x = -30;
        arrowL.y = 65;
        arrowR = new Bitmap(hxd.Res.img.BeltArrow.toTile().center(), sprite);
        arrowR.x = 30;
        arrowR.y = 65;
        arrowR.scaleX = -1;
        sprite.alpha = 0.5;
        MessageManager.addListener(this);
    }

    public function setPosition(v: Vector2D) {
        sprite.x = v.x;
        sprite.y = v.y;
        sprite.rotation = v.angle() + Math.PI/2;
    }

    public function place(i: Int) {
        sprite.alpha = 1;
        side = i;

        var interactive = new Interactive(120, 120, sprite);
        interactive.x -= 120/2;
        interactive.y -= 120/2;
        interactive.onClick = demolish;
        interactive.cursor = Button;
    }

    public function update(dt: Float) {
    }

    function demolish(e: hxd.Event) {
        MessageManager.send(new DemolishPlaceableMessage(this));
    }

    public function receiveMessage(msg:Message):Bool {
        return false;
    }

    public function remove() {
        sprite.remove();
    }
}