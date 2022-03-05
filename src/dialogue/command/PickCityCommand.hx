package dialogue.command;

import event.PickCity;
import ecs.event.EventBus;

class PickCityCommand implements ICommandHandler {
	public var commandName = "pickcity";

	var eventBus:EventBus;

	public function new(eventBus:EventBus) {
		this.eventBus = eventBus;
	}

	public function handleCommand(args:Array<String>):Bool {
		eventBus.publishEvent(new PickCity());
		return true;
	}
}
