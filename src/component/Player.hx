package component;

import constant.Skill;
import ecs.component.IComponent;
import h2d.Console;

class Player implements IComponent {
	public var accel = 25;
	public var maxSpeed = 100;
	public var skills = new Array<Skill>();
	public var health = 100;

	public function new() {}

	public function log(console:Console, ?color:Int) {}

	public function remove() {}

	public function debugText():String {
		return '[Player] accel: $accel, maxSpeed: $maxSpeed';
	}
}
