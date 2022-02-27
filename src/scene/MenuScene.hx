package scene;

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
		Assets.init(Game.globalEventBus);
	}

	public override function init():Void {
		new Bitmap(hxd.Res.images.title.toTile(), this);
	}

	public override function update(dt:Float):Void {
		if (Key.isPressed(Key.SPACE)) {
			Game.globalEventBus.publishEvent(new ChangeSceneEvent(new PlayScene(getScene(), console)));
		}
	}
}
