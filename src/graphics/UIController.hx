package graphics;

import h2d.Text;
import gamelogic.Updateable;
import h2d.Scene;
import h2d.Graphics;
import h2d.Bitmap;
import h2d.Camera;
import h2d.Interactive;
import utilities.MessageManager;
import graphics.TweenManager;
import utilities.Vector2D;

class UIController implements MessageListener implements Updateable {
    var ui: Graphics;
    public var camera: Camera;
    var inventory: Array<ResourceIcon> = [null, null, null];
    var costs: Array<ResourceIcon> = [null, null, null, null, null, null];
    var sprite: Bitmap;
    var rocketsLaunched = 0;
    var time = 0.0;
    var rocketsText: Text;
    var timeText: Text;
    var rocketsPerMinute: Text;

    public function new(s: Scene) {
        ui = new Graphics();
		ui.beginFill(0x333333);
		ui.drawRect(0, 0, 750, 250);
        ui.y = 750;
		s.add(ui, 1);
		camera = new Camera(s);
		camera.layerVisible = (layer) -> layer == 1;

        sprite = new Bitmap(hxd.Res.img.UI0.toTile(), ui);

        MessageManager.addListener(this);

        timeText= new h2d.Text(hxd.res.DefaultFont.get(), ui);
		timeText.smooth = false;
		timeText.scale(2);
		timeText.textAlign = Left;
        timeText.textColor = 0xDDDDDD;
        timeText.x = 25;
        timeText.y = -725;

        rocketsText= new h2d.Text(hxd.res.DefaultFont.get(), timeText);
		rocketsText.smooth = false;
		rocketsText.textAlign = Left;
        rocketsText.textColor = 0xDDDDDD;
        rocketsText.y = 25;

        rocketsPerMinute= new h2d.Text(hxd.res.DefaultFont.get(), rocketsText);
		rocketsPerMinute.smooth = false;
		rocketsPerMinute.textAlign = Left;
        rocketsPerMinute.textColor = 0xDDDDDD;
        rocketsPerMinute.y = 25;

        rocketsText.visible = false;
        timeText.visible = false;
        rocketsPerMinute.visible = false;
    }

    function victory() {
        var splash = new Bitmap(hxd.Res.img.VictorySplash.toTile().center(), ui);
        splash.x = 500;
        splash.y = -300;
        splash.color = new h3d.Vector(0.2,0.2,0.2,1);

        var title= new h2d.Text(hxd.res.DefaultFont.get(), splash);
		title.smooth = false;
		title.scale(7);
		title.textAlign = Center;
        title.textColor = 0xDDDDDD;
        title.x = 0;
        title.y = -220;
        title.text = "You have Won!";

        var bot = new Bitmap(hxd.Res.img.BotBase.toTile().center(), splash);
        bot.x = 0;
        bot.y = -45;
        bot.scale(2);
        var face = new Bitmap(hxd.Res.img.BotHappy2.toTile().center(), bot);

        var text = new h2d.Text(hxd.res.DefaultFont.get(), splash);
		text.smooth = false;
		text.scale(4);
		text.textAlign = Center;
        text.textColor = 0xBBBBBB;
        text.x = 0;
        text.y = 25;
        text.text = "";

        var continueButton = new h2d.Text(hxd.res.DefaultFont.get(), splash);
		continueButton.smooth = false;
		continueButton.scale(5);
		continueButton.textAlign = Center;
        continueButton.textColor = 0xDDDDDD;
        continueButton.x = 0;
        continueButton.y = 120;
        continueButton.text = "Continue";
        continueButton.visible = false;
        TweenManager.add(new GlowInfiniteTween(continueButton, 0, 1.5));

        var interactive = new Interactive(continueButton.getBounds().width, continueButton.getBounds().height, continueButton);
        interactive.x = -continueButton.getBounds().width/2;
        interactive.y = -continueButton.getBounds().height/2;
        interactive.onClick = (e: hxd.Event) -> {splash.remove(); showRocketStats();}

        TweenManager.add(new DelayedCallTween(()->text.text=".",0,1));
        TweenManager.add(new DelayedCallTween(()->text.text="..",0,2));
        TweenManager.add(new DelayedCallTween(()->text.text="...",0,3));
        TweenManager.add(new DelayedCallTween(()->{text.text="...Would you like to win more?";continueButton.visible=true;face.tile = hxd.Res.img.BotSmug.toTile().center();},0,4.5));
    }

    function showRocketStats(){
        MessageManager.send(new ContinueMessage());
        rocketsText.visible = true;
        timeText.visible = true;
        rocketsPerMinute.visible = true;
    }

    function defeat() {
        var splash = new Bitmap(hxd.Res.img.VictorySplash.toTile().center(), ui);
        splash.x = 500;
        splash.y = -300;
        splash.color = new h3d.Vector(0.2,0.2,0.2,1);

        var title= new h2d.Text(hxd.res.DefaultFont.get(), splash);
		title.smooth = false;
		title.scale(7);
		title.textAlign = Center;
        title.textColor = 0xDDDDDD;
        title.x = 0;
        title.y = -220;
        title.text = "Defeat";

        var bot = new Bitmap(hxd.Res.img.BotLose.toTile().center(), splash);
        bot.x = 0;
        bot.y = -45;
        bot.scale(2);

        var text = new h2d.Text(hxd.res.DefaultFont.get(), splash);
		text.smooth = false;
		text.scale(3);
		text.textAlign = Center;
        text.textColor = 0xBBBBBB;
        text.x = 0;
        text.y = 25;
        text.text = "You are stranded without\n resources or means of escape";

        var continueButton = new h2d.Text(hxd.res.DefaultFont.get(), splash);
		continueButton.smooth = false;
		continueButton.scale(5);
		continueButton.textAlign = Center;
        continueButton.textColor = 0xDDDDDD;
        continueButton.x = 0;
        continueButton.y = 120;
        continueButton.text = "Restart";
        TweenManager.add(new GlowInfiniteTween(continueButton, 0, 1.5));

        var interactive = new Interactive(continueButton.getBounds().width, continueButton.getBounds().height, continueButton);
        interactive.x = -continueButton.getBounds().width/2;
        interactive.y = -continueButton.getBounds().height/2;
        interactive.onClick = (e: hxd.Event) -> MessageManager.send(new RestartMessage());
    }

    public function receiveMessage(msg:Message):Bool {
        if (Std.isOfType(msg, AddResourceToInventoryMessage)) {
            var res = cast(msg, AddResourceToInventoryMessage).resourceType;
            for (i in 0...3) {
                if (inventory[i] == null) {
                    inventory[i] = new ResourceIcon(ui, res, new Vector2D(668, 52+73*i));
                    break;
                }
            }
        } if (Std.isOfType(msg, VictoryMessage)) {
            victory();
        } if (Std.isOfType(msg, FadeToBlackMessage)) {
            var black = new Graphics(ui);
            black.beginFill(0x000000);
            black.drawRect(0,-750,1000,1000);

            TweenManager.add(new FadeInTween(black,0,8));
            TweenManager.add(new DelayedCallTween(()->defeat(),0,8));
        } if (Std.isOfType(msg, RocketLaunchedMessage)) {
                rocketsLaunched++;
        } if (Std.isOfType(msg, RemoveResourceFromInventoryMessage)) {
            var res = cast(msg, RemoveResourceFromInventoryMessage).resourceType;
            for (i in 0...3) {
                if (inventory[i] == null) continue;
                if (inventory[i].type == res) {
                    inventory[i].remove();
                    inventory[i] = null;
                    break;
                }
            } 
        } if (Std.isOfType(msg, DumpInventoryMessage)) {
            var res = cast(msg, DumpInventoryMessage).resourceIcon;
            for (i in 0...3) {
                if (inventory[i] == res) {
                    inventory[i].remove();
                    inventory[i] = null;
                    break;
                }
            }
            MessageManager.send(new DropResourceMessage(res.type));
        } if (Std.isOfType(msg, ShowMineMessage)) {
            sprite.tile = hxd.Res.img.UI1.toTile();
            var mineInteractive = new Interactive(120,120,sprite);
            mineInteractive.x = 37;
            mineInteractive.y = 52;
            mineInteractive.onClick = (e: hxd.Event) -> MessageManager.send(new MineClickedMessage());
            mineInteractive.cursor = Button;
            costs[0] = new ResourceIcon(ui, Triangle, new Vector2D(92, 215));
        } if (Std.isOfType(msg, ShowGunMessage)) {
            sprite.tile = hxd.Res.img.UI2.toTile();
            var gunInteractive = new Interactive(120,120,sprite);
            gunInteractive.x = 174;
            gunInteractive.y = 52;
            gunInteractive.onClick = (e: hxd.Event) -> MessageManager.send(new GunClickedMessage());
            gunInteractive.cursor = Button;
            costs[1] = new ResourceIcon(ui, Square, new Vector2D(237, 215), true);
        } if (Std.isOfType(msg, ShowAllMessage)) {
            sprite.tile = hxd.Res.img.UI4.toTile();
            var beltInteractive = new Interactive(120,120,sprite);
            beltInteractive.x = 304;
            beltInteractive.y = 52;
            beltInteractive.onClick = (e: hxd.Event) -> MessageManager.send(new BeltClickedMessage());
            beltInteractive.cursor = Button;
            costs[2] = new ResourceIcon(ui, Circle, new Vector2D(373, 215), true);
            var rocketInteractive = new Interactive(120,120,sprite);
            rocketInteractive.x = 439;
            rocketInteractive.y = 52;
            rocketInteractive.onClick = (e: hxd.Event) -> MessageManager.send(new RocketClickedMessage());
            rocketInteractive.cursor = Button;
            costs[3] = new ResourceIcon(ui, Triangle, new Vector2D(456, 215), true);
            costs[4] = new ResourceIcon(ui, Square, new Vector2D(506, 215), true);
            costs[5] = new ResourceIcon(ui, Circle, new Vector2D(560, 215), true);
        } if (Std.isOfType(msg, DarkenTrianglesMessage)) {
            darkenTriangles();
        } if (Std.isOfType(msg, BrightenTrianglesMessage)) {
            brightenTriangles();
        } if (Std.isOfType(msg, DarkenSquaresMessage)) {
            darkenSquares();
        } if (Std.isOfType(msg, BrightenSquaresMessage)) {
            brightenSquares();
        } if (Std.isOfType(msg, DarkenCirclesMessage)) {
            darkenCircles();
        } if (Std.isOfType(msg, BrightenCirclesMessage)) {
            brightenCircles();
        }
        return false;
    }

    function darkenTriangles() {
        if (costs[0] != null)
            costs[0].darken();
        if (costs[3] != null)
            costs[3].darken();
    }

    function brightenTriangles() {
        if (costs[0] != null)
            costs[0].brighten();
        if (costs[3] != null)
            costs[3].brighten();
    }

    function brightenCircles() {
        if (costs[2] != null)
            costs[2].brighten();
        if (costs[5] != null)
            costs[5].brighten();
    }

    function darkenCircles() {
        if (costs[2] != null)
            costs[2].darken();
        if (costs[5] != null)
            costs[5].darken();
    }

    function brightenSquares() {
        if (costs[1] != null)
            costs[1].brighten();
        if (costs[4] != null)
            costs[4].brighten();
    }

    function darkenSquares() {
        if (costs[1] != null)
            costs[1].darken();
        if (costs[4] != null)
            costs[4].darken();
    }

    public function update(dt: Float) {
        time += dt;

        timeText.text = "Time: "+Std.string(Math.round(time));
        rocketsText.text = "Rockets: "+Std.string(rocketsLaunched);
        var s = Std.string(rocketsLaunched/time*60);
        var i = s.indexOf(".");
        s = s.substring(0,i+2);
        rocketsPerMinute.text = "Rockets\\m: "+s;
    }
}