package dialogue.event;

import ecs.event.IEvent;

class StartDialogueNode implements IEvent {
	public var node:String;

	public function new(node:String) {
		this.node = node;
	}
}
