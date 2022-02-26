package event;

import constant.CityNames.CityName;
import ecs.event.IEvent;

class NewQuest implements IEvent {
	public var nearset:Bool;
	public var target:CityName;
	public var completeQuestNode:String = "";

	public function new() {}
}
