package gamelogic;

import h2d.Graphics;
import h2d.Layers;
import h2d.Object;
import utilities.RNGManager;
import gamelogic.Planet;
import gamelogic.Updateable;
import gamelogic.Resource;

class System implements Updateable {

    var graphics: Graphics;
    var star1: Graphics;
    var star2: Graphics;
    var planets = new Array<Planet>();

    public function new(p: Object, l: Layers) {
        initGraphics(p);

        var start_set = false;

        var sides = [3,3,3,4,4,5];
        RNGManager.rand.shuffle(sides);
        var resources = [Triangle, Square, Circle];
        // var radii = [50,100,150,200,250,300,350];
        for (i in 0...sides.length) {
            var places = [for (j in 0...sides[i]) j];
            RNGManager.rand.shuffle(places);
            var pl = new Planet(graphics, l, sides[i], 300*(i+2), 10+30*RNGManager.rand.rand(), 60+300*RNGManager.rand.rand());
            // var pl = new Planet(graphics, l, sides[i], 300*(i+3) + RNGManager.rand.random(100), 10+30*RNGManager.rand.rand(), 60+300*RNGManager.rand.rand());
            if (!start_set && sides[i] == 3){
                start_set = true;
                pl.starting = true;
                pl.placeResource(Square, 0);
            } if (!pl.starting) {
                if (sides[i] == 5) {
                    pl.placeResource(Circle, 0);
                    pl.placeResource(Triangle, 1);
                } else {
                    for (_ in 0...(sides[i] - 2 + RNGManager.rand.random(1))){
                        var r = resources.pop();
                        if (resources.length == 0) resources = [Triangle, Square, Circle];
                        RNGManager.rand.shuffle(resources);
                        var p = places.pop();
                        pl.placeResource(r, p);
                    }
                }
            }
            planets.push(pl);
        }
    }

    function initGraphics(p: Object) {
        graphics = new Graphics(p);
        star1 = new Graphics(graphics);
        star1.filter = new h2d.filter.Bloom(10,10,100,5,1);
        star1.beginFill(0xFFFF00);
        star1.drawCircle(0,0,300,3);
        
        star2 = new Graphics(star1);
        star2.beginFill(0xFFFF00);
        star2.drawCircle(0,0,300,3);
        star2.rotate(Math.PI);

        graphics.x = 500;
        graphics.y = 500;
    }

    public function update(dt: Float) {
        star1.rotate(dt);
        star2.rotate(-2*dt);
        for (p in planets) p.update(dt);
    }

    public function getStartingPlanet(): Planet {
        for (p in planets) {
            if (p.starting) return p;
        }
        return null;
    }
}