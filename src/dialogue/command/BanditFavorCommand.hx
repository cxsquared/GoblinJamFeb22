package dialogue.command;

import ecs.event.EventBus;
import event.BanditFavorChange;

class BanditFavorCommand implements ICommandHandler {
	public var commandName = "banditfavor";

	var eventBus:EventBus;

	public function new(eventBus:EventBus) {
		this.eventBus = eventBus;
	}

	public function handleCommand(args:Array<String>):Bool {
		var amount = FavorUtils.getAmount(args[0], args[1]);
		eventBus.publishEvent(new BanditFavorChange(amount));

		return true;
	}
}
