package ecs.system;

import component.Player;
import constant.Const;
import ecs.component.Velocity;
import ecs.component.Transform;
import ecs.component.Collidable;
import ecs.Entity;

class LevelCollisionController extends PerEntitySystemBase {
	public var viewOffsetX:Int = 0;
	public var viewOffsetY:Int = 0;

	var level:assets.World.Layer_Collision;
	var tileSize:Int = Const.TileSize;

	public function new(level:assets.World.Layer_Collision) {
		super([Transform, Player, Velocity]);
		// pass in layers to check for collision
		// from LDTK work
		this.level = level;
	}

	public override function update(entity:Entity, dt:Float) {
		var t = entity.get(Transform);
		var v = entity.get(Velocity);

		var dx = v.dx * dt;
		var dy = v.dy * dt;
		var steps = Math.ceil(Math.abs(dx) + Math.abs(dy)) / (tileSize / 3); // Steps is every 1/3rd of a tile

		if (steps <= 0)
			return;

		var x = t.x + t.width / 2 - viewOffsetX; // if the offset is set that means the level doesn't start at 0,0
		var y = t.y + t.height / 2 - viewOffsetY; // Should probably do the offset stuff with proper camera bounds but meh
		var cx = Std.int(x / tileSize);
		var cy = Std.int(y / tileSize);
		var xr = (x - cx * tileSize) / tileSize;
		var yr = (y - cy * tileSize) / tileSize;

		var n = 0;
		while (n < steps) {
			xr += dx / steps;

			if (dx != 0) {
				if (xr > 0.8 && hasCollision(cx + 1, cy)) {
					t.x += -v.dx * dt;
					v.dx = -v.dx * dt;
				}

				if (xr < 0.2 && hasCollision(cx - 1, cy)) {
					t.x += -v.dx * dt;
					v.dx = -v.dx * dt;
				}
			}

			yr += dy / steps;

			if (dy != 0) {
				if (yr > 0.8 && hasCollision(cx, cy + 1)) {
					t.y += -v.dy * dt;
					v.dy = -v.dy * dt;
				}

				if (yr < 0.2 && hasCollision(cx, cy - 1)) {
					t.y += -v.dy * dt;
					v.dy = -v.dy * dt;
				}
			}

			n++;
		}
	}

	function canCollide(c:Collidable) {
		if (c.colliding == false || c.solid == false || c.event == null)
			return false;

		var target = c.event.target;

		if (target == null)
			return false;

		var tc = target.get(Collidable);

		if (tc == null || tc.solid == false)
			return false;

		return true;
	}

	function hasCollision(cx:Int, cy:Int):Bool {
		// Update based on LDTK data
		return !isValid(cx, cy) ? true : level.getInt(cx, cy) == 1;
	}

	function isValid(cx:Int, cy:Int):Bool {
		// Update based on LDTK data
		return level.isCoordValid(cx, cy);
	}
}
