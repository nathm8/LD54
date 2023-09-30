package gamelogic;

import h2d.Graphics;
import gamelogic.Mine;
import gamelogic.Updateable;
import graphics.TweenManager;
import graphics.TweenManager.BotPlanetTravelTween;
import utilities.MessageManager.Message;
import utilities.MessageManager.MessageListener;
import utilities.MessageManager;
import utilities.Vector2D;
import utilities.Constants.normaliseTheta;

enum State {
    None;
    PlacingMine;
    BotTravellingToResource;
}

enum TutorialState {
    Start;
    Mine;
}

class GameState implements MessageListener implements Updateable {

    var circles = 0;
    var triangles = 1;
    var squares = 0;
    var state = None;
    var tutorialState = Start;
    var currentPlanet: Planet;
    var bot: Bot;

    // var graphics: Graphics;
    var updateables = new Array<Updateable>();
    var placing: Placeable;

    public function new(p: Planet, b: Bot) {
        MessageManager.addListener(this);
        currentPlanet = p;
        bot = b;
        // debug
        // graphics = new Graphics(currentPlanet.graphics);
        MessageManager.sendMessage(new SpawnResourceMessage(Triangle, currentPlanet, 1));
    }

    public function receiveMessage(msg:Message):Bool {
		if (Std.isOfType(msg, MineClickedMessage)) {
            if (triangles > 0 && state == None) {
                state = PlacingMine;
                var m = new Mine(currentPlanet);
                placing = m;
                updateables.push(m);
            }
		} if (Std.isOfType(msg, MouseMoveMessage)) {
            if (state == PlacingMine) {
                var p = new Vector2D(hxd.Window.getInstance().mouseX, hxd.Window.getInstance().mouseY);
                p -= new Vector2D(500, 500);
                var i = currentPlanet.getClosestSide(normaliseTheta(p.angle()));
                var v = currentPlanet.getBuildingPositionOnSide(i);
                placing.setPosition(v);
            }
        } if (Std.isOfType(msg, MouseReleaseMessage)) {
            if (state == PlacingMine) {
                placing.place();
                state = None;
                circles -= 1;
            }
        } if (Std.isOfType(msg, ResourceClickedMessage)) {
            var res = cast(msg, ResourceClickedMessage).resource;
            if (state == None && res.planet == currentPlanet && canPickup()) {
                state = BotTravellingToResource;
                TweenManager.add(new BotPlanetTravelTween(bot, currentPlanet, bot.theta, currentPlanet.getAngleOnSide(res.side)-Math.PI/2, 0, 2));
                TweenManager.add(new DelayedCallTween(() -> MessageManager.sendMessage(new PickUpResourceMessage(res)), 0, 2));
            }
        } if (Std.isOfType(msg, SpawnResourceMessage)) {
            var params = cast(msg, SpawnResourceMessage);
            new Resource(params.type, params.planet, params.side);
        } if (Std.isOfType(msg, PickUpResourceMessage)) {
            var res = cast(msg, PickUpResourceMessage).resource;
            if (res.type == Triangle) triangles += 1;
            if (res.type == Circle) circles += 1;
            if (res.type == Square) squares += 1;
            state = None;
            TweenManager.add(new ParabolicMoveTween(res.sprite, new Vector2D(res.sprite.x, res.sprite.y), bot.position, 0, 0.5));
            TweenManager.add(new DelayedCallTween(() -> res.remove(), 0, 0.5));
            TweenManager.add(new DelayedCallTween(getTriangle, 0, 0.5));
        }
		return false;
	}

    function getTriangle() {
        trace("getting tri");
        MessageManager.sendMessage(new AddResourceToInventoryMessage(Triangle));
        if (tutorialState == Start) {
            tutorialState = Mine;
            MessageManager.sendMessage(new ShowMine());
        }
    }

    function canPickup() : Bool {
        return triangles + circles + squares < 3;
    }

    public function update(dt: Float) {
        for (u in updateables) u.update(dt);
    }
}