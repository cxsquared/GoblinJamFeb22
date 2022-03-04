package system;

import ecs.system.PerEntitySystemBase;
import component.Player;
import event.EnteredCity;
import ecs.event.EventBus;
import ecs.component.Collidable;
import component.City;
import component.UiBar;
import ecs.Entity;

class CityController extends PerEntitySystemBase {
	var eventBus:EventBus;

	public function new(eventBus:EventBus) {
		super([City, UiBar, Collidable]);
		this.eventBus = eventBus;
	}

	public override function update(entity:Entity, dt:Float) {
		var city = entity.get(City);
		var uiBar = entity.get(UiBar);
		var c = entity.get(Collidable);

		uiBar.value = city.favor;
		uiBar.maxValue = city.maxFavor;

		if (c.justEntered && c.event != null && c.event.target.has(Player)) {
			eventBus.publishEvent(new EnteredCity(city));
		}
	}
}
