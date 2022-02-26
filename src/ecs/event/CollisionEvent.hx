package ecs.event;

class CollisionEvent implements IEvent {
	public var owner(default, null):Entity;
	public var target(default, null):Entity;

	public function new(owner:Entity, target:Entity) {
		this.owner = owner;
		this.target = target;
	}
}
