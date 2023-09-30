package gamelogic;

import gamelogic.Updateable;
import gamelogic.physics.PhysicalWorld;
import graphics.CameraController;
import graphics.UIController;
import h2d.Scene;
import h2d.Camera;
import h2d.Text;
import h2d.col.Point;
import hxd.Timer;
import utilities.MessageManager;

class GameScene extends Scene implements MessageListener {
	
	var updateables = new Array<Updateable>();
	var cameraController: CameraController;
	var uiController: UIController;
	var gameState: GameState;
	
	public function new() {
		super();
		defaultSmooth = true;

		MessageManager.addListener(this);

		var system = new System(this, this);
		updateables.push(system);
		var p = system.getStartingPlanet();
		cameraController = new CameraController(this, p);
		addCamera(cameraController.camera);
		interactiveCamera = cameraController.camera;
		removeCamera(cameras[0]);
		updateables.push(cameraController);
		
		var bot = new Bot(p);
		updateables.push(bot);

		uiController = new UIController(this);
		gameState = new GameState(p, bot);

		// very hacky minimap
		var minimap = new Camera(this);
		minimap.layerVisible = (layer) -> layer == 0 || layer == 2;
		minimap.anchorX = 0.5;
		minimap.anchorY = 0.5;
		minimap.scaleX = 0.045;
		minimap.scaleY = 0.045;
		minimap.x = -7750;
		minimap.y = -7750;
	}

	public function update(dt:Float) {
		PhysicalWorld.update(dt);
		for (u in updateables)
			u.update(dt);
	}

	public function receiveMessage(msg:Message):Bool {
		if (Std.isOfType(msg, MouseMoveMessage)) {
			var params = cast(msg, MouseMoveMessage);
			if (params.event.relY < 750) {
				interactiveCamera = cameraController.camera;
			}
			else {
				interactiveCamera = uiController.camera;
			}
		}
		return false;
	}
}
