package ui;

import event.GainSkill;
import event.ShowSkill;
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
	var scene:Scene;
	var eventBus:EventBus;
	var options:Array<GainSkill>;

	public function new(eventBus:EventBus, skills:Array<Skill>, scene:Scene) {
		super();
		this.eventBus = eventBus;
		this.scene = scene;
		this.skills = skills;

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
		for (skill in skills) {
			var button = new ScaleGrid(hxd.Res.images.TalkBox_16x16.toTile(), 4, 4, flow);
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
		var showSkill = new ShowSkill(this);
		eventBus.publishEvent(showSkill);
	}

	public function getOptions(){
		return options;
	}

	function buttonText(skill:Skill):String {
		if (skill.level == SkillLevel.None)
			return 'Gain ${skill.name.getName()}';

		return 'Upgrade ${skill.name.getName()}';
	}
}
