package system;

import hxd.Timer;
import ecs.component.Renderable;
import component.Pulse;
import ecs.Entity;
import ecs.system.IPerEntitySystem;

class PulseController implements IPerEntitySystem {
	public function new() {}

	public function update(entity:Entity, dt:Float) {
		var p = entity.get(Pulse);
		var r = entity.get(Renderable);
		var d = r.drawable;

		if (p.initialScale <= 0) {
			p.initialScale = d.scaleX;
		}

		d.setScale(p.initialScale + Math.abs(Math.sin(Timer.frameCount * p.speed)) * p.amount);
	}

	public var forComponents:Array<Class<Dynamic>> = [Pulse, Renderable];
}
