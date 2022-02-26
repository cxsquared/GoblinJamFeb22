package ecs.system;

import h2d.col.Point;
import h2d.Drawable;
import ecs.component.Renderable;
import ecs.component.Transform;
import h2d.Object;
import hxd.res.DefaultFont;
import h2d.Text;
import ecs.World;
import ecs.Entity;
import ecs.system.IPerEntitySystem;

class DebugEntityController implements IPerEntitySystem {
	var world:World;
	var parent:Object;

	public function new(world:World, debugParent:Object) {
		this.world = world;
		this.parent = debugParent;
	}

	public function update(entity:Entity, dt:Float) {
		if (entity.isDebugEntity)
			return;

		if (entity.debug) {
			var debugEnity = entity.debugText;

			if (entity.debugText == null) {
				debugEnity = world.addEntity('debug:${entity.name}').add(new Transform());
				debugEnity.isDebugEntity = true;
				entity.debugText = debugEnity;
			}

			var r:Renderable = debugEnity.get(Renderable);
			var text:Text;
			if (r == null) {
				text = new Text(DefaultFont.get(), parent);
				text.text = entity.buildDebugText();
				r = new Renderable(text);
				debugEnity.add(r);
			} else {
				text = cast(r.drawable, Text);
			}

			text.text = entity.buildDebugText();

			var t = debugEnity.get(Transform);
			var et = entity.get(Transform);

			var point = getDebugLocation(et, entity.debugLocation, r.drawable);
			t.x = point.x;
			t.y = point.y;
		} else {
			var debugEnity = entity.debugText;

			if (debugEnity != null) {
				debugEnity.destroy();
				entity.debugText = null;
			}
		}
	}

	function getDebugLocation(t:Transform, location:DebugLocation, drawable:Drawable):Point {
		if (location == Top) {
			return new Point(t.x, t.y - drawable.getSize().height);
		}

		if (location == Bottom) {
			return new Point(t.x, t.y + t.height);
		}

		return new Point(t.x, t.y);
	}

	public var forComponents:Array<Class<Dynamic>> = [Transform];
}

enum DebugLocation {
	Top;
	Bottom;
}
