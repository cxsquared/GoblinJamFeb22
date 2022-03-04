package ecs.system;

import ecs.component.Transform;
import ecs.component.Drag;
import h2d.Scene;

using tweenxcore.Tools;

class DragController extends PerEntitySystemBase {
	var scene:Scene;

	public function new(scene:Scene) {
		super([Drag, Transform]);
		this.scene = scene;
	}

	public override function update(entity:Entity, dt:Float) {
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
