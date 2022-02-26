package ecs.component;

import h2d.col.Bounds;
import h2d.Console;

class Camera implements IComponent {
	public var target:Entity;
	public var bounds:Bounds;
	public var offsetX:Float;
	public var offsetY:Float;
	public var speed:Float;
	public var deadzone:Float;
	public var zoom:Float;

	public function new(target:Entity, bounds:Bounds, offsetX:Float, offsetY:Float) {
		this.target = target;
		this.bounds = bounds;
		this.offsetX = offsetX;
		this.offsetY = offsetY;
		this.speed = 10;
		this.deadzone = 5;
		this.zoom = 1;
	}

	public function log(console:Console, ?color:Int) {}

	public function debugText():String {
		return '[Camera] target ${target.name}';
	}

	public function remove() {}
}
