package gamelogic;

import gamelogic.Resource.ResourceType;
import graphics.ResourceIcon;
import utilities.Vector2D;
import utilities.RNGManager;
import utilities.MessageManager;
import h2d.Graphics;
import h2d.Layers;
import h2d.Object;
import h2d.Interactive;
import gamelogic.Updateable;
import utilities.Constants.normaliseTheta;

class Planet implements Updateable implements MessageListener {

    static var maxID = 0;
    public var id: Int;

    public var starting = false;
    public var graphics: Graphics;
    public var sides: Int;
    var orbitRadius: Float;
    var minimapView: Graphics;
    public var planetRadius: Float;
    var day: Float;
    var dayElapsed = 0.0;
    var year: Float;
    var yearElapsed = 0.0;
    var time = 0.0;
    public var position: Vector2D;
    public var resources = new Array<ResourceType>();
    public var occupied = new Array<Bool>();
    public var surfaceResources = new Array<ResourceType>();

    public function new(p: Object, o:Layers, s: Int, r: Float, d:Float, y:Float) {
        id = maxID++;
        sides = s;
        orbitRadius = r;
        for (_ in 0...sides) resources.push(null);
        for (_ in 0...sides) surfaceResources.push(null);
        for (_ in 0...sides) occupied.push(false);
        planetRadius = 150 / (2*Math.sin(Math.PI/sides));
        day = d;
        dayElapsed = RNGManager.rand.rand()*day;
        year = y;
        yearElapsed = RNGManager.rand.rand()*year;
        initGraphics(p, o);
        update(0);
        initInteractive();
        MessageManager.addListener(this);
        //DEBUG
        // var text = new h2d.Text(hxd.res.DefaultFont.get(), graphics);
		// text.smooth = false;
		// text.scale(5);
		// text.text = Std.string(id);
    }

    function initInteractive() {
        var interactive = new Interactive(1.5*planetRadius, 1.5*planetRadius, graphics);
        interactive.isEllipse = true;
        interactive.x = -1.5*planetRadius/2;
        interactive.y = -1.5*planetRadius/2;
        interactive.onOver = (e: hxd.Event) -> MessageManager.send(new PlanetFocusedMessage(this));
        interactive.onClick = (e: hxd.Event) -> MessageManager.send(new PlanetClickedMessage(this));
        interactive.cursor = Default;
    }

    function initGraphics(p: Object, o: Layers) {
        var orbit = new Graphics();
        orbit.lineStyle(17.5, 0xFFFFFF, 0.5);
        orbit.drawCircle(500, 500, orbitRadius);
        o.add(orbit, 2);

        minimapView = new Graphics();
        o.add(minimapView, 2);

        graphics = new Graphics(p);
        graphics.beginFill(0x007700);
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

        minimapView.x = position.x + 500;
        minimapView.y = position.y + 500;
        minimapView.rotation = rot;
    }

    public function placeResource(t: ResourceType, i: Int) {
        resources[i] = t;
        var res = new ResourceIcon(graphics, t, getUndergroundResourcePositionOnSide(i), true);
        res.sprite.rotation = getAngleOnSide(i);
        res.sprite.scale(0.5);

        var map_icon = new ResourceIcon(minimapView, t, 1.75*getBuildingPositionOnSide(i, null), true);
        map_icon.sprite.rotation = getAngleOnSide(i);
        map_icon.sprite.scale(4);
    }

    // from angle t, find which side is closest
    public function getClosestSide(t: Float): Int {
        t = normaliseTheta(t);
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

    public function getBuildingPositionOnSide(i: Int, pl: Placeable): Vector2D {
        var offset = 0.0;
        if (sides == 3) {
            if (Std.isOfType(pl, Mine)) offset += 5;
            if (Std.isOfType(pl, Rocket)) offset -= 44;
        } else if (sides == 4) {
            offset = 17;
            if (Std.isOfType(pl, Mine)) offset += 8;
            if (Std.isOfType(pl, Rocket)) offset -= 30;
        } else {
            offset = 25;
            if (Std.isOfType(pl, Mine)) offset += 5;
            if (Std.isOfType(pl, Rocket)) offset -= 26;
        }
        var v1 = new Vector2D(planetRadius+70-offset, 0).rotate(i/sides*2*Math.PI); 
        if (i+1 == sides) i = -1;
        var v2 = new Vector2D(planetRadius+70-offset, 0).rotate((i+1)/sides*2*Math.PI); 
        return (v1 + v2)/2;
    }

    public function getUndergroundResourcePositionOnSide(i: Int): Vector2D {
        var v1 = new Vector2D(planetRadius-50, 0).rotate(i/sides*2*Math.PI); 
        if (i+1 == sides) i = -1;
        var v2 = new Vector2D(planetRadius-50, 0).rotate((i+1)/sides*2*Math.PI); 
        return (v1 + v2)/2;
    }

    public function getResourcePositionOnSide(i: Int): Vector2D {
        var offset = 0.0;
        if (sides == 4) offset = 5;
        var v1 = new Vector2D(planetRadius+40-offset, 0).rotate(i/sides*2*Math.PI); 
        if (i+1 == sides) i = -1;
        var v2 = new Vector2D(planetRadius+40-offset, 0).rotate((i+1)/sides*2*Math.PI); 
        return (v1*0.25 + v2*0.75);
    }

    public function getAngleOnSide(i: Int): Float {
        var v = getBuildingPositionOnSide(i, null);
        return v.angle() + Math.PI/2;
    }

    public function receiveMessage(msg:Message):Bool {
        if (Std.isOfType(msg, SpawnResourceMessage)) {
            var params = cast(msg, SpawnResourceMessage);
            if (params.planet != this) return false;
            if (surfaceResources[params.side] != null) return false;
            surfaceResources[params.side] = params.type;
            new Resource(params.type, params.planet, params.side);
        } if (Std.isOfType(msg, BotPickUpResourceMessage)) {
            var res = cast(msg, BotPickUpResourceMessage).resource;
            if (res.planet != this) return false;
            if (surfaceResources[res.side] != res.type) {
                trace("bad pickup");
                throw(1);
            }
            surfaceResources[res.side] = null;
        } if (Std.isOfType(msg, BeltRemoveResourceMessage)) {
            var params = cast(msg, BeltRemoveResourceMessage);
            if (params.planet != this) return false;
            surfaceResources[params.side] = null;
        } if (Std.isOfType(msg, RocketConsumedResourceMessage)) {
            var params = cast(msg, RocketConsumedResourceMessage);
            if (params.planet != this) return false;
            surfaceResources[params.side] = null;
        }
        return false;
    }

}
