package ecs.component;

import h2d.Console;
import h2d.Anim;

class Animation implements IComponent {
	public var anims = new Map<String, AnimInfo>();
	public var currentAnim:String;
	public var isDirty:Bool;

	public function new(?anims:Map<String, AnimInfo>) {
		if (anims != null)
			this.anims = anims;
	}

	public function addAnimation(name:String, anim:Anim, ?offsetX:Int = 0, offsetY:Int = 0, ?setCurrent:Bool = false) {
		var animInfo = new AnimInfo(anim);
		animInfo.offsetX = offsetX;
		animInfo.offsetY = offsetY;

		anims.set(name, animInfo);
		if (setCurrent) {
			play(name);
		}
	}

	public function play(name:String, ?force:Bool = false) {
		if (currentAnim == name && !force)
			return;

		isDirty = true;
		currentAnim = name;
		var currentInfo = getCurrent();
		currentInfo.anim.currentFrame = 0;
	}

	public function getCurrent() {
		var current = anims.get(currentAnim);
		if (current == null || current.anim == null)
			throw 'Animation ${currentAnim} not loaded. Please add the animation before playing it.';

		return current;
	}

	public function log(console:Console, ?color:Int) {}

	public function debugText():String {
		return '[Animation] currentAnim: $currentAnim, isDirty: $isDirty';
	}

	public function remove() {
		for (animInfo in anims) {
			animInfo.anim.remove();
		}
	}
}

class AnimInfo {
	public var anim:Anim;
	public var offsetX = 0;
	public var offsetY = 0;

	public function new(anim:Anim) {
		this.anim = anim;
	}
}
