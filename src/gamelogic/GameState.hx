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
    var triangles = 0;
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
                state = None;
                triangles -= 1;
                var p = new Vector2D(hxd.Window.getInstance().mouseX, hxd.Window.getInstance().mouseY);
                p -= new Vector2D(500, 500);
                placing.place(currentPlanet.getClosestSide(normaliseTheta(p.angle())));
                placing = null;
                MessageManager.sendMessage(new RemoveResourceFromInventoryMessage(Triangle));
            }
        } if (Std.isOfType(msg, ResourceClickedMessage)) {
            var res = cast(msg, ResourceClickedMessage).resource;
            if (state == None && res.planet == currentPlanet && canPickup()) {
                var src = normaliseTheta(bot.theta);
                var dst = normaliseTheta(currentPlanet.getAngleOnSide(res.side)-Math.PI/2);
                trace(src, dst);
                state = BotTravellingToResource;
                if (src != dst) {
                    TweenManager.add(new BotPlanetTravelTween(bot, currentPlanet, src, dst, 0, 2));
                    TweenManager.add(new DelayedCallTween(() -> MessageManager.sendMessage(new PickUpResourceMessage(res)), 0, 2));
                } else {
                    MessageManager.sendMessage(new PickUpResourceMessage(res));
                }
            }
        } if (Std.isOfType(msg, DropResourceMessage)) {
            var params = cast(msg, DropResourceMessage);
            new Resource(params.resourceType, currentPlanet, currentPlanet.getClosestSide(bot.theta));
            if (params.resourceType == Triangle) triangles -= 1;
            if (params.resourceType == Circle) circles -= 1;
            if (params.resourceType == Square) squares -= 1;
        } if (Std.isOfType(msg, SpawnResourceMessage)) {
            var params = cast(msg, SpawnResourceMessage);
            new Resource(params.type, params.planet, params.side);
        } if (Std.isOfType(msg, PickUpResourceMessage)) {
            if (state != BotTravellingToResource) return false;
            var res = cast(msg, PickUpResourceMessage).resource;
            if (res.type == Triangle) {
                triangles += 1;
                TweenManager.add(new DelayedCallTween(getTriangle, 0, 0.5));
            } if (res.type == Circle) {
                circles += 1;
                TweenManager.add(new DelayedCallTween(getCircle, 0, 0.5));
            } if (res.type == Square) {
                squares += 1;
                TweenManager.add(new DelayedCallTween(getSquare, 0, 0.5));
            }
            state = None;
            TweenManager.add(new ParabolicMoveTween(res.sprite, new Vector2D(res.sprite.x, res.sprite.y), bot.position, 0, 0.5));
            TweenManager.add(new ParabolicScaleTween(res.sprite, 1.0, 0.0, 0, 0.5));
            TweenManager.add(new DelayedCallTween(() -> res.remove(), 0, 0.5));
        }
		return false;
	}

    function getTriangle() {
        MessageManager.sendMessage(new AddResourceToInventoryMessage(Triangle));
        if (tutorialState == Start) {
            tutorialState = Mine;
            MessageManager.sendMessage(new ShowMineMessage());
        }
    }

    function getSquare() {
        MessageManager.sendMessage(new AddResourceToInventoryMessage(Square));
        // if (tutorialState == Start) {
        //     tutorialState = Mine;
        //     MessageManager.sendMessage(new ShowMineMessage());
        // }
    }

    function getCircle() {
        MessageManager.sendMessage(new AddResourceToInventoryMessage(Circle));
        // if (tutorialState == Start) {
        //     tutorialState = Mine;
        //     MessageManager.sendMessage(new ShowMineMessage());
        // }
    }

    function canPickup() : Bool {
        return triangles + circles + squares < 3;
    }

    public function update(dt: Float) {
        if (triangles == 0) MessageManager.sendMessage(new DarkenTrianglesMessage());
        else MessageManager.sendMessage(new BrightenTrianglesMessage());
        for (u in updateables) u.update(dt);
    }
}