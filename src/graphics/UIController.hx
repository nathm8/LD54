package graphics;

import h2d.Scene;
import h2d.Graphics;
import h2d.Bitmap;
import h2d.Camera;
import h2d.Interactive;
import utilities.MessageManager;
import utilities.Vector2D;

class UIController implements MessageListener {
    var ui: Graphics;
    public var camera: Camera;
    var inventory: Array<ResourceIcon> = [null, null, null];
    var costs: Array<ResourceIcon> = [null, null, null, null, null, null];
    var sprite: Bitmap;

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
        } if (Std.isOfType(msg, RemoveResourceFromInventoryMessage)) {
            var res = cast(msg, RemoveResourceFromInventoryMessage).resourceType;
            for (i in 0...3) {
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
            MessageManager.sendMessage(new DropResourceMessage(res.type));
        } if (Std.isOfType(msg, ShowMineMessage)) {
            sprite.tile = hxd.Res.img.UI1.toTile();
            var mineInteractive = new Interactive(120,120,sprite);
            mineInteractive.x = 37;
            mineInteractive.y = 52;
            mineInteractive.onClick = (e: hxd.Event) -> MessageManager.sendMessage(new MineClickedMessage());
            mineInteractive.cursor = Button;
            costs[0] = new ResourceIcon(ui, Triangle, new Vector2D(92, 215));
        } if (Std.isOfType(msg, ShowGunMessage)) {
            sprite.tile = hxd.Res.img.UI2.toTile();
            var gunInteractive = new Interactive(120,120,sprite);
            gunInteractive.x = 174;
            gunInteractive.y = 52;
            gunInteractive.onClick = (e: hxd.Event) -> MessageManager.sendMessage(new GunClickedMessage());
            gunInteractive.cursor = Button;
            costs[1] = new ResourceIcon(ui, Square, new Vector2D(237, 215));
        } if (Std.isOfType(msg, ShowAllMessage)) {
            sprite.tile = hxd.Res.img.UI4.toTile();
            var beltInteractive = new Interactive(120,120,sprite);
            beltInteractive.x = 304;
            beltInteractive.y = 52;
            beltInteractive.onClick = (e: hxd.Event) -> MessageManager.sendMessage(new BeltClickedMessage());
            beltInteractive.cursor = Button;
            costs[2] = new ResourceIcon(ui, Circle, new Vector2D(373, 215));
            var rocketInteractive = new Interactive(120,120,sprite);
            rocketInteractive.x = 439;
            rocketInteractive.y = 52;
            rocketInteractive.onClick = (e: hxd.Event) -> MessageManager.sendMessage(new RocketClickedMessage());
            rocketInteractive.cursor = Button;
            costs[3] = new ResourceIcon(ui, Triangle, new Vector2D(466, 215));
            costs[4] = new ResourceIcon(ui, Square, new Vector2D(516, 215));
            costs[5] = new ResourceIcon(ui, Circle, new Vector2D(566, 215));
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
}