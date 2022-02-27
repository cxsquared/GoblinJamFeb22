package ecs.component;

import h2d.Drawable;
import h2d.Console;

class Renderable implements IComponent {
	public var drawable:Drawable;
	public var offsetX:Float = 0;
	public var offsetY:Float = 0;

	// TODO: Maybe pass in a parent so that anims can get added correctly
	// if we pass in null
	public function new(?drawable:Drawable) {
		this.drawable = drawable;
	}

	public function log(console:Console, ?color:Null<Int>):Void {
		console.log(' tile: ${drawable.name}', color);
	}

	public function debugText():String {
		return '[Renderable]';
	}

	public function remove() {
		if (drawable != null) {
			drawable.remove();
		}
	}
}
