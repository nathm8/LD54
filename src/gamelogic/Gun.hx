package gamelogic;

import h2d.Bitmap;
import h2d.Interactive;
import gamelogic.Resource.ResourceType;
import utilities.Vector2D;
import utilities.MessageManager;
import utilities.Constants.normaliseTheta;
import graphics.TweenManager;

class Gun implements Placeable implements MessageListener {
    public var sprite: Bitmap;
    public var turret: Bitmap;
    public var planet: Planet;
    var time = 0.0;
    public var side: Int;
    public var cost = [Triangle => false, Circle => false, Square => true];

    public function new(p: Planet) {
        planet = p;
        sprite = new Bitmap(hxd.Res.img.GunBase.toTile().center());
        var t = hxd.Res.img.GunTurret.toTile();
        t.setCenterRatio(1.0/3.0,49.0/120.0);
        turret = new Bitmap(t, sprite);
        turret.y = -31;
        p.graphics.addChildAt(sprite, 0);
        sprite.alpha = 0.5;
        sprite.scale(0.75);
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
        interactive.onClick = handleClick;
        interactive.cursor = Button;
    }

    public function update(dt: Float) {
    }

    function handleClick(e: hxd.Event) {
        MessageManager.send(new PlacedGunClickedMessage(this));
    }

    public function receiveMessage(msg:Message):Bool {
        if (Std.isOfType(msg, BotLaunchedMessage)) {
            TweenManager.add(new DelayedCallTween(() -> TweenManager.add(new LinearRotationTween(turret, -Math.PI/2, 0, 0, 2.0)), 0, 2.0));
        }
        return false;
    }

    public function remove() {
        sprite.remove();
    }
}