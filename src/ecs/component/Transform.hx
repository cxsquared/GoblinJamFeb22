package ecs.component;

import ecs.utils.MathUtils;
import h2d.Console;

class Transform implements IComponent {
	public var x(default, set):Float; // pixel position
	public var y(default, set):Float; // pixel position
	public var cx(default, null):Int; // grid position
	public var cy(default, null):Int; // grid position
	public var xr(default, null):Float; // sub-grid position ratio
	public var yr(default, null):Float; // sub-grid position ratio
	public var rotation:Float; // In radians
	public var width:Float;
	public var height:Float;

	public function new(?x:Float = 0, ?y:Float = 0, ?width:Float = 0, ?height:Float = 0) {
		this.x = x;
		this.y = y;
		this.width = width;
		this.height = height;
		this.rotation = 0;
	}

	public function log(console:Console, ?color:Null<Int>):Void {
		console.log('x: $x', color);
		console.log('y: $y', color);
		console.log('width: $width', color);
		console.log('height: $height', color);
	}

	public function set_x(newX:Float) {
		cx = Std.int(x / 16); // TODO make this a tile grid var somewhere
		xr = (newX - cx * 16) / 16;
		return x = newX;
	}

	public function set_y(newY:Float) {
		cy = Std.int(y / 16); // TODO make this a tile grid var somewhere
		yr = (newY - cy * 16) / 16;
		return y = newY;
	}

	public function debugText():String {
		var sb = new StringBuf();
		sb.add("[Transform]");
		sb.add(' x: ${MathUtils.floatToStringPrecision(x, 2)}, y: ${MathUtils.floatToStringPrecision(y, 2)}');
		sb.add('\ncx: $cx, cy: $cy');
		return sb.toString();
	}

	public function remove() {}
}
