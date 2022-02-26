package system;

import hxd.Key;
import hxd.Math;
import ecs.Entity;
import ecs.system.IPerEntitySystem;
import ecs.component.Velocity;
import ecs.component.Transform;
import component.Player;

class PlayerController implements IPerEntitySystem {
	public var forComponents:Array<Class<Dynamic>> = [Player, Velocity, Transform];

	public function new() {}

	public function update(entity:Entity, dt:Float) {
		var up = Key.isDown(Key.UP) || Key.isDown(Key.W);
		var left = Key.isDown(Key.LEFT) || Key.isDown(Key.A);
		var right = Key.isDown(Key.RIGHT) || Key.isDown(Key.D);
		var down = Key.isDown(Key.DOWN) || Key.isDown(Key.S);

		var t = entity.get(Transform);
		var v = entity.get(Velocity);
		var p = entity.get(Player);

		if (up)
			v.dy -= p.accel;

		if (down)
			v.dy += p.accel;

		if (left)
			v.dx -= p.accel;

		if (right)
			v.dx += p.accel;

		v.dx = Math.clamp(v.dx * v.friction, -p.maxSpeed, p.maxSpeed);
		v.dy = Math.clamp(v.dy * v.friction, -p.maxSpeed, p.maxSpeed);

		t.x += v.dx * dt;
		t.y += v.dy * dt;
	}
}
