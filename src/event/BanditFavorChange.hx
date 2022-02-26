package event;

import ecs.event.IEvent;

class BanditFavorChange implements IEvent {
	public var amount:Int;

	public function new(amount:Int) {
		this.amount = amount;
	}
}
