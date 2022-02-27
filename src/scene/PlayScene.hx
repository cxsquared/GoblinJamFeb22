package scene;

import component.Pulse;
import system.PulseController;
import event.QuestFailed;
import ecs.event.ChangeSceneEvent;
import event.DialogueHidden;
import event.GameEnd;
import dn.heaps.TiledTexture;
import listeners.QuestController;
import hxd.Math;
import event.PickCity;
import ui.RandomSkill;
import ecs.utils.MathUtils;
import constant.Skill;
import event.GainSkill;
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
	public var world:World;
	public var eventBus:EventBus;
	public var dialogueManager:DialogueManager;
	public var cities = new Array<Entity>();
	public var encounterCities = new Array<CityName>();

	var layers:Layers;
	var levels:assets.World;
	var player:Entity;
	var camera:Entity;
	var dialogueBox:DialogueBoxController;
	var questController:QuestController;
	var randomEncounters = new Array<String>();
	var storyStarts = new Array<String>();
	var storyMids = new Array<String>();
	var storyEnds = new Array<String>();
	var encounterStage = EncounterStage.StoryStart;
	var availableSkills:Array<Skill>;
	var randomSkill:RandomSkill;
	var gameOver = false;
	var gameEndData:GameEnd;
	var showEndDialogue = true;

	public function new(heapsScene:Scene, console:Console) {
		super(heapsScene, console);

		eventBus = new EventBus(console);

		Assets.init(eventBus);

		levels = Assets.worldData;

		loadDialogue();

		availableSkills = Skill.all();
	}

	function loadDialogue() {
		dialogueManager = new DialogueManager(eventBus);

		var yarnText = [
			hxd.Res.text.encounters.entry.getText(),
			hxd.Res.text.skills.entry.getText(),
			hxd.Res.text.storyStart.entry.getText(),
			hxd.Res.text.storyEnd.entry.getText(),
			hxd.Res.text.quests.entry.getText(),
			hxd.Res.text.gameOver.entry.getText(),
		];
		var yarnFileNames = [
			hxd.Res.text.encounters.entry.name,
			hxd.Res.text.skills.entry.name,
			hxd.Res.text.storyStart.entry.name,
			hxd.Res.text.storyEnd.entry.name,
			hxd.Res.text.quests.entry.name,
			hxd.Res.text.gameOver.entry.name,
		];
		dialogueManager.load(yarnText, yarnFileNames);

		randomEncounters = dialogueManager.getNodeNames("random");
		storyStarts = dialogueManager.getNodeNames("storyStart");
		storyEnds = dialogueManager.getNodeNames("storyEnd");
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
		world.addSystem(new PulseController());
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
					hxd.Math.shuffle(storyEnds);
					dialogueManager.runNode(storyEnds[0]);
				case _:
					hxd.Math.shuffle(randomEncounters);
					var encounter = randomEncounters.pop();
					dialogueManager.runNode(encounter);
					if (randomEncounters.length == 0) {
						encounterStage = EncounterStage.StoryEnd;
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

			var totalFavor = 0;
			for (city in cities) {
				totalFavor += city.get(City).favor;
			}

			if (totalFavor / 5 <= 50) {
				eventBus.publishEvent(new GameEnd(false, "FavorDefeat"));
			}
		});

		eventBus.subscribe(GameEnd, function(e) {
			gameOver = true;
			gameEndData = e;
		});

		eventBus.subscribe(DialogueHidden, function(e) {
			if (gameOver) {
				if (showEndDialogue) {
					showEndDialogue = false;
					dialogueManager.runNode(gameEndData.textNode);
					return;
				}
				if (gameEndData.winner) {
					Game.globalEventBus.publishEvent(new ChangeSceneEvent(new VictoryScene(getScene(), console)));
				} else {
					Game.globalEventBus.publishEvent(new ChangeSceneEvent(new DefeatScene(getScene(), console)));
				}
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

				dialogueManager.storage.setValue("$" + name.getName(), level.getIndex());
				return;
			}

			var newSkill = new Skill(name, level);
			existingSkills.push(newSkill);
			dialogueManager.storage.setValue("$" + name.getName(), level.getIndex());
		});

		var questIcon = setupQuestIcon();
		questController = new QuestController(this, questIcon);

		var uiParent = new Object();
		layers.add(uiParent, Const.UiLayerIndex);
		dialogueBox = new DialogueBoxController(eventBus, world, uiParent);
	}

	public function getCityByName(name:CityName) {
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

		if (randomSkill != null)
			randomSkill.update(dt);

		#if debug
		if (console.isActive())
			return;
		#end

		if (dialogueBox.isTalking || randomSkill != null)
			return;

		world.update(dt);
		questController.update(dt);
	}

	function setupQuestIcon() {
		var questIconTile = hxd.Res.sprites.Menu_icons_16x16.toTile().sub(0, 9 * 16, 16, 16);
		questIconTile.setCenterRatio();
		var questIconBitmap = new Bitmap(questIconTile);
		questIconBitmap.setScale(2);
		questIconBitmap.visible = false;
		layers.add(questIconBitmap, Const.UiLayerIndex);
		return world.addEntity("quest")
			.add(new Transform(0, 0, 32, 32))
			.add(new Renderable(questIconBitmap))
			.add(new Pulse(.15, .75));
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

		var tile = hxd.Res.sprites.horse.toTile().sub(32, 0, 32, 32);
		tile.setCenterRatio();
		var bitmap = new Bitmap(tile);
		layers.add(bitmap, Const.EnityLayerIndex);

		var r = new Renderable(bitmap);
		r.offsetX = 16;
		r.offsetY = 16;
		var player = world.addEntity("player")
			.add(new Player())
			.add(new Transform(playerStart.pixelX, playerStart.pixelY, playerSize, playerSize))
			.add(new Velocity(0, 0))
			.add(new Collidable(CollisionShape.BOUNDS, 0, playerSize, playerSize))
			.add(r);

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
		var fireTile = hxd.Res.sprites.map_sheet.toTile().sub(14 * 32, 19 * 32, 63, 32);
		var fireBitmap = new Bitmap(fireTile);
		layers.add(fireBitmap, Const.EnityLayerIndex);

		world.addEntity("fire").add(new Transform(x, y, 32, 32)).add(new Renderable(fireBitmap));
	}
}
