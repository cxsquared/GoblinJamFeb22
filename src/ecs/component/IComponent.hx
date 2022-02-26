package ecs.component;

import h2d.Console;

interface IComponent {
	public function log(console:Console, ?color:Null<Int>):Void;
	public function debugText():String;
	public function remove():Void;
}
