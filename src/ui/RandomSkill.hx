package ui;

import h2d.Drawable;
import h2d.filter.Glow;
import constant.GameAction;
import dn.heaps.input.ControllerAccess;
import event.GainSkill;
import assets.Assets;
import h2d.Text;
import h2d.Flow;
import ecs.event.EventBus;
import h2d.Scene;
import h2d.ScaleGrid;
import constant.Skill;
import hxd.Key;
import h2d.Object;

class RandomSkill extends Object {
	var skills:Array<Skill>;
	var bg:ScaleGrid;
	var flow:Flow;
	var scene:Scene;
	var eventBus:EventBus;
	var options:Array<GainSkill>;
	var ca:ControllerAccess<GameAction>;
	var optionsJustShown = false;
	var currentSelectedOption = 0;

	public function new(eventBus:EventBus, skills:Array<Skill>, scene:Scene, ca:ControllerAccess<GameAction>) {
		super();
		this.eventBus = eventBus;
		this.scene = scene;
		this.skills = skills;
		this.ca = ca;

		setupBg();
		setupFlow();
		setupOptions();
	}

	function setupBg() {
		bg = new ScaleGrid(hxd.Res.images.TalkBox_16x16.toTile(), 4, 4, this);
		bg.color.a = .85;
		bg.width = scene.width - 8;
		bg.height = scene.height / 2 - 8;
		bg.setPosition(4, scene.height / 2 - scene.height / 4 - 4);
	}

	function setupFlow() {
		flow = new Flow(bg);
		flow.minWidth = Math.floor(bg.getSize().width);
		flow.minHeight = Math.floor(bg.getSize().height);
		flow.verticalAlign = FlowAlign.Middle;
		flow.horizontalAlign = FlowAlign.Middle;
		flow.layout = FlowLayout.Vertical;
		flow.verticalSpacing = 16;
	}

	function setupOptions() {
		optionsJustShown = true;
		currentSelectedOption = 0;
		var text = new Text(Assets.font, flow);
		text.text = "Select a skill";

		var width = 0.0;
		var height = 0.0;
		var calculatingText = new Text(Assets.font);
		for (skill in skills) {
			calculatingText.text = buttonText(skill);
			width = Math.max(width, calculatingText.calcTextWidth(buttonText(skill)));
			height = Math.max(height, calculatingText.getSize().height);
		}
		calculatingText.remove();
		width += 32;
		height += 16;

		options = new Array<GainSkill>();
		for (index => skill in skills) {
			var button = new ScaleGrid(hxd.Res.images.TalkBox_16x16.toTile(), 4, 4, flow);
			if (index == 0) {
				button.filter = new Glow();
			}
			var text = new Text(Assets.font, button);
			text.setPosition(8, 8);
			text.text = buttonText(skill);

			button.width = width;
			button.height = height;

			var i = new h2d.Interactive(width, height, button);
			var gs = new GainSkill();
			gs.skill = skill.name.getName();
			gs.level = skill.level.getIndex() + 1;
			options.push(gs);
			i.onClick = function(e) {
				eventBus.publishEvent(gs);
			};
		}
	}

	public function update(dt:Float):Void {
		// Arrow/Pad
		if (ca.isPressed(Select) && optionsJustShown == false) {
			eventBus.publishEvent(options[currentSelectedOption]);
		}

		if (ca.isPressed(SelectDown)) {
			// unhighlight
			var curButton = cast(flow.getChildAt(currentSelectedOption + 1), Drawable);
			curButton.filter = null;

			// select new
			currentSelectedOption = (currentSelectedOption + 1) % (flow.numChildren - 1);

			// highlight
			var newButton = cast(flow.getChildAt(currentSelectedOption + 1), Drawable);
			newButton.filter = new Glow();
		}

		if (ca.isPressed(SelectUp)) {
			// unhighlight
			var curButton = cast(flow.getChildAt(currentSelectedOption + 1), Drawable);
			curButton.filter = null;

			// select new
			currentSelectedOption = currentSelectedOption - 1;
			if (currentSelectedOption < 0) {
				currentSelectedOption = flow.numChildren - 2;
			}

			// highlight
			var newButton = cast(flow.getChildAt(currentSelectedOption + 1), Drawable);
			newButton.filter = new Glow();
		}

		if (options.length > 0 && Key.isPressed(Key.NUMBER_1)) {
			eventBus.publishEvent(options[0]);
		}
		if (options.length > 1 && Key.isPressed(Key.NUMBER_2)) {
			eventBus.publishEvent(options[1]);
		}
		if (options.length > 2 && Key.isPressed(Key.NUMBER_3)) {
			eventBus.publishEvent(options[2]);
		}
		if (options.length > 3 && Key.isPressed(Key.NUMBER_4)) {
			eventBus.publishEvent(options[3]);
		}
		if (options.length > 4 && Key.isPressed(Key.NUMBER_5)) {
			eventBus.publishEvent(options[4]);
		}

		optionsJustShown = false;
	}

	public function getOptions() {
		return options;
	}

	function buttonText(skill:Skill):String {
		if (skill.level == SkillLevel.None)
			return 'Gain ${skill.name.getName()}';

		return 'Upgrade ${skill.name.getName()}';
	}
}
