package dialogue.event;

import ecs.event.IEvent;

typedef OptionChoice = {
	text:String,
	index:Int,
	enabled:Bool
}

class OptionsShown implements IEvent {
	public var options:Array<OptionChoice>;

	public function new(options:Array<OptionChoice>) {
		this.options = options;
	}
}
