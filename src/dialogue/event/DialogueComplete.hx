package dialogue.event;

import ecs.event.IEvent;

class DialogueComplete implements IEvent {
	public var nodeName:String;

	public function new(nodeName:String) {
		this.nodeName = nodeName;
	}
}
