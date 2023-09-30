package gamelogic;

import gamelogic.Resource.ResourceType;
import utilities.Vector2D;

interface Placeable extends Updateable {
    public var side: Int;
    public var planet: Planet;
    public var sprite: h2d.Bitmap;
    public var cost: Map<ResourceType, Bool>;
    public function setPosition(v: Vector2D): Void;
    public function place(i: Int): Void;
    public function remove(): Void;
}