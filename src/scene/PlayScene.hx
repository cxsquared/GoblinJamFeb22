package scene;

import ui.RandomSkill;
import ecs.utils.MathUtils;
import constant.Skill;
import event.GainSkill;
import ecs.component.Ui;
import event.QuestCompleted;
import event.NewQuest;
import event.EnteredCity;
import constant.EncounterStage;
import ui.Bar;
import component.UiBar;
import system.CityController;
import system.UiBarController;
import dialogue.event.StartNode.StartDialogueNode;
import event.TeleportToNearByTown;
import event.CityFavorChange;
import constant.CityNames.CityName;
import constant.Skill.SkillName;
import ecs.system.CollisionDebug;
import system.EncounterController;
import listeners.DialogueBoxController;
import event.PlayEncounter;
import ecs.system.Collision;
import h2d.Object;
import ecs.system.DebugEntityController;
import ecs.system.LevelCollisionController;
import component.Encounter;
import ecs.component.Collidable;
import component.City;
import h2d.TileGroup;
import assets.Assets;
import ecs.event.EventBus;
import ecs.Entity;
import h2d.Layers;
import constant.Const;
import system.PlayerController;
import component.Player;
import ecs.system.CameraController;
import ecs.component.Velocity;
import h2d.col.Bounds;
import ecs.component.Camera;
import ecs.system.Renderer;
import h2d.Tile;
import h2d.Bitmap;
import ecs.component.Renderable;
import ecs.component.Transform;
import ecs.World;
import h2d.Console;
import h2d.Scene;
import ecs.scene.GameScene;
import dialogue.DialogueManager;

class PlayScene extends GameScene {
	var world:World;
	var layers:Layers;
	var eventBus:EventBus;
	var levels:assets.World;
	var player:Entity;
	var camera:Entity;
	var dialogueManager:DialogueManager;
	var dialogueBox:DialogueBoxController;
	var cities = new Array<Entity>();
	var encounterCities = new Array<CityName>();
	var randomEncounters = new Array<String>();
	var storyStarts = new Array<String>();
	var storyMids = new Array<String>();
	var storyEnds = new Array<String>();
	var defaultQuestCompleted = new Array<String>();
	var encounterStage = EncounterStage.StoryStart;
	var currentCity:City;
	var currentQuestTarget:City;
	var questIcon:Entity;
	var welcomed = false;
	var availableSkills:Array<Skill>;
	var randomSkill:RandomSkill;

	public function new(heapsScene:Scene, console:Console) {
		super(heapsScene, console);

		eventBus = new EventBus(console);

		Assets.init(eventBus);

		levels = Assets.worldData;
		dialogueManager = Assets.dialogueManager;

		randomEncounters = dialogueManager.getNodeNames("random");
		storyStarts = dialogueManager.getNodeNames("storyStart");
		defaultQuestCompleted = dialogueManager.getNodeNames("defaultQuestCompleted");

		availableSkills = Skill.all();
	}

	public override function init():Void {
		var s2d = getScene();
		this.world = new World();

		#if debug
		console.addCommand("toggleDebug", "toggles debug text for an entity", [{name: "entityName", t: ConsoleArg.AString, opt: true}],
			function(entityName:String) {
				if (entityName != null && entityName != "") {
					var e = world.getEntityByName(entityName);
					e.debug = !e.debug;
					return;
				}

				for (e in world.getEntities()) {
					e.debug = !e.debug;
				}
			});

		console.addCommand("setSkill", "sets a skill and level(0,1,2)", [
			{name: "name", t: ConsoleArg.AString, opt: false},
			{name: "level", t: ConsoleArg.AInt, opt: false}
		], function(name:String, level:Int) {
			if (!Skill.isValid(name)) {
				console.log("invalid skil name");
				return;
			}
			if (level < 0 || level > 2) {
				console.log("invalid level");
				return;
			}
			dialogueManager.storage.setValue("$" + name, level);
		});
		#end

		layers = new Layers(this);

		var level = levels.all_levels.Level_0;
		setupLevel(level);

		world.addSystem(new PlayerController());
		world.addSystem(new CameraController(s2d, console));
		world.addSystem(new CityController(eventBus));
		world.addSystem(new LevelCollisionController(level.l_Collision));
		world.addSystem(new Collision());
		world.addSystem(new EncounterController(eventBus));
		world.addSystem(new UiBarController());
		world.addSystem(new Renderer(camera));

		#if debug
		var debugParent = new Object();
		layers.add(debugParent, Const.DebugLayerIndex);
		world.addSystem(new DebugEntityController(world, debugParent));

		world.addSystem(new CollisionDebug(camera, debugParent));
		#end

		eventBus.subscribe(PlayEncounter, function(e) {
			encounterCities = e.encounter.cities;

			switch (encounterStage) {
				case StoryStart:
					hxd.Math.shuffle(storyStarts);
					dialogueManager.runNode(storyStarts[0]);
					encounterStage = EncounterStage.Random;
				case StoryMiddle:
				case StoryEnd:
				case _:
					hxd.Math.shuffle(randomEncounters);
					var encounter = randomEncounters.pop();
					dialogueManager.runNode(encounter);
					if (randomEncounters.length == 0) {
						encounterStage = EncounterStage.StoryEnd;
					} else {
						encounterStage = EncounterStage.StoryMiddle;
					}
			}
		});

		eventBus.subscribe(CityFavorChange, function(e) {
			hxd.Math.shuffle(encounterCities);
			var cityName = encounterCities[0];
			var cityEntity = getCityByName(cityName);
			var city = cityEntity.get(City);
			city.favor = Math.floor(hxd.Math.clamp(city.favor + e.amount, 0, city.maxFavor));

			if (city.favor <= 0) {
				var ct = cityEntity.get(Transform);
				createFire(ct.x, ct.y);
			}
		});

		eventBus.subscribe(TeleportToNearByTown, function(e) {
			hxd.Math.shuffle(encounterCities);
			var cityName = encounterCities[0];
			var city = getCityByName(cityName);
			var ct = city.get(Transform);

			var pt = player.get(Transform);
			var pv = player.get(Velocity);
			pt.x = ct.x + ct.width / 2 - pt.width / 2;
			pt.y = ct.y + ct.height / 2 - pt.height / 2;
			pv.dx = 0;
			pv.dy = 0;
		});

		eventBus.subscribe(StartDialogueNode, function(e) {
			var pv = player.get(Velocity);
			pv.dx = 0;
			pv.dy = 0;
		});

		eventBus.subscribe(EnteredCity, function(e) {
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
			}
		});

		eventBus.subscribe(QuestCompleted, function(e) {
			var nodeToRun = dialogueManager.storage.getValue("$questComplete");
			if (nodeToRun != null && nodeToRun.asString() != "") {
				dialogueManager.runNode(nodeToRun.asString());
				return;
			}

			hxd.Math.shuffle(defaultQuestCompleted);
			dialogueManager.runNode(defaultQuestCompleted[0]);
		});

		eventBus.subscribe(NewQuest, function(e) {
			if (currentQuestTarget != null) {
				currentQuestTarget.favor = Math.floor(Math.max(0, currentQuestTarget.favor - 10));
				currentQuestTarget.hasQuest = false;
				currentQuestTarget = null;
			}

			if (questIcon == null)
				setupQuestIcon();

			var icon = questIcon.get(Renderable).drawable;
			var questT = questIcon.get(Transform);
			icon.visible = true;
			if (e.nearset && encounterCities.length > 0) {
				hxd.Math.shuffle(encounterCities);
				var target = getCityByName(encounterCities[0]);
				var tt = target.get(Transform);
				currentQuestTarget = target.get(City);
				currentQuestTarget.hasQuest = true;
				questT.x = tt.x;
				questT.y = tt.y;
				return;
			}

			var validCities = cities.filter(function(c) {
				var city = c.get(City);
				return city.favor > 0 && city.name.getName() != currentCity.name.getName();
			});

			hxd.Math.shuffle(validCities);

			var target = validCities[0];
			var tt = target.get(Transform);
			currentQuestTarget = target.get(City);
			currentQuestTarget.hasQuest = true;
			questT.x = tt.x;
			questT.y = tt.y;
		});

		eventBus.subscribe(GainSkill, function(e) {
			if (e.skill == null || e.skill == "") {
				var skills = [];
				var tryIncludeUpgrade = MathUtils.roll(6) == 6;

				if (tryIncludeUpgrade) {
					var validUpgrades = player.get(Player).skills.filter(function(s) {
						return s.level != SkillLevel.Advanced;
					});

					hxd.Math.shuffle(validUpgrades);
					skills.push(validUpgrades[0]);
				}

				hxd.Math.shuffle(availableSkills);
				while (availableSkills.length > 0 && skills.length < 3) {
					skills.push(availableSkills.pop());
				}

				randomSkill = new RandomSkill(eventBus, skills, getScene());
				layers.add(randomSkill, Const.UiLayerIndex);
				return;
			}

			if (randomSkill != null) {
				randomSkill.remove();
				randomSkill = null;
			}

			var name = SkillName.createByName(e.skill);
			var level = SkillLevel.createByIndex(e.level);

			var existingSkills = player.get(Player).skills;
			var existingSkill:Skill = null;
			var possibleExisting = existingSkills.filter(function(s) {
				return s.name == name;
			});
			if (possibleExisting.length > 0)
				existingSkill = possibleExisting[0];

			if (existingSkill != null) {
				if (existingSkill.level.getIndex() < level.getIndex())
					existingSkill.level = level;

				return;
			}

			var newSkill = new Skill(name, level);
			existingSkills.push(newSkill);
		});

		var uiParent = new Object();
		layers.add(uiParent, Const.UiLayerIndex);
		dialogueBox = new DialogueBoxController(eventBus, world, uiParent);
	}

	function cleanupQuest() {
		currentQuestTarget = null;
		if (questIcon != null) {
			questIcon.get(Renderable).drawable.visible = false;
		}
	}

	function getCityByName(name:CityName) {
		for (city in cities) {
			var c = city.get(City);
			if (c.name == name) {
				return city;
			}
		}

		return null;
	}

	public override function update(dt:Float):Void {
		dialogueBox.update(dt);

		if (dialogueBox.isTalking || console.isActive() || randomSkill != null)
			return;

		world.update(dt);
	}

	function setupQuestIcon() {
		var questIconTile = hxd.Res.sprites.Menu_icons_16x16.toTile().sub(0, 9 * 16, 16, 16);
		var questIconBitmap = new Bitmap(questIconTile);
		questIconBitmap.visible = false;
		layers.add(questIconBitmap, Const.UiLayerIndex);
		questIcon = world.addEntity("quest").add(new Transform(0, 0, 16, 16)).add(new Renderable(questIconBitmap));
	}

	function setupLevel(level:assets.World.World_Level) {
		if (level.hasBgImage()) {
			var bg = level.getBgBitmap();
			world.addEntity('background').add(new Transform(0, 0, bg.getSize().width, bg.getSize().height)).add(new Renderable(bg));
			layers.add(bg, Const.BackgroundLayerIndex);
		}

		var tiles = new TileGroup(hxd.Res.sprites.map_sheet.toTile());
		layers.add(tiles, Const.EnityLayerIndex);
		level.l_Tiles.render(tiles);

		var worldTiles = world.addEntity('tiles').add(new Transform(0, 0, level.pxWid, level.pxHei)).add(new Renderable(tiles));
		worldTiles.debugLocation = Bottom;

		for (city in level.l_Entities.all_City) {
			createCity(city);
		}

		for (i => encounter in level.l_Entities.all_Encounter) {
			createEncounter(encounter, i);
		}

		var playerStart = level.l_Entities.all_PlayerStart[0];
		if (playerStart != null) {
			player = setupPlayer(playerStart);
		}

		camera = setupCamera(player);
	}

	function setupPlayer(playerStart:assets.World.Entity_PlayerStart):Entity {
		var playerSize = Const.TileSize;

		var bitmap = new Bitmap(Tile.fromColor(0xFF0000, playerSize, playerSize));
		layers.add(bitmap, Const.EnityLayerIndex);

		var player = world.addEntity("player")
			.add(new Player())
			.add(new Transform(playerStart.pixelX, playerStart.pixelY, playerSize, playerSize))
			.add(new Velocity(0, 0))
			.add(new Collidable(CollisionShape.BOUNDS, 0, playerSize, playerSize))
			.add(new Renderable(bitmap));

		return player;
	}

	function createCity(city:assets.World.Entity_City) {
		var uiBar = new UiBar();
		uiBar.bar = new Bar(64, 8);
		uiBar.y = -8;
		uiBar.x = city.width / 2 - 32;
		layers.add(uiBar.bar, Const.UiLayerIndex);
		var c = world.addEntity('city_${city.f_CityName.getName()}')
			.add(new Transform(city.pixelX, city.pixelY, city.width, city.height))
			.add(new Collidable(BOUNDS, 0, city.width, city.height))
			.add(uiBar)
			.add(new City(city.f_CityName));
		cities.push(c);
	}

	function createEncounter(encounter:assets.World.Entity_Encounter, index:Int) {
		world.addEntity('encounter$index')
			.add(new Transform(encounter.pixelX, encounter.pixelY, encounter.width, encounter.height))
			.add(new Collidable(BOUNDS, 0, encounter.width, encounter.height))
			.add(new Encounter(encounter.f_Cities));
	}

	function setupCamera(target:Entity):Entity {
		var s2d = getScene();
		var cameraBounds = Bounds.fromValues(0, 0, s2d.width, s2d.height);

		var camera = world.addEntity("Camera")
			.add(new Transform())
			.add(new Velocity(0, 0))
			.add(new Camera(target, cameraBounds, s2d.width / 2, s2d.height / 2));

		return camera;
	}

	function createFire(x:Float, y:Float) {
		var fireTile = hxd.Res.sprites.map_sheet.toTile().sub(19 * 32, 15 * 32, 63, 32);
		var fireBitmap = new Bitmap(fireTile);
		layers.add(fireBitmap, Const.EnityLayerIndex);

		world.addEntity("fire").add(new Transform(x, y, 32, 32)).add(new Renderable(fireBitmap));
	}
}
