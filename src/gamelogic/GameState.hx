package gamelogic;

import h2d.Bitmap;
import h2d.Graphics;
import gamelogic.Mine;
import gamelogic.Updateable;
import gamelogic.Resource.ResourceType;
import graphics.TweenManager;
import graphics.TweenManager.BotPlanetTravelTween;
import graphics.Selection;
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
    Moving;
    Aiming;
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
    var squares = 1;
    var state = None;
    var tutorialState = Start;
    var currentPlanet: Planet;
    var bot: Bot;
    var botGhost: Bitmap;
    var selection: Selection;

    // var graphics: Graphics;
    var updateables = new Array<Updateable>();
    var placing: Placeable;

    public function new(p: Planet, b: Bot) {
        MessageManager.addListener(this);
        currentPlanet = p;
        bot = b;
        MessageManager.send(new SpawnResourceMessage(Triangle, currentPlanet, 1));
        
        // debug
        // graphics = new Graphics(currentPlanet.graphics);
        MessageManager.send(new ShowGunMessage());
    }

    public function receiveMessage(msg:Message):Bool {
        if (Std.isOfType(msg, BotClickedMessage) && state == None) {
            state = Moving;
            botGhost = new Bitmap(hxd.Res.img.BotBase.toTile().center(), currentPlanet.graphics);
            botGhost.alpha = 0.5;
            botGhost.visible = false;
		} if (Std.isOfType(msg, MineClickedMessage)) {
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
		} if (Std.isOfType(msg, PlanetFocusedMessage)) {
            trace(state);
            if (state != Aiming) return false;
            var planet = cast(msg, PlanetFocusedMessage).planet;
            trace("planet focused");
            if (selection != null)
                selection.remove();
            selection = new Selection(planet.graphics);
		} if (Std.isOfType(msg, PlanetClickedMessage)) {
            if (state != Aiming) return false;
            var planet = cast(msg, PlanetClickedMessage).planet;
            selection.remove();
            selection = null;
		} if (Std.isOfType(msg, PlacedGunClickedMessage)) {
            var gun = cast(msg, PlacedGunClickedMessage).gun;
            if (state == None)
                MessageManager.send(new DemolishPlaceableMessage(gun));
            else if (state == Travelling) {
                TweenManager.add(new DelayedCallTween(() -> state = Aiming, 0, 1.6));
                TweenManager.add(new DelayedCallTween(() -> TweenManager.add(new ParabolicScaleTween(bot.sprite, 1.0, 0.01, 0, 0.5)), 0, 1.5));
                TweenManager.add(new DelayedCallTween(() -> MessageManager.send(new SystemViewMessage()), 0, 2.0));
                TweenManager.add(new DelayedCallTween(() -> TweenManager.add(new LinearRotationTween(gun.turret, 0, -Math.PI/2, 0, 2.0)), 0, 2.0));
            }
		} if (Std.isOfType(msg, MouseMoveMessage)) {
            var p = new Vector2D(hxd.Window.getInstance().mouseX, hxd.Window.getInstance().mouseY);
            p -= new Vector2D(500, 500);
            var i = currentPlanet.getClosestSide(normaliseTheta(p.angle()));
            if (state == Placing) {
                var v = currentPlanet.getBuildingPositionOnSide(i);
                placing.setPosition(v);
            } if (state == Moving) {
                botGhost.visible = true;
                var p = new Vector2D(currentPlanet.planetRadius + 50, 0).rotate(p.angle());
                botGhost.x = p.x; botGhost.y = p.y;
                botGhost.rotation = p.angle() + Math.PI/2;
            }
        } if (Std.isOfType(msg, MouseReleaseMessage)) {
            var p = new Vector2D(hxd.Window.getInstance().mouseX, hxd.Window.getInstance().mouseY);
            p -= new Vector2D(500, 500);
            var i = currentPlanet.getClosestSide(normaliseTheta(p.angle()));
            if (state == Placing && !currentPlanet.occupied[i]) {
                state = None;
                placing.place(i);
                currentPlanet.occupied[i] = true;
                for (res => bool in placing.cost) {
                    if (bool) {
                        MessageManager.send(new RemoveResourceFromInventoryMessage(res));
                        decrementResource(res);
                    }
                }
                placing = null;
            } if (state == Moving) {
                state = Travelling;
                botGhost.remove();
                botGhost = null;
                bot.moveTo(p.angle());
                TweenManager.add(new DelayedCallTween(() -> state = None, 0, 1.5));
            }
        } if (Std.isOfType(msg, ResourceClickedMessage)) {
            var res = cast(msg, ResourceClickedMessage).resource;
            if (state == None && res.planet == currentPlanet && canPickup()) {
                state = Travelling;
                if (currentPlanet.getClosestSide(bot.theta) != res.side) {
                    bot.moveTo(currentPlanet.getAngleOnSide(res.side)-Math.PI/2);
                    TweenManager.add(new DelayedCallTween(() -> MessageManager.send(new PickUpResourceMessage(res)), 0, 1.5));
                } else
                    MessageManager.send(new PickUpResourceMessage(res));
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
            currentPlanet.surfaceResources[res.side] = null;
            state = PickingUp;
            TweenManager.add(new ParabolicMoveTween(res.sprite, new Vector2D(res.sprite.x, res.sprite.y), bot.position, 0, 0.5));
            TweenManager.add(new ParabolicScaleTween(res.sprite, 1.0, 0.0, 0, 0.5));
            TweenManager.add(new DelayedCallTween(() -> res.remove(), 0, 0.5));
        } if (Std.isOfType(msg, DemolishPlaceableMessage)) {
            var placeable = cast(msg, DemolishPlaceableMessage).placeable;
            if (state != None || placeable.planet != currentPlanet || !canPickup()) return false;
            state = Travelling;
            if (currentPlanet.getClosestSide(bot.theta) != placeable.side) {
                bot.moveTo(currentPlanet.getAngleOnSide(placeable.side)-Math.PI/2);
                TweenManager.add(new DelayedCallTween(() -> MessageManager.send(new PickUpPlaceableMessage(placeable)), 0, 1.5));
            } else
                MessageManager.send(new PickUpPlaceableMessage(placeable));
        } if (Std.isOfType(msg, PickUpPlaceableMessage)) {
            var placeable = cast(msg, PickUpPlaceableMessage).placeable;
            if (placeable.cost[Triangle])
                TweenManager.add(new DelayedCallTween(getTriangle, 0, 0.5));
            if (placeable.cost[Circle])
                TweenManager.add(new DelayedCallTween(getCircle, 0, 0.5));
            if (placeable.cost[Square])
                TweenManager.add(new DelayedCallTween(getSquare, 0, 0.5));
            state = PickingUp;
            currentPlanet.occupied[placeable.side] = false;
            TweenManager.add(new ParabolicMoveTween(placeable.sprite, new Vector2D(placeable.sprite.x, placeable.sprite.y), bot.position, 0, 0.5));
            TweenManager.add(new ParabolicScaleTween(placeable.sprite, 0.5, 0.0, 0, 0.5));
            TweenManager.add(new DelayedCallTween(() -> placeable.remove(), 0, 0.5));
        }
		return false;
	}

    function getTriangle() {
        MessageManager.send(new AddResourceToInventoryMessage(Triangle));
        if (tutorialState == Start) {
            tutorialState = Mine;
            MessageManager.send(new ShowMineMessage());
        }
        triangles += 1;
        state = None;
        MessageManager.send(new BrightenTrianglesMessage());
    }

    function getSquare() {
        MessageManager.send(new AddResourceToInventoryMessage(Square));
        if (tutorialState == Mine) {
            tutorialState = Gun;
            MessageManager.send(new ShowGunMessage());
        }
        squares += 1;
        state = None;
        MessageManager.send(new BrightenSquaresMessage());
    }

    function getCircle() {
        MessageManager.send(new AddResourceToInventoryMessage(Circle));
        if (tutorialState == Gun) {
            tutorialState = Done;
            MessageManager.send(new ShowAllMessage());
        }
        circles += 1;
        state = None;
        MessageManager.send(new BrightenCirclesMessage());
    }

    function canPickup() : Bool {
        return triangles + circles + squares < 3;
    }

    function decrementResource(r: ResourceType) {
        if (r == Triangle) {
            triangles--;
            if (triangles == 0) MessageManager.send(new DarkenTrianglesMessage());
        } else if (r == Circle) {
            circles--;
            if (circles == 0) MessageManager.send(new DarkenCirclesMessage());
        } else {
            squares--;
            if (squares == 0) MessageManager.send(new DarkenSquaresMessage());
        }
    }

    public function update(dt: Float) {
        for (u in updateables) u.update(dt);
    }
}