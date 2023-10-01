package graphics;

import h2d.Camera;
import h2d.Object;
import h2d.Drawable;
import utilities.Vector2D;
import utilities.Constants.normaliseTheta;
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

class ParabolicMoveTween extends Tween {
	var obj: Object;
	var start: Vector2D;
	var end: Vector2D;

	public function new(o: Object, s: Vector2D, e:Vector2D, te:Float, tt:Float) {
		super(te, tt);
		obj = o; start = s; end = e;
	}
	override function update(dt:Float) {
		super.update(dt);
		var t = timeElapsed / timeTotal;
		t = t*t;
		var v = (1-t)*start + t*end;
		obj.x = v.x; obj.y = v.y;
	}
}

class LinearRotationTween extends Tween {
	var obj: Object;
	var start: Float;
	var end: Float;

	public function new(o: Object, s: Float, e:Float, te:Float, tt:Float) {
		super(te, tt);
		var src = normaliseTheta(s);
        var dst = normaliseTheta(e);
        if (src == dst) return;
        if (Math.abs(dst - src) > Math.PI) {
            if (src > dst)
                src = -(2*Math.PI - src);
            else
                dst = -(2*Math.PI - dst);
        }
		obj = o; start = src; end = dst;
	}
	override function update(dt:Float) {
		super.update(dt);
		var t = timeElapsed / timeTotal;
		var r = (1-t)*start + t*end;
		obj.rotation = r;
	}
}

class CameraMoveTween extends Tween {
	var camera: Camera;
	var start: Vector2D;
	var end: Vector2D;

	public function new(c: Camera, s: Vector2D, e:Vector2D, te:Float, tt:Float) {
		super(te, tt);
		camera = c; start = s; end = e;
	}
	override function update(dt:Float) {
		super.update(dt);
		var t = timeElapsed / timeTotal;
		var v = (1-t)*start + t*end;
		camera.x = v.x; camera.y = v.y;
	}
}

class CameraRotateTween extends Tween {
	var camera: Camera;
	var start: Float;
	var end: Float;

	public function new(c: Camera, s: Float, e:Float, te:Float, tt:Float) {
		super(te, tt);
		var src = normaliseTheta(s);
        var dst = normaliseTheta(e);
        if (src == dst) return;
        if (Math.abs(dst - src) > Math.PI) {
            if (src > dst)
                src = -(2*Math.PI - src);
            else
                dst = -(2*Math.PI - dst);
        }
		camera = c; start = src; end = dst;
	}
	override function update(dt:Float) {
		super.update(dt);
		var t = timeElapsed / timeTotal;
		var r = (1-t)*start + t*end;
		camera.rotation = r;
	}
}

class CameraZoomTween extends Tween {
	var camera: Camera;
	var start: Float;
	var end: Float;

	public function new(c: Camera, s: Float, e:Float, te:Float, tt:Float) {
		super(te, tt);
		camera = c; start = s; end = e;
	}
	override function update(dt:Float) {
		super.update(dt);
		var t = timeElapsed / timeTotal;
		var r = (1-t)*start + t*end;
		camera.scaleX = r; camera.scaleY = r;
	}
}

class ScaleBounceTween extends Tween {
	var object:Object;
	var reverse=false;
	var scaleMin:Float;
	var scaleMax:Float;

	public function new(o:Object, ss:Float, sb: Float, te:Float, tt:Float) {
		super(te, tt);
		object = o;
		kill = false;
		scaleMin = ss;
		scaleMax = sb;
	}

	override function update(dt:Float) {
		dt = reverse ? -dt: dt;
		super.update(dt);
		if (timeElapsed < 0 || timeElapsed >= timeTotal)
			reverse = !reverse;
		var t = timeElapsed / timeTotal;
		object.setScale(scaleMax*t + scaleMin*(1-t));
	}
}

class ParabolicScaleTween extends Tween {
	var obj: Object;
	var start: Float;
	var end: Float;

	public function new(o: Object, s: Float, e:Float, te:Float, tt:Float) {
		super(te, tt);
		obj = o; start = s; end = e;
	}
	override function update(dt:Float) {
		super.update(dt);
		var t = timeElapsed / timeTotal;
		t = t*t;
		var s = (1-t)*start + t*end;
		obj.scaleX = s; obj.scaleY = s;
	}
}

class BotPlanetTravelTween extends Tween {
	var bot:Bot;
	var planet:Planet;
	var thetaStart: Float;
	var thetaEnd: Float;

	public function new(b:Bot, p: Planet, ths:Float, the: Float, te:Float, tt:Float) {
		super(te, tt);
		bot = b;
		planet = p;
		thetaStart = ths;
		thetaEnd = the;
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