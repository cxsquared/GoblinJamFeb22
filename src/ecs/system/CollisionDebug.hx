package ecs.system;

import h2d.col.Point;
import ecs.utils.CameraUtils;
import ecs.system.IAllEntitySystem.IAllEntitySystems;
import ecs.component.Camera;
import hxsl.Cache;
import ecs.component.Transform;
import hxd.Key;
import h2d.Object;
import ecs.component.Collidable;
import h2d.Graphics;

class CollisionDebug implements IAllEntitySystems {
	public var forComponents:Array<Class<Dynamic>> = [Collidable];

	var graphics = new Graphics();

	public var cameraTransform:Transform;
	public var camera:Camera;

	public function new(camera:Entity, ?parent:Object) {
		graphics = new Graphics(parent);
		this.camera = camera.get(Camera);
		this.cameraTransform = camera.get(Transform);
	}

	public function update(entity:Entity, dt:Float) {}

	public function updateAll(entities:Array<Entity>, dt:Float) {
		var toggle = false;
		if (Key.isPressed(Key.F1)) {
			toggle = true;
		}

		graphics.clear();
		graphics.beginFill(0x000000);

		for (e in entities) {
			var collidable = e.get(Collidable);
			if (toggle) {
				collidable.debug = !collidable.debug;
			}

			if (collidable.debug) {
				graphics.setColor(collidable.debugColor, .75);
				switch (collidable.shape) {
					case CIRCLE:
						var circle = collidable.circle;
						var point = CameraUtils.worldToScreen(new Point(circle.x, circle.y), camera, new Point(cameraTransform.x, cameraTransform.y));
						graphics.drawCircle(point.x, point.y, circle.ray);

					case BOUNDS:
						var bounds = collidable.bounds;
						var point = CameraUtils.worldToScreen(new Point(bounds.x, bounds.y), camera, new Point(cameraTransform.x, cameraTransform.y));
						graphics.drawRect(point.x, point.y, bounds.width, bounds.height);
				}
			}
		}

		graphics.endFill();
	}
}
