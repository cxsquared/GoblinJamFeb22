package system;

import component.City;
import component.UiBar;
import ecs.Entity;
import ecs.system.IPerEntitySystem;

class CityController implements IPerEntitySystem {
	public function new() {}

	public function update(entity:Entity, dt:Float) {
		var city = entity.get(City);
		var uiBar = entity.get(UiBar);

		uiBar.value = city.favor;
		uiBar.maxValue = city.maxFavor;
	}

	public var forComponents:Array<Class<Dynamic>> = [City, UiBar];
}
