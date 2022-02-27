package scene;

import ecs.event.ChangeSceneEvent;
import hxd.Key;
import h2d.Console;
import h2d.Scene;
import assets.Assets;
import h2d.Text;
import ecs.scene.GameScene;

class DefeatScene extends GameScene {
	public function new(heapsScene:Scene, console:Console) {
		super(heapsScene, console);
		Assets.init(Game.globalEventBus);
	}

	public override function init():Void {
		var t = new Text(Assets.font, this);
		t.text = "You lost!\nPress space to try again";
	}

	public override function update(dt:Float):Void {
		if (Key.isPressed(Key.SPACE)) {
			Game.globalEventBus.publishEvent(new ChangeSceneEvent(new PlayScene(getScene(), console)));
		}
	}
}
