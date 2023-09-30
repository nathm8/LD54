package gamelogic;

import h2d.Graphics;
import h2d.Layers;
import h2d.Object;
import utilities.RNGManager;
import gamelogic.Planet;
import gamelogic.Updateable;

class System implements Updateable {

    var graphics: Graphics;
    var star1: Graphics;
    var star2: Graphics;
    var planets = new Array<Planet>();

    public function new(p: Object, l: Layers) {
        initGraphics(p);

        var sides = [3,3,3,4,4];
        RNGManager.rand.shuffle(sides);
        // var radii = [50,100,150,200,250,300,350];
        for (i in 0...sides.length) {
            var pl = new Planet(graphics, l, sides[i], 300*(i+3) + RNGManager.rand.random(100), 10+30*RNGManager.rand.rand(), 60+300*RNGManager.rand.rand());
            planets.push(pl);
        }
    }

    function initGraphics(p: Object) {
        graphics = new Graphics(p);
        star1 = new Graphics(graphics);
        star1.beginFill(0xAAAA00);
        star1.drawCircle(0,0,300,3);
        
        star2 = new Graphics(graphics);
        star2.beginFill(0xAAAA00);
        star2.drawCircle(0,0,300,3);
        star2.rotate(Math.PI);

        graphics.x = 500;
        graphics.y = 500;
    }

    public function update(dt: Float) {
        star1.rotate(dt);
        star2.rotate(-dt);
        for (p in planets) p.update(dt);
    }

    public function getStartingPlanet(): Planet {
        for (p in planets) {
            if (p.sides == 3){
                p.placeResource(Square, 0);
                p.placeResource(Circle, 2);
                return p;
            } 
        }
        return null;
    }
}