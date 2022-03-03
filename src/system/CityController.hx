package system;

import component.Player;
import event.EnteredCity;
import dn.heaps.slib.SpriteLib.FrameData;
import ecs.event.EventBus;
import ecs.component.Collidable;
import component.City;
import component.UiBar;
import ecs.Entity;
import ecs.system.IPerEntitySystem;

class CityController implements IPerEntitySystem {
	var eventBus:EventBus;

	public function new(eventBus:EventBus) {
		this.eventBus = eventBus;
	}

	public function update(entity:Entity, dt:Float) {
		var city = entity.get(City);
		var uiBar = entity.get(UiBar);
		var c = entity.get(Collidable);

		uiBar.value = city.favor;
		uiBar.maxValue = city.maxFavor;

		if (c.justEntered && c.event != null && c.event.target.has(Player)) {
			eventBus.publishEvent(new EnteredCity(city));
		}
	}

	public var forComponents:Array<Class<Dynamic>> = [City, UiBar, Collidable];

	public function destroy() {}
}
