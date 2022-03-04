package ecs.component;

import constant.Const;
import ecs.utils.MathUtils;
import h2d.Console;

class Velocity implements IComponent {
	public var dx:Float;
	public var dy:Float;
	public var friction:Float;
	public var accel:Float = Const.TileSize / 2;
	public var maxSpeed:Float = Const.TileSize * 3;

	public function new(?dx:Float = 0, ?dy:Float = 0, ?friction:Float = .85) {
		this.dx = dx;
		this.dy = dy;
		this.friction = friction;
	}

	public function log(console:Console, ?color:Null<Int>):Void {
		console.log('dx: $dx', color);
		console.log('dy: $dy', color);
	}

	public function debugText():String {
		var sb = new StringBuf();
		sb.add('[Velocity] dx: ${MathUtils.floatToStringPrecision(dx, 2)}, dy: ${MathUtils.floatToStringPrecision(dy, 2)}');
		sb.add('\n  accel: ${accel}, maxSpeed: ${maxSpeed}, friction: ${friction}');
		return sb.toString();
	}

	public function remove() {}
}
