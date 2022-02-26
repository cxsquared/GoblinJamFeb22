package ecs.system;

interface IPerEntitySystem extends ISystem {
	function update(entity:Entity, dt:Float):Void;
}
