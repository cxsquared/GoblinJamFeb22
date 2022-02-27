package assets;

import dialogue.DialogueManager;
import ecs.event.WorldReloaded;
import ecs.event.EventBus;

class Assets {
	public static var worldData:assets.World;
	public static var font:h2d.Font;

	static var _initDone = false;

	public static function init(eventBus:EventBus) {
		if (_initDone) {
			return;
		}

		_initDone = true;

		worldData = new assets.World();

		// LDtk file hot-reloading
		#if debug
		var res = try hxd.Res.load(worldData.projectFilePath.substr(4)) catch (_) null; // assume the LDtk file is in "res/" subfolder
		if (res != null)
			res.watch(() -> {
				// Only reload actual updated file from disk after a short delay, to avoid reading a file being written
				haxe.Timer.delay(function() {
					worldData.parseJson(res.entry.getText());
					eventBus.publishEvent(new WorldReloaded());
				}, 200);
			});
		#end

		font = hxd.Res.font.pixel_unicode.Pixel_UniCode_fnt.toFont();
		font.resizeTo(32);
	}
}
