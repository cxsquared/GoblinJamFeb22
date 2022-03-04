package system;

import ecs.system.PerEntitySystemBase;
import hxd.Timer;
import ecs.component.Renderable;
import component.Pulse;
import ecs.Entity;

class PulseController extends PerEntitySystemBase {
	public function new() {
		super([Pulse, Renderable]);
	}

	public override function update(entity:Entity, dt:Float) {
		var p = entity.get(Pulse);
		var r = entity.get(Renderable);
		var d = r.drawable;

		if (p.initialScale <= 0) {
			p.initialScale = d.scaleX;
		}

		p.ticks++;
		d.setScale(p.initialScale + Math.abs(Math.sin(p.ticks * p.speed)) * p.amount);
	}
}
