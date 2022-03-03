package scene;

import hxd.Event;
import h2d.Bitmap;
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
		Assets.init(Game.current.globalEventBus);
	}

	public override function init():Void {
		var s2d = getScene();
		new Bitmap(hxd.Res.images.defeat_screen.toTile(), this);
		var t = new Text(Assets.font, this);
		t.text = "D E F E A T\n\nPress space to try again";
		t.textAlign = Align.MultilineCenter;
		t.y = 100;
		t.x = s2d.width / 2 - t.getSize().width / 2;

		s2d.addEventListener(onEvent);
	}

	public override function update(dt:Float):Void {
		if (Game.current.ca.isPressed(Select)) {
			Game.current.globalEventBus.publishEvent(new ChangeSceneEvent(new PlayScene(getScene(), console)));
		}
	}

	function onEvent(e:Event) {
		if (e.kind == EPush) {
			Game.current.globalEventBus.publishEvent(new ChangeSceneEvent(new PlayScene(getScene(), console)));
		}
	}

	public override function onRemove() {
		getScene().removeEventListener(onEvent);
		super.onRemove();
	}
}
