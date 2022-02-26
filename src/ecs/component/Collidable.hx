package ecs.component;

import ecs.event.CollisionEvent;
import h2d.col.Collider;
import h2d.Console;
import h2d.col.Bounds;
import h2d.col.Circle;

class Collidable implements IComponent {
	public var colliding = false;
	public var event:CollisionEvent;
	public var solid:Bool = false;
	public var debug = false;
	public var debugColor:Int;

	public var circle:Circle;
	public var bounds:Bounds;
	public var shape:CollisionShape;
	public var offsetX:Float = 0;
	public var offsetY:Float = 0;

	public var ignore = new Array<Class<Dynamic>>();

	public function getCollider():Collider {
		switch (shape) {
			case CIRCLE:
				return this.circle;
			case BOUNDS:
				return this.bounds;
		}
	}

	public function new(?shape:CollisionShape = CIRCLE, ?radius:Int = 15, ?width:Float, ?height:Float, ?debugColor:Int = 0xFF0000) {
		this.shape = shape;
		switch (shape) {
			case CIRCLE:
				this.circle = new Circle(0, 0, radius);
			case BOUNDS:
				this.bounds = new Bounds();
				this.bounds.set(0, 0, width, height);
		}
		this.debugColor = debugColor;
	}

	public function log(console:Console, ?color:Null<Int>):Void {
		console.log('Colliding: $colliding', color);
		console.log('shape: $shape', color);
		if (event != null) {
			console.log('Owner: ${event.owner.id}', color);
			console.log('Target: ${event.target.id}', color);
		}
	}

	public function remove() {}

	public function debugText():String {
		return '[Collidable] colliding: $colliding';
	}
}

enum CollisionShape {
	CIRCLE;
	BOUNDS;
}
