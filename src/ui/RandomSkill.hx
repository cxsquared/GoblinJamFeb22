package ui;

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
import h2d.Object;

class RandomSkill extends Object {
	var skills:Array<Skill>;
	var bg:ScaleGrid;
	var flow:Flow;
	var optionButtons:SelectableOptions;
	var scene:Scene;
	var eventBus:EventBus;
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

		optionButtons = new SelectableOptions(ca, hxd.Res.images.TalkBox_16x16.toTile(), flow);
		optionButtons.verticalAlign = FlowAlign.Middle;
		optionButtons.horizontalAlign = FlowAlign.Middle;
		optionButtons.layout = FlowLayout.Vertical;
		optionButtons.verticalSpacing = 16;

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

		var o = [];
		for (skill in skills) {
			var text = buttonText(skill);

			var gs = new GainSkill();
			gs.skill = skill.name.getName();
			gs.level = skill.level.getIndex() + 1;

			o.push({
				text: text,
				callback: function() {
					eventBus.publishEvent(gs);
				}
			});
		}

		optionButtons.setOptions(o, width, height);
	}

	public function update(dt:Float):Void {
		// Arrow/Pad
		if (optionsJustShown) {
			optionsJustShown = false;
			return;
		}

		optionButtons.update();
	}

	function buttonText(skill:Skill):String {
		if (skill.level == SkillLevel.None)
			return 'Gain ${skill.name.getName()}';

		return 'Upgrade ${skill.name.getName()}';
	}
}
