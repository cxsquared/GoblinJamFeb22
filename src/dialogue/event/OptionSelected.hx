package dialogue.event;

import ecs.event.IEvent;

class OptionSelected implements IEvent {
	public var index:Int;

	public function new(index:Int) {
		this.index = index;
	}
}
