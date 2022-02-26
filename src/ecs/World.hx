package ecs;

import h2d.Console;
import ecs.system.IPerEntitySystem;
import ecs.system.IAllEntitySystem.IAllEntitySystems;
import ecs.system.ISystem;
import ecs.component.IComponent;

class World {
	var entities:Array<Entity>;
	var components:Map<String, Map<Int, IComponent>>;
	var systems:Array<ISystem>;

	public function new() {
		entities = new Array<Entity>();
		components = new Map<String, Map<Int, IComponent>>();
		systems = new Array<ISystem>();
	}

	public function addEntity(?name:String) {
		var entity = new Entity(this, name);
		entities.push(entity);
		return entity;
	}

	public function removeEntity(entity:Entity) {
		for (component in components.keys()) {
			if (components[component].exists(entity.id)) {
				components[component][entity.id].remove();
				components[component].remove(entity.id);
			}
		}

		entities.remove(entity);
	}

	public function addSystem(s:ISystem) {
		systems.push(s);
	}

	public function getEntities():Array<Entity> {
		return entities;
	}

	public function getEntityByName(name:String):Entity {
		for (entitiy in entities) {
			if (entitiy.name == name) {
				return entitiy;
			}
		}

		return null;
	}

	public function getComponent<T:IComponent>(entity:Entity, component:Class<T>):Null<T> {
		var className = Type.getClassName(component);
		if (!components.exists(className))
			return null;

		if (!components[className].exists(entity.id))
			return null;

		return cast components[className][entity.id];
	}

	public function getAllComponentsForEntity(entity:Entity):Array<IComponent> {
		var components = new Array<IComponent>();
		for (component in this.components.keys()) {
			if (this.components[component].exists(entity.id))
				components.push(this.components[component][entity.id]);
		}

		return components;
	}

	public function hasComponent<T:IComponent>(entity:Entity, component:Class<T>):Bool {
		var className = Type.getClassName(component);
		if (!components.exists(className))
			return false;

		return components[className].exists(entity.id);
	}

	public function addComponent<T:IComponent>(entityId:Int, component:T) {
		var componentType = Type.getClassName(Type.getClass(component));
		if (components[componentType] == null) {
			components[componentType] = new Map<Int, IComponent>();
		}

		components[componentType][entityId] = component;
	}

	public function removeComponent<T:IComponent>(entityId:Int, component:Class<T>) {
		var className = Type.getClassName(component);
		if (!components.exists(className))
			return;

		if (!components[className].exists(entityId))
			return;

		var component = components[className][entityId];
		components[className].remove(entityId);
		component.remove();
	}

	public function update(dt:Float) {
		for (system in systems) {
			var entitiesToProcess = entities;
			for (type in system.forComponents) {
				entitiesToProcess = getEntitiesWithComponent(entitiesToProcess, Type.getClassName(type));
			}

			if (Std.isOfType(system, IAllEntitySystems)) {
				Std.downcast(system, IAllEntitySystems).updateAll(entitiesToProcess, dt);
				continue;
			}

			var perEntitySystem = Std.downcast(system, IPerEntitySystem);

			for (entity in entitiesToProcess) {
				perEntitySystem.update(entity, dt);
			}
		}
	}

	public function debugLog(console:Console) {
		console.log("World");
		console.log("Entities:");
		for (entity in entities) {
			var color = Std.int(Math.random() * 0xFFFFFF);
			console.log('id: ${entity.id}', color);
			console.log('name: ${entity.name}', color);
			console.log("components: ", color);
			for (type in components.keys()) {
				if (components[type].exists(entity.id)) {
					console.log('type: $type', color);
					components[type][entity.id].log(console, color);
				}
			}
		}
	}

	public function debugEntity(console:Console, name:String) {
		for (entity in entities) {
			if (entity.name != name)
				continue;

			var color = Std.int(Math.random() * 0xFFFFFF);
			console.log('id: ${entity.id}', color);
			console.log("components: ", color);
			for (type in components.keys()) {
				if (components[type].exists(entity.id)) {
					console.log('type: $type', color);
					components[type][entity.id].log(console, color);
				}
			}
		}
	}

	function getEntitiesWithComponent(entitiesToFilter:Array<Entity>, componentType:String) {
		var entitiesWithComponent = new Array<Entity>();
		if (!components.exists(componentType))
			return entitiesWithComponent;

		for (entity in entitiesToFilter) {
			if (components[componentType][entity.id] != null) {
				entitiesWithComponent.push(entity);
			}
		}
		return entitiesWithComponent;
	}
}
