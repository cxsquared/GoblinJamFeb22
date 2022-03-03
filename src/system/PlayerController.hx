package system;

import hxd.Event;
import event.DialogueHidden;
import h2d.Scene;
import ecs.event.EventBus;
import constant.Const;
import h2d.col.Point;
import constant.GameAction;
import dn.heaps.input.ControllerAccess;
import hxd.Timer;
import ecs.Entity;
import ecs.system.IPerEntitySystem;
import ecs.component.Velocity;
import ecs.component.Transform;
import component.Player;

class PlayerController implements IPerEntitySystem {
	public var forComponents:Array<Class<Dynamic>> = [Player, Velocity, Transform];

	var ca:ControllerAccess<GameAction>;
	var eventBus:EventBus;
	var stopPlayer = false;
	var newClick = false;
	var newX = 0.0;
	var newY = 0.0;
	var scene:Scene;

	public function new(ca:ControllerAccess<GameAction>, eventBus:EventBus, scene:Scene) {
		this.scene = scene;
		this.ca = ca;
		this.eventBus = eventBus;
		// Stop player when dialogue starts
		eventBus.subscribe(DialogueHidden, onDialogueHidden);
		scene.addEventListener(onEvent);
	}

	var deadzone = 0.25;

	function onDialogueHidden(e:DialogueHidden) {
		stopPlayer = true;
	}

	function onEvent(e:Event) {
		if (e.kind == EPush) {
			newClick = true;
			newX = e.relX;
			newY = e.relY;
		}
	}

	public function update(entity:Entity, dt:Float) {
		var t = entity.get(Transform);
		var v = entity.get(Velocity);
		var p = entity.get(Player);

		var controllerX = ca.getAnalogValue(GameAction.MoveX);
		var controllerY = ca.getAnalogValue(GameAction.MoveY);

		if (Math.abs(controllerX) > deadzone || Math.abs(controllerY) > deadzone) {
			updatePlayerInput(controllerX, controllerY, v, p);
			p.target = null;
		} else {
			updateClick(p, t);
			updatePlayerTarget(p, v, t);
		}

		updatePlayerTransform(v, p, t, dt);
		updateWalkAnimation(v, t);
	}

	function updatePlayerInput(x:Float, y:Float, v:Velocity, p:Player) {
		if (Math.abs(x) > deadzone)
			v.dx += p.accel * x;

		if (Math.abs(y) > deadzone)
			v.dy += p.accel * y;
	}

	function updateClick(p:Player, t:Transform) {
		if (newClick) {
			newClick = false;
			if (p.target == null)
				p.target = new Point();

			p.target.x = newX - t.width / 2;
			p.target.y = newY - t.height / 2;
		}
	}

	function updatePlayerTarget(p:Player, v:Velocity, t:Transform) {
		if (stopPlayer) {
			stopPlayer = false;
			v.dx = 0;
			v.dy = 0;
			p.target = null;
			return;
		}

		if (p.target == null)
			return;

		var current = new Point(t.x, t.y);
		// Stop if within half a tile
		if (Math.abs(current.distance(p.target)) < Const.TileSize / 3) {
			p.target = null;
			v.dx = 0;
			v.dy = 0;
			return;
		}

		var dir = p.target.sub(current);
		dir.normalize();
		v.dx += p.accel * dir.x;
		v.dy += p.accel * dir.y;
	}

	function updatePlayerTransform(v:Velocity, p:Player, t:Transform, dt:Float) {
		v.dx = hxd.Math.clamp(v.dx * v.friction, -p.maxSpeed, p.maxSpeed);
		v.dy = hxd.Math.clamp(v.dy * v.friction, -p.maxSpeed, p.maxSpeed);

		t.x += v.dx * dt;
		t.y += v.dy * dt;
	}

	function updateWalkAnimation(v:Velocity, t:Transform) {
		if (Math.abs(v.dx) + Math.abs(v.dy) > 16) {
			t.rotation = Math.sin(Timer.frameCount * .1) * .25;
		} else {
			v.dy = 0;
			v.dx = 0;
			t.rotation = 0;
		}
	}

	public function destroy() {
		scene.removeEventListener(onEvent);
		eventBus.unsubscribe(DialogueHidden, onDialogueHidden);
	}
}
