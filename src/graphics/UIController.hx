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

    function mineClicked(e: hxd.Event) {
        MessageManager.sendMessage(new MineClickedMessage());
    }

    public function receiveMessage(msg:Message):Bool {
        if (Std.isOfType(msg, AddResourceToInventoryMessage)) {
            var res = cast(msg, AddResourceToInventoryMessage).resourceType;
            for (i in 0...3) {
                if (inventory[i] == null) {
                    inventory[i] = new ResourceIcon(ui, res, new Vector2D(668, 51+70*i));
                    break;
                }
            }
        } if (Std.isOfType(msg, ShowMine)) {
            sprite.tile = hxd.Res.img.UI1.toTile();
            var mineInteractive = new Interactive(120,120,sprite);
            mineInteractive.x = 37;
            mineInteractive.y = 52;
            mineInteractive.onClick = mineClicked;
            mineInteractive.cursor = Button;
            new ResourceIcon(ui, Triangle, new Vector2D(90, 215));
        }
        return false;
    }
}