package listeners;

import assets.Assets;
import hxd.res.DefaultFont;
import hxyarn.dialogue.markup.MarkupParseResult;
import h2d.HtmlText;
import dialogue.event.OptionSelected;
import dialogue.event.NextLine;
import hxd.Key;
import dialogue.event.DialogueComplete;
import dialogue.event.OptionsShown;
import dialogue.event.LineShown;
import h2d.Text;
import h2d.ScaleGrid;
import ecs.World;
import h2d.Scene;
import h2d.Object;
import ecs.event.EventBus;

class DialogueBoxController {
	public var isTalking = false;

	var eventBus:EventBus;
	var dialogueBackground:ScaleGrid;
	var dialogueName:ScaleGrid;
	var dialogueTextName:HtmlText;
	var dialogueText:HtmlText;
	var parent:Object;
	var scene:Scene;
	var world:World;
	var currentText:String;
	var rate = 0.0;
	var speed = 1.0;
	var textState:DialogueBoxState;
	var lineMarkup:MarkupParseResult;
	var numberOfOptions:Int;

	public function new(eventBus:EventBus, world:World, parent:Object) {
		this.eventBus = eventBus;
		this.world = world;
		this.parent = parent;
		this.scene = parent.getScene();

		dialogueBackground = new ScaleGrid(hxd.Res.images.TalkBox_16x16.toTile(), 4, 4, parent);
		dialogueBackground.visible = false;
		dialogueBackground.width = scene.width - 8;
		dialogueBackground.height = scene.height / 4 - 8;
		dialogueBackground.setPosition(4, scene.height - scene.height / 4 - 4);
		// dialogueBackground.filter = new Nothing();
		var dialogueBackgroundSize = dialogueBackground.getSize();

		dialogueName = new ScaleGrid(hxd.Res.images.TalkBox_16x16.toTile(), 4, 4, parent);
		// dialogueName.filter = new Nothing();
		dialogueName.visible = false;
		dialogueName.width = dialogueBackgroundSize.width / 5;
		dialogueName.height = dialogueBackgroundSize.height / 5;
		dialogueName.setPosition(dialogueBackground.x + 8, dialogueBackground.y - 8);

		dialogueText = new HtmlText(Assets.font, dialogueBackground);
		dialogueText.maxWidth = dialogueBackgroundSize.width - 16;

		dialogueTextName = new HtmlText(Assets.font, dialogueName);
		dialogueTextName.text = "Player";
		dialogueTextName.textAlign = Align.Center;
		dialogueTextName.maxWidth = dialogueName.width;

		eventBus.subscribe(LineShown, this.showLine);
		eventBus.subscribe(OptionsShown, this.showOptions);
		eventBus.subscribe(DialogueComplete, this.dialogueFinished);
	}

	public function showLine(event:LineShown) {
		isTalking = true;
		rate = 0.0;
		currentText = event.line();
		lineMarkup = event.markUpResults;
		dialogueTextName.text = event.characterName();

		dialogueText.text = currentText;
		var textWidth = dialogueText.calcTextWidth(currentText);
		dialogueText.setPosition(dialogueBackground.getSize().width / 2 - textWidth / 2, dialogueBackground.getSize().height / 4);
		dialogueText.text = "";

		textState = DialogueBoxState.TypingText;

		dialogueBackground.visible = true;
		if (dialogueTextName.text != "") {
			dialogueName.visible = true;
		}
	}

	public function showOptions(event:OptionsShown) {
		var sb = new StringBuf();

		for (option in event.options) {
			if (option.enabled) {
				sb.add('${option.index + 1} ${option.text}<br/>');
			}
			numberOfOptions++;
		}

		dialogueText.text = sb.toString();
		dialogueTextName.text = "Select";
		textState = DialogueBoxState.WaitingForOptionSelection;
	}

	public function dialogueFinished(event:DialogueComplete) {
		dialogueBackground.visible = false;
		dialogueName.visible = false;
		textState = Hidden;
		// Delay so we don't talk after finish
		haxe.Timer.delay(function() {
			isTalking = false;
		}, 50);
	}

	public function update(dt:Float) {
		if (textState == Hidden || textState == DialogueBoxState.WaitingForNextLine)
			return;

		if (textState == TypingText) {
			updateText(dt);
		}

		if (isTalking && Key.isPressed(Key.SPACE)) {
			if (textState == TypingText) {
				dialogueText.text = applyTextAttributes(currentText);
				textState = DialogueBoxState.WaitingForContinue;
			} else if (textState == WaitingForContinue) {
				eventBus.publishEvent(new NextLine());
			}
		}

		if (textState == WaitingForOptionSelection) {
			if (numberOfOptions > 0 && Key.isPressed(Key.NUMBER_1)) {
				textState = DialogueBoxState.WaitingForNextLine;
				eventBus.publishEvent(new OptionSelected(0));
			}
			if (numberOfOptions > 1 && Key.isPressed(Key.NUMBER_2)) {
				textState = DialogueBoxState.WaitingForNextLine;
				eventBus.publishEvent(new OptionSelected(1));
			}
			if (numberOfOptions > 2 && Key.isPressed(Key.NUMBER_3)) {
				textState = DialogueBoxState.WaitingForNextLine;
				eventBus.publishEvent(new OptionSelected(2));
			}
			if (numberOfOptions > 3 && Key.isPressed(Key.NUMBER_4)) {
				textState = DialogueBoxState.WaitingForNextLine;
				eventBus.publishEvent(new OptionSelected(3));
			}
			if (numberOfOptions > 4 && Key.isPressed(Key.NUMBER_5)) {
				textState = DialogueBoxState.WaitingForNextLine;
				eventBus.publishEvent(new OptionSelected(4));
			}
		}
	}

	function updateText(dt:Float) {
		rate += speed * dt;
		var textLenght = Math.min(currentText.length, Math.floor(rate * currentText.length));
		var rawText = currentText.substring(0, Math.floor(textLenght));
		dialogueText.text = applyTextAttributes(rawText);

		if (rawText == currentText) {
			textState = DialogueBoxState.WaitingForContinue;
		}
	}

	function applyTextAttributes(text:String):String {
		var characterOffest = 0;
		var characterAttribute = lineMarkup.tryGetAttributeWithName("character");
		if (characterAttribute != null)
			characterOffest = -characterAttribute.length;

		var htmlTagsByIndex = new Map<Int, String>();

		for (attribute in lineMarkup.attributes) {
			var startTagIndex = attribute.position + characterOffest;
			if (startTagIndex < text.length) {
				var currrentStartTag = "";
				var currentEndTag = "";
				var endTagIndex = Std.int(Math.min(text.length, startTagIndex + attribute.length));
				if (htmlTagsByIndex.exists(startTagIndex))
					currrentStartTag = htmlTagsByIndex.get(startTagIndex);

				if (htmlTagsByIndex.exists(endTagIndex))
					currentEndTag = htmlTagsByIndex.get(endTagIndex);

				if (attribute.name == "font") {
					var openTag = '$currrentStartTag<font';
					var closeTag = '</font>$currentEndTag';
					for (property in attribute.properties) {
						if (property.name == "color") {
							openTag += ' color="' + property.value.stringValue + '"';
						}

						if (property.name == "opacity") {
							openTag += ' opacity="' + property.value.floatValue + '"';
						}
					}
					openTag += '>';
					htmlTagsByIndex.set(startTagIndex, openTag);
					htmlTagsByIndex.set(endTagIndex, closeTag);
				}
			}
		}

		var sb = new StringBuf();

		for (i in 0...text.length) {
			var char = text.charAt(i);
			if (htmlTagsByIndex.exists(i)) {
				sb.add(htmlTagsByIndex.get(i));
			}

			sb.add(char);
		}

		if (htmlTagsByIndex.exists(text.length)) {
			sb.add(htmlTagsByIndex.get(text.length));
		}

		return sb.toString();
	}
}

enum DialogueBoxState {
	Hidden;
	TypingText;
	WaitingForNextLine;
	WaitingForContinue;
	WaitingForOptionSelection;
}
