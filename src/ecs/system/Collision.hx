package ecs.system;

import ecs.event.CollisionEvent;
import ecs.system.IAllEntitySystem.IAllEntitySystems;
import ecs.component.Collidable;
import ecs.component.Transform;

class Collision implements IAllEntitySystems {
	public var forComponents:Array<Class<Dynamic>> = [Collidable, Transform];

	public function new() {}

	public function updateAll(entities:Array<Entity>, dt:Float) {
		// Update all positions
		for (e in entities) {
			var ec = e.get(Collidable);
			var et = e.get(Transform);
			switch (ec.shape) {
				case CIRCLE:
					ec.circle.x = et.x + et.width / 2 + ec.offsetX;
					ec.circle.y = et.y + et.height / 2 + ec.offsetY;
				case BOUNDS:
					ec.bounds.x = et.x + ec.offsetX;
					ec.bounds.y = et.y + ec.offsetY;
			}
			ec.colliding = false;
			ec.event = null;
		}

		// check for collisions
		for (a in entities) {
			var ac = a.get(Collidable);

			for (b in entities) {
				if (a.id == b.id)
					continue;

				var ignore = false;
				for (type in ac.ignore) {
					ignore = b.has(type);

					if (ignore)
						break;
				}

				if (ignore)
					continue;

				var bc = b.get(Collidable);

				if (overlaps(ac, bc)) {
					var event = new CollisionEvent(a, b);
					ac.colliding = true;
					ac.event = event;
					break;
				}
			}
		}
	}

	function overlaps(ac:Collidable, bc:Collidable):Bool {
		switch (ac.shape) {
			case CIRCLE:
				if (bc.shape == CIRCLE)
					return ac.circle.collideCircle(bc.circle);

				return ac.circle.collideBounds(bc.bounds);
			case BOUNDS:
				if (bc.shape == CIRCLE)
					return bc.circle.collideBounds(ac.bounds);

				return ac.bounds.intersects(bc.bounds);
		}

		return false;
	}
}
