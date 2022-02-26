import ecs.event.ChangeSceneEvent;
import ecs.event.EventBus;
import scene.PlayScene;
import ecs.scene.GameScene;
import hxd.Key;
import ecs.tools.WorldEditor;
import h2d.Console;
import h2d.Layers;
import hxd.Timer;
import hxd.res.DefaultFont;
import h2d.Text;

class Game extends hxd.App {
	var scene:GameScene;
	var fps:Text;
	var layer:Layers;
	var console:Console;

	public var editor:WorldEditor;

	public static var globalEventBus:EventBus;
	public static var game:Game;

	public function new() {
		super();
		game = this;
	}

	override function init() {
		s2d.scaleMode = ScaleMode.Fixed(800, 600, 1);
		hxd.Res.initEmbed();

		layer = new Layers(s2d);

		#if debug
		fps = new Text(DefaultFont.get());
		fps.visible = false;
		layer.addChildAt(fps, 3);
		console = new Console(DefaultFont.get());
		layer.addChildAt(console, 2);
		editor = new WorldEditor(s2d);
		editor.visible = false;
		layer.addChildAt(editor, 1);
		#end

		globalEventBus = new EventBus(console);
		globalEventBus.subscribe(ChangeSceneEvent, onChangeScene);

		setGameScene(new PlayScene(s2d, console));
	}

	public function onChangeScene(event:ChangeSceneEvent) {
		setGameScene(event.newScene);
	}

	public function setGameScene(gs:GameScene) {
		console.resetCommands();
		if (scene != null) {
			s2d.removeChild(scene); // This might not actually clean anything up aka memory leak
			layer.removeChild(scene); // This might not actually clean anything up aka memory leak
		}

		scene = gs;

		scene.init();

		layer.addChildAt(scene, 0);
	}

	override function update(dt:Float) {
		if (scene != null)
			scene.update(dt);

		#if debug
		if (Key.isPressed(Key.F3)) {
			fps.visible = !fps.visible;
		}
		fps.text = "FPS: " + Timer.fps();
		#end
	}
}
