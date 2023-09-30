package gamelogic;

import h2d.Bitmap;
import utilities.Vector2D;
import utilities.RNGManager;
import h2d.Graphics;
import h2d.Object;
import gamelogic.Updateable;

class Bot implements Updateable {

    var planet: Planet;
    var sprite: Bitmap;
    public var theta = 0.0;
    var time = 0.0;

    public function new(p: Planet) {
        planet = p;
        sprite = new Bitmap(hxd.Res.img.Bot.toTile().center(), p.graphics);
        theta = p.getAngleOnSide(0) - Math.PI/2;
    }

    public function update(dt: Float) {
        time += dt;
        var height = planet.planetRadius + 50 + 10*Math.sin(2*time);
        var pos = new Vector2D(height, 0).rotate(theta);
        sprite.x = pos.x;
        sprite.y = pos.y;
        sprite.rotation = theta + Math.PI/2;
    }
}