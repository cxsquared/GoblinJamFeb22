package ecs.system;

import ecs.component.Ui;
import ecs.component.Transform;

class UiRenderer implements IPerEntitySystem {
	public var forComponents:Array<Class<Dynamic>> = [Ui, Transform];

	public function new() {}

	public function update(entity:Entity, dt:Float) {
		var renderable = entity.get(Ui);
		var transform = entity.get(Transform);

		renderable.drawable.setPosition(transform.x, transform.y);
		renderable.drawable.rotation = transform.rotation;
	}
}
