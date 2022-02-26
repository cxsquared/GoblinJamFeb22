package ecs.component;

import ecs.utils.MathUtils;
import h2d.Console;

class Velocity implements IComponent {
	public var dx:Float;
	public var dy:Float;
	public var friction:Float;

	public function new(?dx:Float = 0, ?dy:Float = 0, ?friction:Float = .95) {
		this.dx = dx;
		this.dy = dy;
		this.friction = friction;
	}

	public function log(console:Console, ?color:Null<Int>):Void {
		console.log('dx: $dx', color);
		console.log('dy: $dy', color);
	}

	public function debugText():String {
		return '[Velocity] dx: ${MathUtils.floatToStringPrecision(dx, 2)}, dy: ${MathUtils.floatToStringPrecision(dy, 2)}';
	}

	public function remove() {}
}
