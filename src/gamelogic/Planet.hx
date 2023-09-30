package gamelogic;

import utilities.Vector2D;
import utilities.RNGManager;
import h2d.Graphics;
import h2d.Layers;
import h2d.Object;
import gamelogic.Updateable;

class Planet implements Updateable {

    public var graphics: Graphics;
    public var sides: Int;
    var orbitRadius: Float;
    public var planetRadius: Float;
    var day: Float;
    var dayElapsed = 0.0;
    var year: Float;
    var yearElapsed = 0.0;
    var time = 0.0;
    public var position: Vector2D;

    public function new(p: Object, o:Layers, s: Int, r: Float, d:Float, y:Float) {
        sides = s;
        orbitRadius = r;
        planetRadius = 150 / (2*Math.sin(Math.PI/sides));
        day = d;
        dayElapsed = RNGManager.rand.rand()*day;
        year = y;
        yearElapsed = RNGManager.rand.rand()*year;
        initGraphics(p, o);
        update(0);
    }

    function initGraphics(p: Object, o: Layers) {
        var orbit = new Graphics();
        orbit.lineStyle(17.5, 0xFFFFFF);
        orbit.drawCircle(500, 500, orbitRadius);
        o.add(orbit, 2);

        graphics = new Graphics(p);
        graphics.beginFill(0x00AA00);
        graphics.drawCircle(0, 0, planetRadius, sides);
    }

    public function update(dt: Float) {
        yearElapsed += dt;
        if (yearElapsed > year) yearElapsed -= year;
        dayElapsed += dt;
        if (dayElapsed > day) dayElapsed -= day;
        position = new Vector2D(orbitRadius, 0).rotate(2*Math.PI*(yearElapsed/year));
        var rot = 2*Math.PI*(dayElapsed/day);
        graphics.x = position.x;
        graphics.y = position.y;
        graphics.rotation = rot;
    }

    // from angle t, find which side is closest
    public function getClosestSide(t: Float): Int {
        for (i in 0...sides) {
            var start = i*2*Math.PI/sides;
            var end = (i+1)*2*Math.PI/sides;
            if (t >= start && t <= end) {
                return i;
            }
        }
        trace("side not found");
        throw(1);
        return 0;
    }

    public function getBuildingPositionOnSide(i: Int): Vector2D {
        var v1 = new Vector2D(planetRadius+110, 0).rotate(i/sides*2*Math.PI); 
        if (i+1 == sides) i = -1;
        var v2 = new Vector2D(planetRadius+110, 0).rotate((i+1)/sides*2*Math.PI); 
        return (v1 + v2)/2;
    }

    public function getResourcePositionOnSide(i: Int): Vector2D {
        var v1 = new Vector2D(planetRadius+40, 0).rotate(i/sides*2*Math.PI); 
        if (i+1 == sides) i = -1;
        var v2 = new Vector2D(planetRadius+40, 0).rotate((i+1)/sides*2*Math.PI); 
        return (v1*0.4 + v2*0.6);
    }

    public function getAngleOnSide(i: Int): Float {
        var v = getBuildingPositionOnSide(i);
        return v.angle() + Math.PI/2;
    }

}
