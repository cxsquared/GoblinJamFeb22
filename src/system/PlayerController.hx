package system;

import ecs.system.PerEntitySystemBase;
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
import ecs.component.Velocity;
import ecs.component.Transform;
import component.Player;

class PlayerController extends PerEntitySystemBase {
	var ca:ControllerAccess<GameAction>;
	var eventBus:EventBus;
	var stopPlayer = false;
	var newClick = false;
	var newX = 0.0;
	var newY = 0.0;
	var scene:Scene;

	public function new(ca:ControllerAccess<GameAction>, eventBus:EventBus, scene:Scene) {
		super([Player, Velocity, Transform]);
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

	public override function update(entity:Entity, dt:Float) {
		var t = entity.get(Transform);
		var v = entity.get(Velocity);
		var p = entity.get(Player);

		var controllerX = ca.getAnalogValue(GameAction.MoveX);
		var controllerY = ca.getAnalogValue(GameAction.MoveY);

		if (Math.abs(controllerX) > deadzone || Math.abs(controllerY) > deadzone) {
			updatePlayerInput(controllerX, controllerY, v);
			p.target = null;
		} else {
			updateClick(p, t);
			updatePlayerTarget(p, v, t);
		}

		updatePlayerTransform(v, t, dt);
		updateWalkAnimation(v, t, p);
	}

	function updatePlayerInput(x:Float, y:Float, v:Velocity) {
		if (Math.abs(x) > deadzone)
			v.dx += v.accel * x;

		if (Math.abs(y) > deadzone)
			v.dy += v.accel * y;
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
		v.dx += v.accel * dir.x;
		v.dy += v.accel * dir.y;
	}

	function updatePlayerTransform(v:Velocity, t:Transform, dt:Float) {
		v.dx = hxd.Math.clamp(v.dx * v.friction, -v.maxSpeed, v.maxSpeed);
		v.dy = hxd.Math.clamp(v.dy * v.friction, -v.maxSpeed, v.maxSpeed);

		t.x += v.dx * dt;
		t.y += v.dy * dt;
	}

	function updateWalkAnimation(v:Velocity, t:Transform, p:Player) {
		if (Math.abs(v.dx) > 4 || Math.abs(v.dy) > 4) {
			p.walkTick++;
			t.rotation = Math.sin(p.walkTick * .5) * .25;
		} else {
			p.walkTick = 0;
			t.rotation = 0;
		}
	}

	public override function destroy() {
		scene.removeEventListener(onEvent);
		eventBus.unsubscribe(DialogueHidden, onDialogueHidden);
	}
}
