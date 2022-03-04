package system;

import ecs.system.PerEntitySystemBase;
import event.PlayEncounter;
import dn.heaps.slib.SpriteLib.FrameData;
import ecs.utils.MathUtils;
import component.Player;
import ecs.event.EventBus;
import ecs.component.Collidable;
import component.Encounter;
import ecs.Entity;

class EncounterController extends PerEntitySystemBase {
	var eventBus:EventBus;
	var firstEncounter = false;

	public function new(eventBus:EventBus) {
		super([Encounter, Collidable]);
		this.eventBus = eventBus;
	}

	public override function update(entity:Entity, dt:Float) {
		var c = entity.get(Collidable);
		var e = entity.get(Encounter);

		if (c.justEntered && c.event != null && c.event.target.has(Player)) {
			if (firstEncounter == false) {
				firstEncounter = true;
				eventBus.publishEvent(new PlayEncounter(e));
				return;
			}

			if (MathUtils.roll(10) > 6) {
				eventBus.publishEvent(new PlayEncounter(e));
			}
		}
	}
}
