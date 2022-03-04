package ecs.system;

import ecs.component.Ui;
import ecs.component.Transform;

class UiRenderer extends PerEntitySystemBase {
	public function new() {
		super([Ui, Transform]);
	}

	public override function update(entity:Entity, dt:Float) {
		var renderable = entity.get(Ui);
		var transform = entity.get(Transform);

		renderable.drawable.setPosition(transform.x, transform.y);
		renderable.drawable.rotation = transform.rotation;
	}
}
