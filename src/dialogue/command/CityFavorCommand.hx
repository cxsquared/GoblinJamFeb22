package dialogue.command;

import event.CityFavorChange;
import ecs.event.EventBus;

class CityFavorCommand implements ICommandHandler {
	public var commandName = "cityfavor";

	var eventBus:EventBus;

	public function new(eventBus:EventBus) {
		this.eventBus = eventBus;
	}

	public function handleCommand(args:Array<String>):Bool {
		var amount = FavorUtils.getAmount(args[0], args[1]);
		eventBus.publishEvent(new CityFavorChange(amount));

		return true;
	}
}
