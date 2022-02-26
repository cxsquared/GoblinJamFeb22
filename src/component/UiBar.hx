package component;

import ui.Bar;
import h2d.Console;
import ecs.component.IComponent;

class UiBar implements IComponent {
	public var value:Float;
	public var maxValue:Float;
	public var bar:Bar;
	public var x:Float;
	public var y:Float;

	public function new() {}

	public function log(console:Console, ?color:Int) {}

	public function debugText():String {
		return '[UiBar] value: $value, maxValue: $maxValue';
	}

	public function remove() {}
}
