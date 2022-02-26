package ecs;

import ecs.component.IComponent;
import ecs.system.DebugEntityController.DebugLocation;

class Entity {
	static var lastId = 0;

	public var id(default, null):Int;
	public var name(default, null):String;
	public var debugText:Entity;
	public var isDebugEntity = false;
	public var debugLocation = DebugLocation.Top;
	public var debug = false;

	var world:World;

	public function new(world:World, ?name:String):Void {
		this.id = Entity.lastId++;
		this.world = world;
		if (name != null || name == "") {
			this.name = name;
		} else {
			this.name = Std.string(id);
		}
	}

	public function buildDebugText():String {
		var sb = new StringBuf();

		sb.add('Id:$name');
		for (component in getAll()) {
			sb.add('\n${component.debugText()}');
		}
		return sb.toString();
	}

	public function add(component:IComponent):Entity {
		world.addComponent(id, component);

		return this;
	}

	public function get<T:IComponent>(component:Class<T>):Null<T> {
		return world.getComponent(this, component);
	}

	public function getAll():Array<IComponent> {
		return world.getAllComponentsForEntity(this);
	}

	public function has<T:IComponent>(component:Class<T>):Bool {
		return world.hasComponent(this, component);
	}

	public function remove<T:IComponent>(component:Class<T>):Void {
		return world.removeComponent(this.id, component);
	}

	public function destroy() {
		if (!isDebugEntity && debugText != null)
			debugText.destroy();

		world.removeEntity(this);
	}
}
