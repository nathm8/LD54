package gamelogic;

import utilities.Vector2D;

interface Placeable {
    public function setPosition(v: Vector2D): Void;
    public function place(): Void;
}