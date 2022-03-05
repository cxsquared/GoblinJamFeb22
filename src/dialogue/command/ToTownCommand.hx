package dialogue.command;

import event.TeleportToNearByTown;
import ecs.event.EventBus;

class ToTownCommand implements ICommandHandler {
	public var commandName = "totown";

	var eventBus:EventBus;

	public function new(eventBus:EventBus) {
		this.eventBus = eventBus;
	}

	public function handleCommand(args:Array<String>):Bool {
		eventBus.publishEvent(new TeleportToNearByTown());
		return true;
	}
}
