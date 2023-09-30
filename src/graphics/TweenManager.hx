package graphics;

import h2d.Camera;
import h2d.Object;
import h2d.Drawable;
import utilities.Vector2D;
import gamelogic.Bot;
import gamelogic.Planet;

class Tween {
    public var timeTotal:Float;
	public var timeElapsed:Float;
	public var kill:Bool = true; // flag to let tweens live forever
	var after: Tween;

    public function new(te:Float, tt:Float, a: Tween= null) {
		// negative te acts a delay
		timeElapsed = te;
		timeTotal = tt;
		after = a;
	}

	public function update(dt:Float) {
        timeElapsed += dt;
        if (timeElapsed > timeTotal) {
			timeElapsed = timeTotal;
			if (after != null)
				TweenManager.add(after);
		}
    }
}

class FadeTween extends Tween {
	var obj:Object;

	public function new(o:Object, te:Float, tt:Float) {
		super(te, tt);
		obj = o;
	}

	override function update(dt:Float) {
		super.update(dt);
		var t = timeElapsed / timeTotal;
		obj.alpha = 1-t;
	}
}

class BotPlanetTravelTween extends Tween {
	var bot:Bot;
	var planet:Planet;
	var thetaStart: Float;
	var thetaEnd: Float;

	public function new(b:Bot, p: Planet, ts:Float, te: Float, te:Float, tt:Float) {
		super(te, tt);
		bot = b;
		planet = p;
		thetaStart = ts;
		thetaEnd = te;
	}

	override function update(dt:Float) {
		super.update(dt);
		var t = timeElapsed / timeTotal;
		bot.theta = (1-t)*thetaStart + t*thetaEnd;
	}
}

class DelayedCallTween extends Tween {
    var func: ()->Void;

	public function new(func:() -> Void, te:Float, tt:Float) {
        super(te, tt);
        this.func = func;
    }

	override function update(dt:Float) {
        super.update(dt);
        if (timeElapsed >= timeTotal)
            func();
    }

}

class TweenManager {
    static var tweens = new Array<Tween>();
    
    static public function update(dt: Float) {
        var to_remove = [];
        for (t in tweens) {
            t.update(dt);
            if (t.timeElapsed >= t.timeTotal)
                to_remove.push(t);
        }
        for (t in to_remove)
			if (t.kill)
            	tweens.remove(t);
    }

    static public function add(t: Tween) {
        tweens.push(t);
    }

    static public function remove(t: Tween) {
        tweens.remove(t);
    }

	static public function reset() {
		tweens = [];
	}
}