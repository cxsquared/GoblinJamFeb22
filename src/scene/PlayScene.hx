package scene;

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

class PlayScene extends GameScene {
	var world:World;

	public function new(heapsScene:Scene, console:Console) {
		super(heapsScene, console);
	}

	public override function init():Void {
		var s2d = getScene();
		this.world = new World();

		var playerSize = 32;
		var playerX = s2d.width / 2 - playerSize / 2;
		var playerY = s2d.height / 2 - playerSize / 2;
		var player = world.addEntity("Hello World")
			.add(new Player())
			.add(new Transform(playerX, playerY, playerSize, playerSize))
			.add(new Velocity(0, 0))
			.add(new Renderable(new Bitmap(Tile.fromColor(0xFF0000, playerSize, playerSize), this)));

		var cameraBounds = Bounds.fromValues(0, 0, s2d.width, s2d.height);
		var camera = world.addEntity("Camera")
			.add(new Transform())
			.add(new Velocity(0, 0))
			.add(new Camera(player, cameraBounds, s2d.width / 2, s2d.height / 2));

		world.addSystem(new PlayerController());
		world.addSystem(new CameraController(s2d, console));
		world.addSystem(new Renderer(camera));
	}

	public override function update(dt:Float):Void {
		world.update(dt);
	}
}
