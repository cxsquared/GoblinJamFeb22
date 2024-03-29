package ecs.system;

import ecs.event.CollisionEvent;
import ecs.component.Collidable;
import ecs.component.Transform;

class Collision extends AllEntitySystemBase {
	public function new() {
		super([Collidable, Transform]);
	}

	public override function updateAll(entities:Array<Entity>, dt:Float) {
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
			ec.previousEvent = ec.event;
			ec.event = null;
		}

		// check for collisions
		for (a in entities) {
			var ac = a.get(Collidable);

			if (ac.colliding)
				continue;

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
					var aevent = new CollisionEvent(a, b);
					var bevent = new CollisionEvent(b, a);
					if (ac.previousEvent == null) {
						ac.justEntered = true;
						bc.justEntered = true;
					} else {
						ac.justEntered = false;
						bc.justEntered = false;
					}

					ac.justExited = false;
					bc.justExited = false;

					ac.colliding = true;
					bc.colliding = true;

					ac.event = aevent;
					bc.event = bevent;
					break;
				}
			}
			if (ac.colliding == false) {
				if (ac.previousEvent != null) {
					ac.justExited = true;
					continue;
				}

				ac.justEntered = false;
				ac.justExited = false;
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
