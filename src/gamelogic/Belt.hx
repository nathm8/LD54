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
    var active = false;
    var movingRight = false;

    var sprite2 = false;
    var leftArm: Bitmap;
    var leftUp = true;
    var rightArm: Bitmap;
    var rightUp = true;

    static final MOVING_TIME = 3.0;
    var time = 3.0;
    static final ANIM_TIME = 1.0;
    var animTime = 1.0;

    public function new(p: Planet) {
        planet = p;
        sprite = new Bitmap(hxd.Res.img.Belt.toTile().center(), p.graphics);
        sprite.scale(0.75);
        leftArm = new Bitmap(hxd.Res.img.BeltLeftUp.toTile().center(), sprite);
        rightArm = new Bitmap(hxd.Res.img.BeltRightUp.toTile().center(), sprite);

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

        interactive = new Interactive(46, 31, arrowL);
        interactive.x -= 46/2;
        interactive.y -= 31/2;
        interactive.onClick = moveLeft;
        interactive.cursor = Button;

        interactive = new Interactive(46, 31, arrowR);
        interactive.x -= 46/2;
        interactive.y -= 31/2;
        interactive.onClick = moveRight;
        interactive.cursor = Button;

        active = true;
        moveRight(null);
    }

    function moveLeft(e: hxd.Event) {
        arrowL.alpha = 1.0;
        arrowR.alpha = 0.5;
        movingRight = false;
    }
    
    function moveRight(e: hxd.Event) {
        arrowL.alpha = 0.5;
        arrowR.alpha = 1.0;
        movingRight = true;
    }

    public function update(dt: Float) {
        if (!active) return;
        time -= dt;
        animTime -= dt;
        if (animTime <= 0) {
            animTime = ANIM_TIME;
            if (sprite2)
                sprite.tile = hxd.Res.img.Belt2.toTile().center();
            else
                sprite.tile = hxd.Res.img.Belt.toTile().center();
            sprite2 = !sprite2;
        }
        if (time <= 0) {
            time = MOVING_TIME;
            var next = (side+1)%planet.sides;
            var prev = side-1==-1 ? planet.sides-1 : side-1;
            if (!movingRight) {
                var temp = next;
                next = prev;
                prev = temp;
            }
            if (planet.surfaceResources[next]==null && planet.surfaceResources[side] != null) {
                MessageManager.send(new SpawnResourceMessage(planet.surfaceResources[side], planet, next));
                MessageManager.send(new BeltRemoveResourceMessage(planet, side));
                if (movingRight){
                    if (rightUp) {
                        trace("moving right arm down1");
                        rightArm.tile = hxd.Res.img.BeltRightDown.toTile().center();
                    }
                    else {
                        trace("moving right arm up1");
                        rightArm.tile = hxd.Res.img.BeltRightUp.toTile().center();
                    }
                    rightUp = !rightUp;
                } else {
                    if (leftUp) {
                        trace("moving left arm down1");
                        leftArm.tile = hxd.Res.img.BeltLeftDown.toTile().center();
                    }
                    else {
                        trace("moving left arm up1");
                        leftArm.tile = hxd.Res.img.BeltLeftUp.toTile().center();
                    }
                    leftUp = !leftUp;
                }
            } if (planet.surfaceResources[side]==null && planet.surfaceResources[prev] != null) {
                MessageManager.send(new SpawnResourceMessage(planet.surfaceResources[prev], planet, side));
                MessageManager.send(new BeltRemoveResourceMessage(planet, prev));
                if (!movingRight){
                    if (rightUp) {
                        trace("moving right arm down2");
                        rightArm.tile = hxd.Res.img.BeltRightDown.toTile().center();
                    }
                    else {
                        trace("moving right arm up2");
                        rightArm.tile = hxd.Res.img.BeltRightUp.toTile().center();
                    }
                    rightUp = !rightUp;
                } else {
                    if (leftUp) {
                        trace("moving left arm down2");
                        leftArm.tile = hxd.Res.img.BeltLeftDown.toTile().center();
                    }
                    else {
                        trace("moving left arm up2");
                        leftArm.tile = hxd.Res.img.BeltLeftUp.toTile().center();
                    }
                    leftUp = !leftUp;
                }
            }
        }
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