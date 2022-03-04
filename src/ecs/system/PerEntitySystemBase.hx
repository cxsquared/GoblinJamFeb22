package ecs.system;

class PerEntitySystemBase implements IPerEntitySystem {
	public function new(forComponents:Array<Class<Dynamic>>) {
		this.forComponents = forComponents;
	}

	public function update(entity:Entity, dt:Float) {
		throw "Abstract method call";
	}

	public var forComponents:Array<Class<Dynamic>>;

	public var fixed = true;

	public function destroy() {}
}
