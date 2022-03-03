package ecs.utils;

import h2d.Console;

class WorldUtils {
	public static function registerConsoleDebugCommands(console:Console, world:World) {
		console.addCommand("toggleDebug", "toggles debug text for an entity", [{name: "entityName", t: ConsoleArg.AString, opt: true}],
			function(entityName:String) {
				if (entityName != null && entityName != "") {
					var e = world.getEntityByName(entityName);
					e.debug = !e.debug;
					return;
				}

				for (e in world.getEntities()) {
					e.debug = !e.debug;
				}
			});
	}
}
