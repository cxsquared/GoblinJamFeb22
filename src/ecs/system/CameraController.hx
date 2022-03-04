package ecs.system;

import hxd.Key;
import h2d.col.Point;
import ecs.component.Velocity;
import h2d.Scene;
import hxd.Math;
import h2d.Console;
import ecs.component.Transform;
import ecs.component.Camera;

class CameraController extends PerEntitySystemBase {
	var console:Console;
	var scene:Scene;

	public function new(scene:Scene, console:Console) {
		super([Camera, Transform, Velocity]);
		this.console = console;
		this.scene = scene;
	}

	public override function update(entity:Entity, dt:Float) {
		var t = cast entity.get(Transform);
		var v = cast entity.get(Velocity);
		var camera = cast entity.get(Camera);
		var target = camera.target;

		#if debug
		if (Key.isDown(Key.NUMPAD_ADD)) {
			camera.zoom += 0.1;
		}
		if (Key.isDown(Key.NUMPAD_SUB)) {
			camera.zoom -= 0.1;
		}
		#end

		// scene.scaleMode = Zoom(camera.zoom);

		if (target == null)
			return;

		if (!target.has(Transform)) {
			#if debug
			console.log("Camera target must have a Transform component");
			#end
			return;
		}

		var targetTransform = target.get(Transform);

		// Follow target entity
		var cameraPoint = new Point(t.x, t.y);
		var targetPoint = new Point(targetTransform.x + targetTransform.width / 2, targetTransform.y + targetTransform.height / 2);

		var d = cameraPoint.distance(targetPoint);
		if (d >= camera.deadzone) {
			var angle = Math.atan2(targetPoint.y - cameraPoint.y, targetPoint.x - cameraPoint.x);

			v.dx += Math.cos(angle) * (d - camera.deadzone) * camera.speed;
			v.dy += Math.sin(angle) * (d - camera.deadzone) * camera.speed;
		}

		// Movements
		t.x += v.dx;
		v.dx *= v.friction;

		t.y += v.dy;
		v.dy *= v.friction;
	}
}
