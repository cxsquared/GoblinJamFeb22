package system;

import event.PlayEncounter;
import dn.heaps.slib.SpriteLib.FrameData;
import ecs.utils.MathUtils;
import component.Player;
import ecs.event.EventBus;
import ecs.component.Collidable;
import component.Encounter;
import ecs.Entity;
import ecs.system.IPerEntitySystem;

class EncounterController implements IPerEntitySystem {
	var eventBus:EventBus;
	var firstEncounter = false;

	public function new(eventBus:EventBus) {
		this.eventBus = eventBus;
	}

	public function update(entity:Entity, dt:Float) {
		var c = entity.get(Collidable);
		var e = entity.get(Encounter);

		if (c.justEntered && c.event != null && c.event.target.has(Player)) {
			if (firstEncounter == false) {
				firstEncounter = true;
				eventBus.publishEvent(new PlayEncounter(e));
				return;
			}

			if (MathUtils.roll(3) == 3) {
				eventBus.publishEvent(new PlayEncounter(e));
			}
		}
	}

	public var forComponents:Array<Class<Dynamic>> = [Encounter, Collidable];
}
