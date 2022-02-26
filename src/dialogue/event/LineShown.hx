package dialogue.event;

import hxyarn.dialogue.markup.MarkupAttribute;
import hxyarn.dialogue.markup.MarkupParseResult;
import ecs.event.IEvent;

class LineShown implements IEvent {
	public var markUpResults:MarkupParseResult;

	public function new(markupParseResults:MarkupParseResult) {
		this.markUpResults = markupParseResults;
	}

	public function line():String {
		var text = markUpResults.text;
		var characterAttribute = characterNameAttribute();

		if (characterAttribute != null)
			text = text.substr(characterAttribute.position + characterAttribute.length);

		return text;
	}

	public function characterName():String {
		var attribute = characterNameAttribute();

		if (attribute != null)
			return attribute.properties[0].value.stringValue;

		return "";
	}

	function characterNameAttribute():MarkupAttribute {
		return markUpResults.tryGetAttributeWithName("character");
	}
}
