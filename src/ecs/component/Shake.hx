package ecs.component;

import h2d.Console;
import ecs.component.IComponent;

class Shake implements IComponent {
	public var shakePower:Float;
	public var time:Float;
	public var startOffsetX:Null<Float> = null;
	public var startOffsetY:Null<Float> = null;

	public function new(shakePower:Float, timeInSeconds:Float) {
		shake(shakePower, timeInSeconds);
	}

	public function shake(shakePower:Float, timeInSeconds:Float) {
		this.shakePower = shakePower;
		this.time = timeInSeconds;
	}

	public function log(console:Console, ?color:Int) {}

	public function debugText():String {
		return '[Shake] power $shakePower, time $time, startOffsetX $startOffsetX, startOffsetY $startOffsetY';
	}

	public function remove() {}
}
