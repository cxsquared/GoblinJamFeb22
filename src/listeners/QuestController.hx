package listeners;

import event.DialogueHidden;
import dialogue.event.DialogueComplete;
import event.QuestFailed;
import event.PickCity;
import ecs.component.Renderable;
import ecs.component.Transform;
import ecs.Entity;
import component.City;
import scene.PlayScene;
import dialogue.DialogueManager;
import event.EnteredCity;
import event.QuestCompleted;
import event.NewQuest;
import ecs.event.EventBus;

class QuestController {
	public var currentCity:City;
	public var currentQuestTarget:City;
	public var availableQuestTarget:City;
	public var questIcon:Entity;
	public var welcomed = false;
	public var questTime = 5.0;
	public var timeTillNextQuest = 5.0;
	public var gettingQuest = false;
	public var nextTargetCity:Entity;
	public var questEndNode = "";
	public var defaultQuestCompleted = new Array<String>();
	public var questStart = new Array<String>();
	public var questFailed = new Array<String>();

	var shouldFailQuest = false;

	var eventBus:EventBus;
	var playScene:PlayScene;
	var dialogueManager:DialogueManager;

	public function new(playScene:PlayScene, questIcon:Entity) {
		this.questIcon = questIcon;
		this.playScene = playScene;
		this.eventBus = playScene.eventBus;
		this.dialogueManager = playScene.dialogueManager;

		eventBus.subscribe(EnteredCity, onEnteredCity);
		eventBus.subscribe(QuestCompleted, onQuestCompleted);
		eventBus.subscribe(NewQuest, onNewQuest);
		eventBus.subscribe(QuestFailed, onQuestFailed);
		eventBus.subscribe(PickCity, function(e) {
			nextTargetCity = getQuestCity();
			dialogueManager.storage.setValue("$targetCity", nextTargetCity.get(City).name.getName());
		});

		eventBus.subscribe(DialogueHidden, function(e) {
			if (shouldFailQuest) {
				hxd.Math.shuffle(questFailed);
				dialogueManager.runNode(questFailed[0]);
				shouldFailQuest = false;
			}
		});

		defaultQuestCompleted = dialogueManager.getNodeNames("defaultQuestCompleted");
		questStart = dialogueManager.getNodeNames("questStart");
		questFailed = dialogueManager.getNodeNames("questFailed");
	}

	public function update(dt:Float) {
		if (availableQuestTarget == null && currentQuestTarget == null && welcomed && !gettingQuest) {
			timeTillNextQuest -= dt;
			if (timeTillNextQuest < 0) {
				var icon = questIcon.get(Renderable).drawable;
				var questT = questIcon.get(Transform);
				icon.visible = true;

				var target = getQuestCity();
				var tt = target.get(Transform);
				availableQuestTarget = target.get(City);
				questT.x = tt.x;
				questT.y = tt.y;
				nextTargetCity = null;
				return;
			}
		}
	}

	function onEnteredCity(e:EnteredCity) {
		currentCity = e.city;
		dialogueManager.storage.setValue("$currentCity", currentCity.name.getName());

		if (currentCity == currentQuestTarget) {
			cleanupQuest();

			if (!welcomed) {
				welcomed = true;
				dialogueManager.runNode("Welcome");
				return;
			}

			eventBus.publishEvent(new QuestCompleted());
			return;
		}

		if (currentCity == availableQuestTarget) {
			gettingQuest = true;
			cleanupQuest();
			hxd.Math.shuffle(questStart);
			dialogueManager.runNode(questStart[0]);
			return;
		}
	}

	function onQuestFailed(e:QuestFailed) {
		if (currentQuestTarget != null) {
			timeTillNextQuest = questTime;
			currentQuestTarget.favor = Math.floor(Math.max(0, currentQuestTarget.favor - 25));
			currentQuestTarget.hasQuest = false;
			cleanupQuest();
			shouldFailQuest = true;
		}
	}

	function onQuestCompleted(e:QuestCompleted) {
		timeTillNextQuest = questTime;
		var nodeToRun = dialogueManager.storage.getValue("$questComplete");
		if (nodeToRun != null && nodeToRun.type != null && nodeToRun.asString() != "") {
			dialogueManager.runNode(nodeToRun.asString());
			return;
		}

		hxd.Math.shuffle(defaultQuestCompleted);
		dialogueManager.runNode(defaultQuestCompleted[0]);
	}

	function onNewQuest(e:NewQuest) {
		gettingQuest = false;
		if (currentQuestTarget != null) {
			currentQuestTarget.favor = Math.floor(Math.max(0, currentQuestTarget.favor - 10));
			currentQuestTarget.hasQuest = false;
			currentQuestTarget = null;
		}

		var icon = questIcon.get(Renderable).drawable;
		var questT = questIcon.get(Transform);
		icon.visible = true;
		if (e.nearset && playScene.encounterCities.length > 0) {
			hxd.Math.shuffle(playScene.encounterCities);
			var target = playScene.getCityByName(playScene.encounterCities[0]);
			var tt = target.get(Transform);
			currentQuestTarget = target.get(City);
			currentQuestTarget.hasQuest = true;
			questT.x = tt.x;
			questT.y = tt.y;
			return;
		}

		if (e.target != null) {
			var target = playScene.getCityByName(e.target);
			var tt = target.get(Transform);
			currentQuestTarget = target.get(City);
			currentQuestTarget.hasQuest = true;
			questT.x = tt.x;
			questT.y = tt.y;
			return;
		}

		if (nextTargetCity != null) {
			var target = nextTargetCity;
			var tt = target.get(Transform);
			currentQuestTarget = target.get(City);
			currentQuestTarget.hasQuest = true;
			questT.x = tt.x;
			questT.y = tt.y;
			nextTargetCity = null;
			return;
		}

		var target = getQuestCity();
		var tt = target.get(Transform);
		currentQuestTarget = target.get(City);
		currentQuestTarget.hasQuest = true;
		questT.x = tt.x;
		questT.y = tt.y;
	}

	function cleanupQuest() {
		currentQuestTarget = null;
		availableQuestTarget = null;

		if (questIcon != null) {
			questIcon.get(Renderable).drawable.visible = false;
		}
	}

	function getQuestCity():Entity {
		var validCities = playScene.cities.filter(function(c) {
			var city = c.get(City);
			if (city.favor <= 0)
				return false;

			if (currentCity != null && city.name.getName() == currentCity.name.getName())
				return false;

			return true;
		});

		hxd.Math.shuffle(validCities);

		return validCities[0];
	}
}
