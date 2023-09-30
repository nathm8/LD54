package gamelogic;

import h2d.Bitmap;
import utilities.Vector2D;
import utilities.MessageManager;

class Mine implements Placeable implements MessageListener {
    static final MINING_TIME = 5.0;
    static final ANIM_TIME = 0.5;
    var sprite: Bitmap;
    var planet: Planet;
    var active = false;
    var time = 0.0;
    var animTime = 0.0;
    var spriteOne = true;
    var side: Int;
    var full = false;

    public function new(p: Planet) {
        planet = p;
        sprite = new Bitmap(hxd.Res.img.Mine.toTile().center());
        p.graphics.addChildAt(sprite, 0);
        sprite.alpha = 0.5;
        sprite.scale(0.5);
        MessageManager.addListener(this);
    }

    public function setPosition(v: Vector2D) {
        sprite.x = v.x;
        sprite.y = v.y;
        sprite.rotation = v.angle() + Math.PI/2;
    }

    public function place(i: Int) {
        active = true;
        sprite.alpha = 1;
        side = i;
    }

    public function update(dt: Float) {
        if (!active || full) return;
        time += dt;
        animTime += dt;
        if (animTime > ANIM_TIME) {
            if (spriteOne)
                sprite.tile = hxd.Res.img.Mine2.toTile().center();
            else
                sprite.tile = hxd.Res.img.Mine.toTile().center();
            spriteOne = !spriteOne;
            animTime = 0;
        }
        if (time > MINING_TIME) {
            time -= MINING_TIME;
            MessageManager.sendMessage(new SpawnResourceMessage(planet.resources[side], planet, side));
            full = true;
        }
    }

    public function receiveMessage(msg:Message):Bool {
        if (Std.isOfType(msg, PickUpResourceMessage)) {
            var res = cast(msg, PickUpResourceMessage).resource;
            if (res.planet == planet && res.side == side) full = false;
        }
        return false;
    }
}