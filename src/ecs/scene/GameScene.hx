package ecs.scene;

import h2d.Console;
import h2d.Scene;

class GameScene extends h2d.Object {
	public var console:Console;

	public function new(heapsScene:Scene, console:Console) {
		super(heapsScene);
		this.console = console;
	}

	public function init():Void {
		throw "Must override init()";
	}

	public function update(dt:Float):Void {
		throw "Must override update()";
	}
}
