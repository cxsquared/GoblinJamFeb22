package ecs.system;

import ecs.component.Renderable;
import ecs.component.Animation;

class AnimationController implements IPerEntitySystem {
	public function new() {}

	public function update(entity:Entity, dt:Float) {
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

	public var forComponents:Array<Class<Dynamic>> = [Animation, Renderable];
}
