package;

import utilities.MessageManager.MessageListener;
import utilities.SoundManager;
import gamelogic.GameScene;
import gamelogic.physics.PhysicalWorld;
import graphics.TweenManager;
import h2d.col.Point;
import utilities.MessageManager;
import utilities.RNGManager;

class Main extends hxd.App implements MessageListener {

	var gameScene: GameScene;

	static function main() {
		new Main();
	}

	override private function init() {
		// boilerplate
		RNGManager.initialise();
		hxd.Res.initEmbed();
		// background
		h3d.Engine.getCurrent().backgroundColor = 0x0006071B;
		// controls
		hxd.Window.getInstance().addEventTarget(onEvent);	
		// gamelogic
		SoundManager.initialise();
		newGame();
	}
	
	override function update(dt:Float) {
		if (gameScene != null)
			gameScene.update(dt);
		TweenManager.update(dt);
	}
	
	function newGame() {
		PhysicalWorld.reset();
		TweenManager.reset();
		MessageManager.reset();
		gameScene = new GameScene();
		setScene2D(gameScene);
		SoundManager.reset();
		MessageManager.addListener(this);
	}

	function onEvent(event:hxd.Event) {
		switch (event.kind) {
			case EPush:
				var p = new Point(event.relX, event.relY);
				s2d.camera.sceneToCamera(p);
				MessageManager.send(new MouseClickMessage(event, p));
			case ERelease:
				var p = new Point(event.relX, event.relY);
				s2d.camera.sceneToCamera(p);
				MessageManager.send(new MouseReleaseMessage(event, p));
			case EMove:
				var p = new Point(event.relX, event.relY);
				s2d.camera.sceneToCamera(p);
				MessageManager.send(new MouseMoveMessage(event, p));
			case EKeyDown:
				switch (event.keyCode) {
					case hxd.Key.R:
						MessageManager.send(new RestartMessage());
					// case hxd.Key.ENTER:
				}
			case EKeyUp:
				MessageManager.send(new KeyUpMessage(event.keyCode));
			case _:
		}
	}

	public function receiveMessage(msg:Message):Bool {
		if (Std.isOfType(msg, RestartMessage)) {
			newGame();
		}
		return false;
	}
}