package system;

import ecs.system.PerEntitySystemBase;
import ecs.component.Transform;
import component.UiBar;
import ecs.Entity;

class UiBarController extends PerEntitySystemBase {
	public function new() {
		super([UiBar, Transform]);
	}

	public override function update(entity:Entity, dt:Float) {
		var uiBar = entity.get(UiBar);
		var t = entity.get(Transform);
		var bar = uiBar.bar;

		bar.setPosition(t.x + uiBar.x, t.y + uiBar.y);
		bar.set(uiBar.value, uiBar.maxValue);
	}
}
