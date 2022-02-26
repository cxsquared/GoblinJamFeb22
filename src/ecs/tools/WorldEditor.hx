package ecs.tools;

import hxd.Key;
import h2d.Flow.FlowAlign;
import ecs.ui.ViewComp;
import h2d.Scene;

class WorldEditor extends h2d.Object {
	var view:ViewComp;
	var world:World;

	public function new(parent:Scene) {
		super(parent);
		view = new ViewComp(FlowAlign.Left, [], this);
		view.minWidth = view.maxWidth = parent.width;
		view.minHeight = view.maxHeight = parent.height;
	}

	public function setWorld(world:World) {
		this.world = world;
	}

	public function setEntity(e:Entity) {
		var fields = Reflect.fields(e);
		var entityFields = new Array<EntityField>();
		for (field in fields) {
			entityFields.push(new EntityField(field, Reflect.getProperty(e, field)));
		}

		view.remove();
		view = new ViewComp(FlowAlign.Left, entityFields, this);
	}

	public function update() {
		if (Key.isPressed(Key.F2)) {
			this.visible = !this.visible;
		}
	}
}

class EntityField {
	public var name:String;
	public var data:Dynamic;

	public function new(name:String, data:Dynamic) {
		this.name = name;
		this.data = data;
	}
}
