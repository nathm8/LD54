package utilities;

import gamelogic.Resource;
import hxd.Event;
import gamelogic.Resource.ResourceType;
import gamelogic.Planet;

class Message {public function new(){}}

class PhysicsStepDoneMessage extends Message {}
class MineClickedMessage extends Message {}
class RestartMessage extends Message {}
class ShowMine extends Message {}
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
class PickUpResourceMessage extends Message {
	public var resource: Resource;
	public function new(r: Resource) {super(); resource = r;}
}
class AddResourceToInventoryMessage extends Message {
	public var resourceType: ResourceType;
	public function new(r: ResourceType) {super(); resourceType = r;}
}
class SpawnResourceMessage extends Message {
	public var planet: Planet;
	public var side: Int;
	public var type: ResourceType;
	public function new(t: ResourceType, p: Planet, s: Int) {super(); type = t; planet = p; side = s;}
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

    public static function sendMessage(msg: Message) {
        for (l in listeners)
            if (l.receiveMessage(msg)) return;
		// trace("unconsumed message", msg);
    }

	public static function reset() {
		listeners = [];
	}

}