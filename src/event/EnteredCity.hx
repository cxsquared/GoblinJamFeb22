package event;

import ecs.event.IEvent;
import component.City;

class EnteredCity implements IEvent {
	public var city:City;

	public function new(city:City) {
		this.city = city;
	}
}
