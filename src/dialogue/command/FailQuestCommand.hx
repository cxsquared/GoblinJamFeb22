package dialogue.command;

import event.QuestFailed;
import ecs.event.EventBus;

class FailQuestCommand implements ICommandHandler {
	public var commandName:String = "failquest";

	var eventBus:EventBus;

	public function new(eventBus:EventBus) {
		this.eventBus = eventBus;
	}

	public function handleCommand(args:Array<String>):Bool {
		eventBus.publishEvent(new QuestFailed());
		return true;
	}
}
