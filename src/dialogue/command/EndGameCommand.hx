package dialogue.command;

import event.GameEnd;
import ecs.event.EventBus;

class EndGameCommand implements ICommandHandler {
	public var commandName:String = "endgame";

	var eventBus:EventBus;

	public function new(eventBus:EventBus) {
		this.eventBus = eventBus;
	}

	public function handleCommand(args:Array<String>):Bool {
		if (args.contains("lose")) {
			eventBus.publishEvent(new GameEnd(false, args[1]));
		} else {
			eventBus.publishEvent(new GameEnd(true, args[1]));
		}

		return true;
	}
}
