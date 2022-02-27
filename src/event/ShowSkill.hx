package event;

import ecs.event.IEvent;
import ui.RandomSkill;

class ShowSkill implements IEvent {
	public var randomSkill:RandomSkill;
	public function new(skill:RandomSkill){
		randomSkill=skill;
	}
}
