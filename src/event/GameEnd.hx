package event;

import ecs.event.IEvent;

class GameEnd implements IEvent {
	public var winner:Bool;
	public var textNode:String;

	public function new(winner:Bool, textNode:String) {
		this.winner = winner;
		this.textNode = textNode;
	}
}
