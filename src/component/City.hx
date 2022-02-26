package component;

import h2d.Console;
import constant.CityNames.CityName;
import ecs.component.IComponent;

class City implements IComponent {
	public var name:CityName;
	public var favor:Int = 100;

	public function new(name:CityName) {
		this.name = name;
	}

	public function log(console:Console, ?color:Int) {}

	public function debugText():String {
		return '[City] ${name.getName()}';
	}

	public function remove() {}
}
