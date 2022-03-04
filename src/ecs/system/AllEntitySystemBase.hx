package ecs.system;

import ecs.system.IAllEntitySystem;

class AllEntitySystemBase implements IAllEntitySystem {
	public function new(forComponents:Array<Class<Dynamic>>) {
		this.forComponents = forComponents;
	}

	public function updateAll(entities:Array<Entity>, dt:Float) {
		throw "Abstract method not implemented.";
	}

	public var forComponents:Array<Class<Dynamic>>;

	public var fixed = true;

	public function destroy() {}
}
