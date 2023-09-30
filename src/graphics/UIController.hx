package graphics;

import h2d.Scene;
import h2d.Graphics;
import h2d.Bitmap;
import h2d.Camera;
import h2d.Interactive;
import utilities.MessageManager;

class UIController {
    var ui: Graphics;
    public var camera: Camera;

    public function new(s: Scene) {
        ui = new Graphics();
		ui.beginFill(0x333333);
		ui.drawRect(0, 0, 750, 250);
        ui.y = 750;
		s.add(ui, 1);
		camera = new Camera(s);
		camera.layerVisible = (layer) -> layer == 1;

        var sprite = new Bitmap(hxd.Res.img.UI1.toTile(), ui);

        // var mine = new Bitmap(hxd.Res.img.Mine.toTile().center(), ui);
        // mine.x = 187-93.75; mine.y = 125;
        var mineInteractive = new Interactive(120,120,sprite);
        mineInteractive.x = 37;
        mineInteractive.y = 52;
        mineInteractive.onClick = mineClicked;
        mineInteractive.cursor = Button;
    }

    function mineClicked(e: hxd.Event) {
        MessageManager.sendMessage(new MineClickedMessage());
    }
}