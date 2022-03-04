package component;

import h2d.Console;
import ecs.component.IComponent;

class Pulse implements IComponent {
	public var speed:Float = .75;
	public var amount:Float = 1;
	public var initialScale:Float = -1;
	public var ticks = 0;

	public function new(speed:Float, amount:Float) {
		this.speed = speed;
		this.amount = amount;
	}

	public function log(console:Console, ?color:Int) {}

	public function debugText():String {
		return '[Pulse] speed: $speed, amount: $amount';
	}

	public function remove() {}
}
