package listeners;

import event.DialogueHidden;
import event.ShowSkill;
import h2d.Interactive;
import h2d.Flow;
import assets.Assets;
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
import ui.RandomSkill;
import h2d.Scene;
import h2d.Object;
import ecs.event.EventBus;
import ui.RandomSkill;

class DialogueBoxController {
	public var isTalking = false;

	var eventBus:EventBus;
	var dialogueBackground:ScaleGrid;
	var dialogueName:ScaleGrid;
	var dialogueTextName:HtmlText;
	var dialogueText:HtmlText;
	var options:Flow;
	var textFlow:Flow;
	var parent:Object;
	var scene:Scene;
	var world:World;
	var currentText:String;
	var rate = 0.0;
	var speed = 1.0;
	var textState:DialogueBoxState;
	var lineMarkup:MarkupParseResult;
	var numberOfOptions:Int;
	var randomSkill:RandomSkill;

	public function new(eventBus:EventBus, world:World, parent:Object) {
		this.eventBus = eventBus;
		this.world = world;
		this.parent = parent;
		this.scene = parent.getScene();

		dialogueBackground = new ScaleGrid(hxd.Res.images.TalkBox_16x16.toTile(), 4, 4, parent);
		dialogueBackground.visible = false;
		dialogueBackground.color.a = .85;
		dialogueBackground.width = scene.width - 8;
		dialogueBackground.height = scene.height / 2 - 8;
		dialogueBackground.setPosition(4, scene.height / 2 - scene.height / 4 - 4);
		var dialogueBackgroundSize = dialogueBackground.getSize();

		dialogueName = new ScaleGrid(hxd.Res.images.TalkBox_16x16.toTile(), 4, 4, parent);
		dialogueName.visible = false;
		dialogueName.width = dialogueBackgroundSize.width / 4;
		dialogueName.height = dialogueBackgroundSize.height / 5;
		dialogueName.setPosition(dialogueBackground.x + 8, dialogueBackground.y - 8);

		textFlow = new Flow(dialogueBackground);
		textFlow.borderWidth = 8;
		textFlow.borderHeight = 8;
		textFlow.horizontalAlign = FlowAlign.Middle;
		textFlow.verticalAlign = FlowAlign.Middle;
		textFlow.minWidth = Std.int(dialogueBackgroundSize.width);
		textFlow.minHeight = Std.int(dialogueBackgroundSize.height);
		// textFlow.backgroundTile = h2d.Tile.fromColor(0xffffff, 32, 32);

		dialogueText = new HtmlText(Assets.font);
		dialogueText.maxWidth = dialogueBackgroundSize.width - 16;

		dialogueTextName = new HtmlText(Assets.font, dialogueName);
		dialogueTextName.text = "Player";
		dialogueTextName.textAlign = Align.Center;
		dialogueTextName.maxWidth = dialogueName.width;

		options = new Flow();
		options.borderWidth = 8;
		options.borderHeight = 8;
		options.layout = FlowLayout.Vertical;
		options.horizontalAlign = FlowAlign.Middle;
		options.verticalAlign = FlowAlign.Middle;
		options.minWidth = Std.int(dialogueBackgroundSize.width);
		options.minHeight = Std.int(dialogueBackgroundSize.height);
		options.verticalSpacing = 8;

		eventBus.subscribe(LineShown, this.showLine);
		eventBus.subscribe(OptionsShown, this.showOptions);
		eventBus.subscribe(DialogueComplete, this.dialogueFinished);
		eventBus.subscribe(ShowSkill, this.skillGenerated);
	}

	public function skillGenerated(event:ShowSkill) {
		textState = DialogueBoxState.WaitingForSkillSelection;
		randomSkill = event.randomSkill;
	}


	public function showLine(event:LineShown) {
		if (!textFlow.contains(dialogueText)) {
			textFlow.addChild(dialogueText);
			textFlow.removeChild(options);
		}
		textFlow.addChild(dialogueText);
		isTalking = true;
		rate = 0.0;
		currentText = event.line();
		lineMarkup = event.markUpResults;
		dialogueTextName.text = event.characterName();

		dialogueText.text = currentText;
		dialogueText.text = "";

		textState = DialogueBoxState.TypingText;

  		dialogueBackground.visible = true;
		if (dialogueTextName.text != "") {
			dialogueName.visible = true;
		} else {
			dialogueName.visible = false;
		}
	}

	public function showOptions(event:OptionsShown) {
		dialogueName.visible = false;

		options.removeChildren();
		if (!textFlow.contains(options)) {
			textFlow.addChild(options);
			textFlow.removeChild(dialogueText);
		}
		isTalking = true;

		var width = 0.0;
		var height = 0.0;
		var calculatingText = new Text(Assets.font);
		for (option in event.options) {
			calculatingText.text = option.markup.text;
			width = Math.max(width, calculatingText.calcTextWidth(option.markup.text));
			height = Math.max(height, calculatingText.getSize().height);
		}
		calculatingText.remove();
		width += 32;
 		height += 16;

		for (option in event.options) {
			if (option.enabled) {
				var button = new ScaleGrid(hxd.Res.images.TalkBox_16x16.toTile(), 4, 4, options);
				var text = new HtmlText(Assets.font, button);
				text.setPosition(8, 8);
				var pluralAttribute = option.markup.tryGetAttributeWithName("plural");
				if (pluralAttribute != null && pluralAttribute.properties[0].value.integerValue > 0) {
					text.text = '<font color="#ffff00">${option.text}</font>';
				} else {
					text.text = option.text;
				}

				button.width = width;
				button.height = height;

				var i = new Interactive(button.getSize().width, button.getSize().height, button);
				i.onClick = function(e) {
					eventBus.publishEvent(new OptionSelected(option.index));
				};
			}
			numberOfOptions++;
		}

		textState = DialogueBoxState.WaitingForOptionSelection;
	}

	public function dialogueFinished(event:DialogueComplete) {
		dialogueBackground.visible = false;
		dialogueName.visible = false;
		if (textState != DialogueBoxState.WaitingForSkillSelection)
			textState = Hidden;
		// Delay so we don't talk after finish
		haxe.Timer.delay(function() {
			isTalking = false;
			eventBus.publishEvent(new DialogueHidden());
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
		if (textState == WaitingForSkillSelection){
			if (numberOfOptions > 0 && Key.isPressed(Key.NUMBER_1)) {
				var selection = randomSkill.getOptions()[0];
				eventBus.publishEvent(selection);
				textState=DialogueBoxState.Hidden;
			}
			if (numberOfOptions > 1 && Key.isPressed(Key.NUMBER_2)) {
				var selection = randomSkill.getOptions()[1];
				eventBus.publishEvent(selection);
				textState=DialogueBoxState.Hidden;
			}
			if (numberOfOptions > 2 && Key.isPressed(Key.NUMBER_3)) {
				var selection = randomSkill.getOptions()[2];
				eventBus.publishEvent(selection);
				textState=DialogueBoxState.Hidden;
			}
			if (numberOfOptions > 3 && Key.isPressed(Key.NUMBER_4)) {
				var selection = randomSkill.getOptions()[3];
				eventBus.publishEvent(selection);
				textState=DialogueBoxState.Hidden;
			}
			if (numberOfOptions > 4 && Key.isPressed(Key.NUMBER_5)) {
				var selection = randomSkill.getOptions()[4];
				eventBus.publishEvent(selection);
				textState=DialogueBoxState.Hidden;
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
	WaitingForSkillSelection;
}
