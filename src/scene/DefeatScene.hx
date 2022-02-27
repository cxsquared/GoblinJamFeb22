package scene;

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
		Assets.init(Game.globalEventBus);
	}

	public override function init():Void {
		var s2d = getScene();
		new Bitmap(hxd.Res.images.defeat_screen.toTile(), this);
		var t = new Text(Assets.font, this);
		t.text = "D E F E A T\n\nPress space to try again";
		t.textAlign = Align.MultilineCenter;
		t.y = 100;
		t.x = s2d.width / 2 - t.getSize().width / 2;
	}

	public override function update(dt:Float):Void {
		if (Key.isPressed(Key.SPACE)) {
			Game.globalEventBus.publishEvent(new ChangeSceneEvent(new PlayScene(getScene(), console)));
		}
	}
}
