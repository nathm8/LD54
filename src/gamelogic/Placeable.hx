package gamelogic;

import utilities.Vector2D;

interface Placeable extends Updateable {
    public function setPosition(v: Vector2D): Void;
    public function place(i: Int): Void;
}