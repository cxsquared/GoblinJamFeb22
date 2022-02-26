package event;

import ecs.event.IEvent;

class GainSkill implements IEvent {
	public var skill:String;
	public var level = 1;

	public function new() {}
}
