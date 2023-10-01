package utilities;

import h2d.Object;
import gamelogic.Placeable;
import hxd.Event;
import gamelogic.Resource;
import gamelogic.Mine;
import gamelogic.Gun;
import gamelogic.Resource.ResourceType;
import gamelogic.Planet;
import graphics.ResourceIcon;

class Message {public function new(){}}

class PhysicsStepDoneMessage extends Message {}
class MineClickedMessage extends Message {}
class BotClickedMessage extends Message {}
class GunClickedMessage extends Message {}
class BeltClickedMessage extends Message {}
class RocketClickedMessage extends Message {}
class RestartMessage extends Message {}
class ShowMineMessage extends Message {}
class ShowGunMessage extends Message {}
class ShowAllMessage extends Message {}
class SystemViewMessage extends Message {}
class DarkenTrianglesMessage extends Message {}
class BrightenTrianglesMessage extends Message {}
class DarkenCirclesMessage extends Message {}
class BrightenCirclesMessage extends Message {}
class DarkenSquaresMessage extends Message {}
class BrightenSquaresMessage extends Message {}
class RocketLaunchedMessage extends Message {}
class VictoryMessage extends Message {}
class ContinueMessage extends Message {}
class MouseClickMessage extends Message {
	public var event: Event;
	public var worldPosition: Vector2D;
	public function new(e: Event, p: Vector2D) {super(); event = e; worldPosition = p;}
}
class KeyUpMessage extends Message {
	public var keycode: Int;
	public function new(k: Int) {super(); keycode = k;}
}
class MouseReleaseMessage extends Message {
	public var event: Event;
	public var worldPosition: Vector2D;
	public function new(e: Event, p: Vector2D) {super(); event = e; worldPosition = p;}
}
class MouseMoveMessage extends Message {
	public var event: Event;
	public var worldPosition: Vector2D;
	public function new(e: Event, p: Vector2D) {super(); event = e; worldPosition = p;}
}
class ResourceClickedMessage extends Message {
	public var resource: Resource;
	public function new(r: Resource) {super(); resource = r;}
}
class BotPickUpResourceMessage extends Message {
	public var resource: Resource;
	public function new(r: Resource) {super(); resource = r;}
}
class AddResourceToInventoryMessage extends Message {
	public var resourceType: ResourceType;
	public function new(r: ResourceType) {super(); resourceType = r;}
}
class DropResourceMessage extends Message {
	public var resourceType: ResourceType;
	public function new(r: ResourceType) {super(); resourceType = r;}
}
class RemoveResourceFromInventoryMessage extends Message {
	public var resourceType: ResourceType;
	public function new(r: ResourceType) {super(); resourceType = r;}
}
class DumpInventoryMessage extends Message {
	public var resourceIcon: ResourceIcon;
	public function new(r: ResourceIcon) {super(); resourceIcon = r;}
}
class PlacedGunClickedMessage extends Message {
	public var gun: Gun;
	public function new(r: Gun) {super(); gun = r;}
}
class BotViewMessage extends Message {
	public var object: Object;
	public var transitTime: Float;
	public var planet: Planet;
	public function new(r: Object, t: Float, p: Planet) {super(); object = r; transitTime = t; planet = p;}
}
class PlanetViewMessage extends Message {
	public var planet: Planet;
	public function new(p: Planet) {super(); planet = p;}
}
class BotLaunchedMessage extends Message {
	public var planet: Planet;
	public function new(p: Planet) {super(); planet = p;}
}
class DemolishPlaceableMessage extends Message {
	public var placeable: Placeable;
	public function new(r: Placeable) {super(); placeable = r;}
}
class PickUpPlaceableMessage extends Message {
	public var placeable: Placeable;
	public function new(r: Placeable) {super(); placeable = r;}
}
class PlanetFocusedMessage extends Message {
	public var planet: Planet;
	public function new(r: Planet) {super(); planet = r;}
}
class PlanetClickedMessage extends Message {
	public var planet: Planet;
	public function new(r: Planet) {super(); planet = r;}
}
class SpawnResourceMessage extends Message {
	public var planet: Planet;
	public var side: Int;
	public var type: ResourceType;
	public function new(t: ResourceType, p: Planet, s: Int) {super(); type = t; planet = p; side = s;}
}
class BeltRemoveResourceMessage extends Message {
	public var planet: Planet;
	public var side: Int;
	public function new(p: Planet, s: Int) {super(); planet = p; side = s;}
}

interface MessageListener {
    public function receiveMessage(msg: Message): Bool;
}

class MessageManager {

    static var listeners = new Array<MessageListener>();

	public static function addListener(l:MessageListener) {
		listeners.push(l);
    }

	public static function removeListener(l:MessageListener) {
		listeners.remove(l);
    }

    public static function send(msg: Message) {
        for (l in listeners)
            if (l.receiveMessage(msg)) return;
		// trace("unconsumed message", msg);
    }

	public static function reset() {
		listeners = [];
	}

}