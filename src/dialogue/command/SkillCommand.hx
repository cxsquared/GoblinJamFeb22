package dialogue.command;

import event.GainSkill;
import ecs.event.EventBus;

class SkillCommand implements ICommandHandler {
	public var commandName:String = "skill";

	var eventBus:EventBus;

	public function new(eventBus:EventBus) {
		this.eventBus = eventBus;
	}

	public function handleCommand(args:Array<String>):Bool {
		var s = new GainSkill();
		if (args.length > 0 && args[0] != "random") {
			s.skill = args[0];
		}
		if (args.length > 1) {
			s.skill = args[1];
		}
		eventBus.publishEvent(s);

		return true;
	}
}
