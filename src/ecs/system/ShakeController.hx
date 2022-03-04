package ecs.system;

import hxd.Math;
import ecs.component.Renderable;
import ecs.component.Shake;
import ecs.Entity;

class ShakeController extends PerEntitySystemBase {
	public function new() {
		super([Shake, Renderable]);
	}

	public override function update(entity:Entity, dt:Float) {
		var shake = entity.get(Shake);
		var r = entity.get(Renderable);

		if (shake.startOffsetX == null || shake.startOffsetY == null) {
			shake.startOffsetX = r.offsetX;
			shake.startOffsetY = r.offsetY;
		}

		shake.time -= dt;

		if (shake.time <= 0) {
			r.offsetX = shake.startOffsetX;
			r.offsetY = shake.startOffsetY;
			entity.remove(Shake);
			return;
		}

		r.offsetX += Math.srand() * shake.shakePower;
		r.offsetY += Math.srand() * shake.shakePower;
	}
}
