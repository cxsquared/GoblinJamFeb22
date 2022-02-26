package ecs.system;

interface IAllEntitySystems extends ISystem {
	function updateAll(entities:Array<Entity>, dt:Float):Void;
}
