package dialogue.command;

import ecs.event.EventBus;
import event.MoneyChange;

class MoneyCommand implements ICommandHandler {
	public var commandName = "money";

	var eventBus:EventBus;

	public function new(eventBus:EventBus) {
		this.eventBus = eventBus;
	}

	public function handleCommand(args:Array<String>):Bool {
		var amount = FavorUtils.getAmount(args[0], args[1]);
		eventBus.publishEvent(new MoneyChange(amount));

		return true;
	}
}
