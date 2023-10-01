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
    public var side: Int;
    public var cost = [Triangle => false, Circle => false, Square => true];
    var targetIcon: Bitmap;
    var targeting = false;
    var hasTarget = false;
    var targetPlanet: Planet;
    var targetSide: Int;

    var time = 3.0;
    static final FIRING_TIME = 3.0;

    public function new(p: Planet) {
        planet = p;
        sprite = new Bitmap(hxd.Res.img.GunBase.toTile().center(), p.graphics);
        targetIcon = new Bitmap(hxd.Res.img.Target.toTile().center(), sprite);
        targetIcon.y = 75;
        var t = hxd.Res.img.GunTurret.toTile();
        t.setCenterRatio(1.0/3.0,49.0/120.0);
        turret = new Bitmap(t, sprite);
        turret.y = -31;
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

        var interactive = new Interactive(64, 98, sprite);
        interactive.x -= 64/2;
        interactive.y -= 98/2;
        interactive.onClick = handleClick;
        interactive.cursor = Button;

        interactive = new Interactive(37, 37, targetIcon);
        interactive.x -= 37/2;
        interactive.y -= 37/2;
        interactive.onClick = (e: hxd.Event) -> {MessageManager.send(new GunTargetingMessage()); targeting=true;};
        interactive.cursor = Button;
    }

    public function update(dt: Float) {
        if (!hasTarget) return;
        time -= dt;
        if (time <= 0) {
            time = FIRING_TIME;
            if (planet.surfaceResources[side] != null) {
                MessageManager.send(new RocketConsumedResourceMessage(planet, side));
                var src_global_pos = sprite.localToGlobal(new Vector2D(sprite.x, sprite.y));
                var start = new Vector2D(src_global_pos.x, src_global_pos.y);
                var dst_global_pos = targetPlanet.graphics.localToGlobal(targetPlanet.getResourcePositionOnSide(targetSide));
                var end = new Vector2D(dst_global_pos.x, dst_global_pos.y);

                var launchedRes: Bitmap;
                var type = planet.surfaceResources[side];
                if (type == Triangle) {
                    launchedRes = new Bitmap(hxd.Res.img.Triangle.toTile().center(), sprite.getScene());
                    launchedRes.color = new h3d.Vector(0.8,0,0,1);
                } else if (type == Square){
                    launchedRes = new Bitmap(hxd.Res.img.Square.toTile().center(), sprite.getScene());
                    launchedRes.color = new h3d.Vector(0,0.8,0,1);
                } else {
                    launchedRes = new Bitmap(hxd.Res.img.Circle.toTile().center(), sprite.getScene());
                    launchedRes.color = new h3d.Vector(0,0,0.8,1);
                }
                launchedRes.x = start.x; launchedRes.y = start.y;

                var t = (start - end).magnitude/900;
                t = t < 0.3 ? 0.3 : t;

                TweenManager.add(new LaunchTween(launchedRes, targetPlanet, start, 0, t));
                TweenManager.add(new DelayedCallTween(() -> MessageManager.send(new SpawnResourceMessage(type, targetPlanet, targetSide)), 0, t));
                TweenManager.add(new DelayedCallTween(() -> launchedRes.remove(), 0, t));
            }
        }
    }

    function handleClick(e: hxd.Event) {
        MessageManager.send(new PlacedGunClickedMessage(this));
    }

    public function receiveMessage(msg:Message):Bool {
        if (Std.isOfType(msg, BotLaunchedMessage)) {
            TweenManager.add(new DelayedCallTween(() -> TweenManager.add(new LinearRotationTween(turret, -Math.PI/2, 0, 0, 2.0)), 0, 2.0));
        } if (Std.isOfType(msg, CancelGunTargeting)) {
            targeting = false;
        } if (Std.isOfType(msg, GunTargetAcquired)) {
            if (!targeting) return false;
            var params = cast(msg, GunTargetAcquired);
            targetPlanet = params.planet;
            targetSide = params.side;
            hasTarget = true;
        }
        return false;
    }

    public function remove() {
        sprite.remove();
    }
}