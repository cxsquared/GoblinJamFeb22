package ecs.system;

import h2d.col.Point;
import ecs.utils.CameraUtils;
import ecs.component.Transform;
import ecs.component.Renderable;
import ecs.component.Camera;

class Renderer implements IPerEntitySystem {
	public var forComponents:Array<Class<Dynamic>> = [Renderable, Transform];

	var cameraTransform:Transform;
	var cameraComponent:Camera;

	public var camera(default, set):Entity;

	public function set_camera(newCamera:Entity) {
		cameraComponent = newCamera.get(Camera);
		cameraTransform = newCamera.get(Transform);
		return camera = newCamera;
	}

	public function new(camera:Entity) {
		this.camera = camera;
	}

	public function update(entity:Entity, dt:Float) {
		var renderable = entity.get(Renderable);
		var transform = entity.get(Transform);

		if (renderable.drawable == null)
			return;

		var point = new Point(transform.x + renderable.offsetX, transform.y + renderable.offsetY);
		var position = CameraUtils.worldToScreen(point, cameraComponent, new Point(cameraTransform.x, cameraTransform.y));

		renderable.drawable.setPosition(position.x, position.y);
		renderable.drawable.rotation = transform.rotation;
	}
}
