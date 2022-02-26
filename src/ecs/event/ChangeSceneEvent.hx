package ecs.event;

import ecs.scene.GameScene;

class ChangeSceneEvent implements IEvent {
	public var newScene:GameScene;

	public function new(gs:GameScene) {
		this.newScene = gs;
	}
}
