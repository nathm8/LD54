package gamelogic;

import h2d.Graphics;
import gamelogic.Mine;
import gamelogic.Updateable;
import gamelogic.Resource.ResourceType;
import graphics.TweenManager;
import graphics.TweenManager.BotPlanetTravelTween;
import utilities.MessageManager.Message;
import utilities.MessageManager.MessageListener;
import utilities.MessageManager;
import utilities.Vector2D;
import utilities.Constants.normaliseTheta;

enum State {
    None;
    Placing;
    Travelling;
    PickingUp;
}

enum TutorialState {
    Start;
    Mine;
    Gun;
    Done;
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
                state = Placing;
                var m = new Mine(currentPlanet);
                placing = m;
                updateables.push(m);
            }
		} if (Std.isOfType(msg, GunClickedMessage)) {
            if (squares > 0 && state == None) {
                state = Placing;
                var m = new Gun(currentPlanet);
                placing = m;
                updateables.push(m);
            }
		} if (Std.isOfType(msg, MouseMoveMessage)) {
            if (state == Placing) {
                var p = new Vector2D(hxd.Window.getInstance().mouseX, hxd.Window.getInstance().mouseY);
                p -= new Vector2D(500, 500);
                var i = currentPlanet.getClosestSide(normaliseTheta(p.angle()));
                var v = currentPlanet.getBuildingPositionOnSide(i);
                placing.setPosition(v);
            }
        } if (Std.isOfType(msg, MouseReleaseMessage)) {
            if (state == Placing) {
                state = None;
                var p = new Vector2D(hxd.Window.getInstance().mouseX, hxd.Window.getInstance().mouseY);
                p -= new Vector2D(500, 500);
                placing.place(currentPlanet.getClosestSide(normaliseTheta(p.angle())));
                for (res => bool in placing.cost) {
                    if (bool) {
                        MessageManager.sendMessage(new RemoveResourceFromInventoryMessage(res));
                        decrementResource(res);
                    }
                }
                placing = null;
            }
        } if (Std.isOfType(msg, ResourceClickedMessage)) {
            var res = cast(msg, ResourceClickedMessage).resource;
            if (state == None && res.planet == currentPlanet && canPickup()) {
                var src = normaliseTheta(bot.theta);
                var dst = normaliseTheta(currentPlanet.getAngleOnSide(res.side)-Math.PI/2);
                state = Travelling;
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
            if (state != Travelling) return false;
            var res = cast(msg, PickUpResourceMessage).resource;
            if (res.type == Triangle)
                TweenManager.add(new DelayedCallTween(getTriangle, 0, 0.5));
            if (res.type == Circle)
                TweenManager.add(new DelayedCallTween(getCircle, 0, 0.5));
            if (res.type == Square)
                TweenManager.add(new DelayedCallTween(getSquare, 0, 0.5));
            state = PickingUp;
            TweenManager.add(new ParabolicMoveTween(res.sprite, new Vector2D(res.sprite.x, res.sprite.y), bot.position, 0, 0.5));
            TweenManager.add(new ParabolicScaleTween(res.sprite, 1.0, 0.0, 0, 0.5));
            TweenManager.add(new DelayedCallTween(() -> res.remove(), 0, 0.5));
        } if (Std.isOfType(msg, DemolishPlaceableMessage)) {
            var placeable = cast(msg, DemolishPlaceableMessage).placeable;
            if (state != None || placeable.planet != currentPlanet || !canPickup()) return false;
            var src = normaliseTheta(bot.theta);
            var dst = normaliseTheta(currentPlanet.getAngleOnSide(placeable.side)-Math.PI/2);
            trace(src, dst);
            state = Travelling;
            if (src != dst) {
                TweenManager.add(new BotPlanetTravelTween(bot, currentPlanet, src, dst, 0, 2));
                TweenManager.add(new DelayedCallTween(() -> MessageManager.sendMessage(new PickUpPlaceableMessage(placeable)), 0, 2));
            } else {
                MessageManager.sendMessage(new PickUpPlaceableMessage(placeable));
            }
        } if (Std.isOfType(msg, PickUpPlaceableMessage)) {
            var placeable = cast(msg, PickUpPlaceableMessage).placeable;
            if (placeable.cost[Triangle])
                TweenManager.add(new DelayedCallTween(getTriangle, 0, 0.5));
            if (placeable.cost[Circle])
                TweenManager.add(new DelayedCallTween(getCircle, 0, 0.5));
            if (placeable.cost[Square])
                TweenManager.add(new DelayedCallTween(getSquare, 0, 0.5));
            state = PickingUp;
            TweenManager.add(new ParabolicMoveTween(placeable.sprite, new Vector2D(placeable.sprite.x, placeable.sprite.y), bot.position, 0, 0.5));
            TweenManager.add(new ParabolicScaleTween(placeable.sprite, 0.5, 0.0, 0, 0.5));
            TweenManager.add(new DelayedCallTween(() -> placeable.remove(), 0, 0.5));
        }
		return false;
	}

    function getTriangle() {
        trace("get triangle");
        MessageManager.sendMessage(new AddResourceToInventoryMessage(Triangle));
        if (tutorialState == Start) {
            tutorialState = Mine;
            MessageManager.sendMessage(new ShowMineMessage());
        }
        triangles += 1;
        state = None;
        MessageManager.sendMessage(new BrightenTrianglesMessage());
    }

    function getSquare() {
        MessageManager.sendMessage(new AddResourceToInventoryMessage(Square));
        if (tutorialState == Mine) {
            tutorialState = Gun;
            MessageManager.sendMessage(new ShowGunMessage());
        }
        squares += 1;
        state = None;
        MessageManager.sendMessage(new BrightenSquaresMessage());
    }

    function getCircle() {
        MessageManager.sendMessage(new AddResourceToInventoryMessage(Circle));
        if (tutorialState == Gun) {
            tutorialState = Done;
            MessageManager.sendMessage(new ShowAllMessage());
        }
        circles += 1;
        state = None;
        MessageManager.sendMessage(new BrightenCirclesMessage());
    }

    function canPickup() : Bool {
        return triangles + circles + squares < 3;
    }

    function decrementResource(r: ResourceType) {
        if (r == Triangle) {
            triangles--;
            if (triangles == 0) MessageManager.sendMessage(new DarkenTrianglesMessage());
        } else if (r == Circle) {
            circles--;
            if (circles == 0) MessageManager.sendMessage(new DarkenCirclesMessage());
        } else {
            squares--;
            if (squares == 0) MessageManager.sendMessage(new DarkenSquaresMessage());
        }
    }

    public function update(dt: Float) {
        for (u in updateables) u.update(dt);
    }
}