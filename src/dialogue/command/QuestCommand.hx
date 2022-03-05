package dialogue.command;

import ecs.event.EventBus;
import event.NewQuest;

class QuestCommand implements ICommandHandler {
	public var commandName:String = "quest";

	var eventBus:EventBus;

	public function new(eventBus:EventBus) {
		this.eventBus = eventBus;
	}

	public function handleCommand(args:Array<String>):Bool {
		var q = new NewQuest();
		if (args.contains("nearby")) {
			q.nearset = true;
		}

		if (args.length > 0 && args[0] != "nearby") {
			q.completeQuestNode = args[0];
		}

		eventBus.publishEvent(q);

		return true;
	}
}
