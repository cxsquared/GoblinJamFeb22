package system;

import ecs.component.Transform;
import component.UiBar;
import ecs.Entity;
import ecs.system.IPerEntitySystem;

class UiBarController implements IPerEntitySystem {
	public function new() {}

	public function update(entity:Entity, dt:Float) {
		var uiBar = entity.get(UiBar);
		var t = entity.get(Transform);
		var bar = uiBar.bar;

		bar.setPosition(t.x + uiBar.x, t.y + uiBar.y);
		bar.set(uiBar.value, uiBar.maxValue);
	}

	public var forComponents:Array<Class<Dynamic>> = [UiBar, Transform];
}
