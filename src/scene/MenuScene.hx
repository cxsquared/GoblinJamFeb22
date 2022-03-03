package scene;

import hxd.Event;
import h2d.Bitmap;
import ecs.event.ChangeSceneEvent;
import hxd.Key;
import h2d.Console;
import h2d.Scene;
import assets.Assets;
import ecs.scene.GameScene;

class MenuScene extends GameScene {
	public function new(heapsScene:Scene, console:Console) {
		super(heapsScene, console);
		Assets.init(Game.current.globalEventBus);
	}

	public override function init():Void {
		new Bitmap(hxd.Res.images.title.toTile(), this);
		getScene().addEventListener(onEvent);
	}

	function onEvent(e:Event) {
		if (e.kind == EPush) {
			Game.current.globalEventBus.publishEvent(new ChangeSceneEvent(new PlayScene(getScene(), console)));
		}
	}

	public override function update(dt:Float):Void {
		if (Game.current.ca.isPressed(Select)) {
			Game.current.globalEventBus.publishEvent(new ChangeSceneEvent(new PlayScene(getScene(), console)));
		}
	}

	public override function onRemove() {
		getScene().removeEventListener(onEvent);
		super.onRemove();
	}
}
