package scene;

import constant.Skill.SkillName;
import ecs.system.CollisionDebug;
import system.EncounterController;
import listeners.DialogueBoxController;
import event.PlayEncounter;
import ecs.system.Collision;
import h2d.Object;
import ecs.system.DebugEntityController;
import dn.heaps.ScreenWash;
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

	public function new(heapsScene:Scene, console:Console) {
		super(heapsScene, console);

		eventBus = new EventBus(console);

		Assets.init(eventBus);

		levels = Assets.worldData;
		dialogueManager = Assets.dialogueManager;
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
			var valid = false;
			for (n in SkillName.createAll()) {
				if (n.getName() == name) {
					valid = true;
					break;
				}
			}
			if (!valid) {
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
		world.addSystem(new LevelCollisionController(level.l_Collision));
		world.addSystem(new Collision());
		world.addSystem(new EncounterController(eventBus));
		world.addSystem(new Renderer(camera));

		#if debug
		var debugParent = new Object();
		layers.add(debugParent, Const.DebugLayerIndex);
		world.addSystem(new DebugEntityController(world, debugParent));

		world.addSystem(new CollisionDebug(camera, debugParent));
		#end

		eventBus.subscribe(PlayEncounter, function(e) {
			var possibleNodes = dialogueManager.getNodeNames("random");
			dialogueManager.runNode(possibleNodes[0]);
		});

		var uiParent = new Object();
		layers.add(uiParent, Const.UiLayerIndex);
		dialogueBox = new DialogueBoxController(eventBus, world, uiParent);
	}

	public override function update(dt:Float):Void {
		dialogueBox.update(dt);

		if (dialogueBox.isTalking || console.isActive())
			return;

		world.update(dt);
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
			setupPlayer(playerStart);
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
		world.addEntity('city_${city.f_CityName.getName()}')
			.add(new Transform(city.pixelX, city.pixelY, city.width, city.height))
			.add(new Collidable(BOUNDS, 0, city.width, city.height))
			.add(new City(city.f_CityName));
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
}
