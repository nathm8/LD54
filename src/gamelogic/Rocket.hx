package gamelogic;

import h2d.Text;
import h2d.Bitmap;
import h2d.Interactive;
import graphics.TweenManager;
import graphics.ResourceIcon;
import gamelogic.Resource.ResourceType;
import utilities.Vector2D;
import utilities.MessageManager;

class Rocket implements Placeable implements MessageListener {
    public var sprite: Bitmap;
    public var planet: Planet;
    public var side: Int;
    public var cost = [Triangle => true, Circle => true, Square => true];
    var countdown = 1.0;
    var countdownInts = [for (i in 1...11) i];
    var active = false;
    var updateables = new Array<Updateable>();

    var circleCharged = true;
    var triangleCharged = true;
    var circleIcon: ResourceIcon;
    var triangleIcon: ResourceIcon;
    var hasLaunched = false;

    public function new(p: Planet) {
        planet = p;
        sprite = new Bitmap(hxd.Res.img.Rocket.toTile().center());
        p.graphics.addChildAt(sprite, 0);
        sprite.alpha = 0.5;
        sprite.scale(0.75);
        MessageManager.addListener(this);

        circleIcon = new ResourceIcon(sprite, Circle, new Vector2D(-30, 95));
        circleIcon.sprite.visible = false;
        circleIcon.sprite.scale(0.5);
        circleIcon.darken();
        triangleIcon = new ResourceIcon(sprite, Triangle, new Vector2D(30, 95));
        triangleIcon.sprite.visible = false;
        triangleIcon.sprite.scale(0.5);
        triangleIcon.darken();
    }

    public function setPosition(v: Vector2D) {
        sprite.x = v.x;
        sprite.y = v.y;
        sprite.rotation = v.angle() + Math.PI/2;
    }

    public function place(i: Int) {
        sprite.alpha = 1;
        side = i;
        active = true;

        var interactive = new Interactive(120, 156, sprite);
        interactive.x -= 120/2;
        interactive.y -= 156/2;
        interactive.onClick = demolish;
        interactive.cursor = Button;
    }

    public function update(dt: Float) {
        if (!circleCharged && !active) {
            if (planet.surfaceResources[side] == Circle) {
                MessageManager.send(new RocketConsumedResourceMessage(planet, side));
                circleCharged = true;
                circleIcon.brighten();
            }
        }
        if (!triangleCharged && !active) {
            if (planet.surfaceResources[side] == Triangle) {
                MessageManager.send(new RocketConsumedResourceMessage(planet, side));
                triangleCharged = true;
                triangleIcon.brighten();
            }
        }
        if (hasLaunched && triangleCharged && circleCharged && !active) {
            sprite.tile = hxd.Res.img.Rocket.toTile().center();
            active = true;
            countdownInts = [for (i in 1...11) i];
        }
        if (!active) return;
        countdown -= dt;
        if (countdown <= 0) {
            countdown = 1.0;
            if (countdownInts.length == 0)
                blastOff();
            else {
                var i = countdownInts.pop();
                updateables.push(new CountdownText(this, i));
            }
        }
        for (u in updateables) u.update(dt);
    }

    function blastOff() {
        sprite.tile = hxd.Res.img.RocketPlatform.toTile().center();
        updateables.push(new LaunchedRocket(this));
        active = false;
        cost = [Triangle => false, Circle => false, Square => true];
        // TODO show greyed out triangle and circle
        circleCharged = false;
        circleIcon.darken();
        triangleCharged = false;
        triangleIcon.darken();
        circleIcon.sprite.visible = true;
        triangleIcon.sprite.visible = true;
        hasLaunched = true;
    }

    function demolish(e: hxd.Event) {
        active = false;
        MessageManager.send(new DemolishPlaceableMessage(this));
    }

    public function receiveMessage(msg:Message):Bool {
        return false;
    }

    public function remove() {
        sprite.remove();
    }
}

class CountdownText implements Updateable {
    
    var text: Text;

    public function new(r: Rocket, i: Int) {
        text = new h2d.Text(hxd.res.DefaultFont.get(), r.sprite);
		text.smooth = false;
		text.scale(7);
		text.textAlign = Center;
        text.textColor = 0xFFFFFF;
        text.x = 100;
        text.y = -75;
        TweenManager.add(new FadeTween(text, 0, 0.9));
        TweenManager.add(new ParabolicMoveTween(text, new Vector2D(100,-75), new Vector2D(100,-200), 0, 0.9));
        var exclaims = "";
        if (i == 1) {
            exclaims = "!!!!";
            text.scale(1.3);
            TweenManager.add(new ShakeTween(text, 16, 0, 0.9));
            text.textColor = 0xFF0000;
        } if (i == 2) {
            exclaims = "!!!";
            text.scale(1.2);
            TweenManager.add(new ShakeTween(text, 8, 0, 0.9));
            text.textColor = 0xFC5F5F;
        } if (i == 3) {
            exclaims = "!!"; 
            text.scale(1.1);
            TweenManager.add(new ShakeTween(text, 2, 0, 0.9));
            text.textColor = 0xFC8888;
        } if (i == 4) {
            exclaims = "!"; 
            text.scale(1.05);
            TweenManager.add(new ShakeTween(text, 1, 0, 0.9));
            text.textColor = 0xFAB1B1;
        }
		text.text = Std.string(i)+exclaims;
    }

    public function update(dt: Float) {

    }

}

class LaunchedRocket implements Updateable {

    var sprite: Bitmap;

    public function new(r: Rocket) {
        sprite = new Bitmap(hxd.Res.img.LaunchedRocket.toTile().center(), r.sprite);
        TweenManager.add(new ExponentialMoveTween(sprite, new Vector2D(0,0), new Vector2D(0,-5000), 0, 5));
        TweenManager.add(new ShakeTween(sprite, 10, 0, 5));
        TweenManager.add(new DelayedCallTween(()->remove(),0,5));
        TweenManager.add(new DelayedCallTween(()->MessageManager.send(new RocketLaunchedMessage()),0,5));
    }

    public function update(dt: Float) {

    }

    function remove() {
        sprite.remove();
    }
}