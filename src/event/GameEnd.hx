package event;

import ecs.event.IEvent;

class GameEnd implements IEvent {
	public var winner:Bool;

	public function new(winner:Bool) {
		this.winner = winner;
	}
}
