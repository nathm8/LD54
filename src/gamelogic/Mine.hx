package gamelogic;

import h2d.Bitmap;
import h2d.Interactive;
import gamelogic.Resource.ResourceType;
import utilities.Vector2D;
import utilities.MessageManager;

class Mine implements Placeable implements MessageListener {
    static final MINING_TIME = 5.0;
    static final ANIM_TIME = 0.5;
    public var sprite: Bitmap;
    public var planet: Planet;
    var active = false;
    var time = 0.0;
    var animTime = 0.0;
    var spriteOne = true;
    public var side: Int;
    public var cost = [Triangle => true, Circle => false, Square => false];

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
        active = planet.resources[i] != null;
        sprite.alpha = 1;
        side = i;

        var interactive = new Interactive(120, 120, sprite);
        interactive.x -= 120/2;
        interactive.y -= 120/2;
        interactive.onClick = demolish;
        interactive.cursor = Button;
    }

    public function update(dt: Float) {
        if (!active || planet.surfaceResources[side] != null) return;
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
            MessageManager.send(new SpawnResourceMessage(planet.resources[side], planet, side));
            planet.surfaceResources[side] = planet.resources[side];
        }
    }

    function demolish(e: hxd.Event) {
        active = false;
        MessageManager.send(new DemolishPlaceableMessage(this));
    }

    public function receiveMessage(msg:Message):Bool {
        return false;
    }

    public function remove() {
        sprite.remove();
        active = false;
    }
}