package ecs.component;

import h2d.Drawable;
import h2d.Console;

class Ui implements IComponent {
	public var drawable(default, null):Drawable;

	public function new(drawable:Drawable) {
		this.drawable = drawable;
	}

	public function log(console:Console, ?color:Int) {}

	public function debugText():String {
		return '[Ui]';
	}

	public function remove() {
		drawable.remove();
	}
}
