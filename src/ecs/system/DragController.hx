package ecs.system;

import ecs.component.Transform;
import ecs.component.Drag;
import h2d.Scene;

using tweenxcore.Tools;

class DragController implements IPerEntitySystem {
	public var forComponents:Array<Class<Dynamic>> = [Drag, Transform];

	var scene:Scene;

	public function new(scene:Scene) {
		this.scene = scene;
	}

	public function update(entity:Entity, dt:Float) {
		var d = entity.get(Drag);
		var t = entity.get(Transform);
		d.interaction.x = t.x;
		d.interaction.y = t.y;

		if (d.isDragging) {
			t.x = scene.mouseX - t.width / 2;
			t.y = scene.mouseY - t.height / 2;
		}
	}
}
