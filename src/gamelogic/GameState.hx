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

class GameState implements MessageListener implements Updateable {

    var circles = 0;
    var triangles = 1;
    var squares = 0;
    var state = None;
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
            if (state == None && res.planet == currentPlanet) {
                trace("bot naving to res");
                trace(bot.theta, currentPlanet.getAngleOnSide(res.side)- Math.PI/2/2);
                state = BotTravellingToResource;
                TweenManager.add(new BotPlanetTravelTween(bot, currentPlanet, bot.theta, currentPlanet.getAngleOnSide(res.side)-Math.PI/2, 0, 2));
            }
        } if (Std.isOfType(msg, SpawnResourceMessage)) {
            var params = cast(msg, SpawnResourceMessage);
            new Resource(params.type, params.planet, params.side);
        }
		return false;
	}

    public function update(dt: Float) {
        for (u in updateables) u.update(dt);
    }
}