package ecs.system;

import ecs.component.Renderable;
import ecs.component.Animation;

class AnimationController extends PerEntitySystemBase {
	public function new() {
		super([Animation, Renderable]);
	}

	public override function update(entity:Entity, dt:Float) {
		var r = entity.get(Renderable);
		var a = entity.get(Animation);

		if (a.isDirty) {
			a.isDirty = false;
			var parent = r.drawable.parent;
			var info = a.getCurrent();
			parent.removeChild(r.drawable);
			parent.addChild(info.anim);
			r.drawable = info.anim;
			r.offsetX = info.offsetX;
			r.offsetY = info.offsetY;
		}
	}
}
