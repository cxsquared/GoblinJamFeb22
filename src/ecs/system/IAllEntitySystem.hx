package ecs.system;

interface IAllEntitySystem extends ISystem {
	function updateAll(entities:Array<Entity>, dt:Float):Void;
}
