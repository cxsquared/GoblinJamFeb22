package dialogue.event;

import hxyarn.dialogue.markup.MarkupParseResult;
import ecs.event.IEvent;

typedef OptionChoice = {
	text:String,
	index:Int,
	enabled:Bool,
	markup:MarkupParseResult
}

class OptionsShown implements IEvent {
	public var options:Array<OptionChoice>;

	public function new(options:Array<OptionChoice>) {
		this.options = options;
	}
}
