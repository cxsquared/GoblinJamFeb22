package ecs.system;

import ecs.component.IComponent;

interface ISystem {
	var forComponents:Array<Class<Dynamic>>;
	var fixed:Bool;
	function destroy():Void;
}
