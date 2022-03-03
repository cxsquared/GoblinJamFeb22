package ecs.event;

import h2d.Console;

class EventBus {
	var listeners = new Map<String, Array<Dynamic>>();
	var console:Console;

	public function new(console:Console) {
		this.console = console;
	}

	public function subscribe<T:IEvent>(event:Class<T>, callback:(T) -> Void) {
		var type = Type.getClassName(event);
		if (!listeners.exists(type))
			listeners.set(type, new Array<T>());

		listeners.get(type).push(callback);
	}

	public function unsubscribe<T:IEvent>(event:Class<T>, callback:(T) -> Void) {
		var type = Type.getClassName(event);
		if (!listeners.exists(type))
			return;

		var callbacks = listeners.get(type);
		for (c in callbacks) {
			if (Reflect.compareMethods(c, callback)) {
				callbacks.remove(c);
				return;
			}
		}
	}

	public function publishEvent<T:IEvent>(event:T) {
		var type = Type.getClassName(Type.getClass(event));
		if (!listeners.exists(type)) {
			#if debug
			console.log('Publishing event with no listeners: $type');
			#end
			return;
		}

		for (func in listeners.get(type))
			func(event);
	}
}
