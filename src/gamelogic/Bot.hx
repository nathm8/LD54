package gamelogic;

import h2d.Bitmap;
import utilities.Vector2D;
import utilities.MessageManager;
import utilities.RNGManager;
import graphics.TweenManager;
import h2d.Graphics;
import h2d.Object;
import gamelogic.Updateable;
import utilities.Constants.normaliseTheta;

class Bot implements Updateable implements MessageListener {

    var planet: Planet;
    var sprite: Bitmap;
    var face: Bitmap;
    public var theta = 0.0;
    var time = 0.0;
    public var position: Vector2D;

    var faceTime = 1.0;
    var waking = 0;

    public function new(p: Planet) {
        planet = p;
        sprite = new Bitmap(hxd.Res.img.BotBase.toTile().center(), p.graphics);
        face = new Bitmap(hxd.Res.img.BotWake1.toTile().center(), sprite);
        theta = - Math.PI/2;
        MessageManager.addListener(this);
    }

    public function update(dt: Float) {
        time += dt;
        faceTime -= dt;
        if (faceTime <= 0) {
            faceTime = 1.0;
            if (waking < 3) {
                if (waking == 0)
                    face.tile = hxd.Res.img.BotWake2.toTile().center();
                else if (waking == 1)
                    face.tile = hxd.Res.img.BotWake3.toTile().center();
                else
                    face.tile = hxd.Res.img.BotDefault.toTile().center();
                waking++;
            } else
                face.tile = hxd.Res.img.BotDefault.toTile().center();
        }
        var height = planet.planetRadius + 50 + 10*Math.sin(2*time);
        position = new Vector2D(height, 0).rotate(theta);
        sprite.x = position.x;
        sprite.y = position.y;
        sprite.rotation = theta + Math.PI/2;
    }

    // move from current theta to target, via the shortest path
    public function moveTo(dst: Float): Bool {
        var src = normaliseTheta(theta);
        dst = normaliseTheta(dst);
        if (src == dst) return false;
        if (Math.abs(dst - src) > Math.PI) {
            src = -(2*Math.PI - src);
        }
        trace(src, dst);
        TweenManager.add(new BotPlanetTravelTween(this, planet, src, dst, 0, 2));
        return true;
    }

    public function receiveMessage(msg:Message):Bool {
        if (Std.isOfType(msg, AddResourceToInventoryMessage)) {
            var i = RNGManager.rand.random(4);
            if (i == 0)
                face.tile = hxd.Res.img.BotHappy1.toTile().center();
            else if (i == 2)
                face.tile = hxd.Res.img.BotHappy2.toTile().center();
            else if (i == 3)
                face.tile = hxd.Res.img.BotHappy3.toTile().center();
            else
                face.tile = hxd.Res.img.BotHappy4.toTile().center();
            faceTime = 1.0;
        } if (Std.isOfType(msg, DumpInventoryMessage)) {
            var i = RNGManager.rand.random(4);
            if (i == 0)
                face.tile = hxd.Res.img.BotSad1.toTile().center();
            else if (i == 2)
                face.tile = hxd.Res.img.BotSad2.toTile().center();
            else if (i == 3)
                face.tile = hxd.Res.img.BotSad3.toTile().center();
            else
                face.tile = hxd.Res.img.BotSad4.toTile().center();
            faceTime = 1.0;
        }
        return false;
    }
}