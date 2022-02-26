package component;

import h2d.Console;
import constant.CityNames.CityName;
import ecs.component.IComponent;

class Encounter implements IComponent {
	public var cities:Array<CityName>;

	public function new(cities:Array<CityName>) {
		this.cities = cities;
	}

	public function log(console:Console, ?color:Int) {}

	public function debugText():String {
		return '[Encounter]';
	}

	public function remove() {}
}
