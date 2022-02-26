package event;

import ecs.event.IEvent;
import component.Encounter;

class PlayEncounter implements IEvent {
	public var encounter:Encounter;

	public function new(encounter:Encounter) {
		this.encounter = encounter;
	}
}
