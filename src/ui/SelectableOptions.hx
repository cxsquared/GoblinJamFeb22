package ui;

import h2d.Tile;
import constant.GameAction;
import dn.heaps.input.ControllerAccess;
import h2d.Interactive;
import h2d.Drawable;
import h2d.filter.Glow;
import h2d.HtmlText;
import assets.Assets;
import h2d.ScaleGrid;
import h2d.Object;
import h2d.Flow;

typedef SelectOption = {
	text:String,
	callback:() -> Void
};

class SelectableOptions extends Flow {
	public var currentSelectedOptionIndex = 0;
	public var onSelectCallback:() -> Void = null;
	public var bgTile:Tile = null;

	var options:Array<SelectOption>;
	var ca:ControllerAccess<GameAction>;

	public function new(ca:ControllerAccess<GameAction>, bgTile:Tile, ?parent:Object) {
		super(parent);
		this.ca = ca;
		this.bgTile = bgTile;
	}

	public function clearOptions() {
		this.removeChildren();
		currentSelectedOptionIndex = 0;
	}

	public function setOptions(options:Array<SelectOption>, width:Float, height:Float) {
		clearOptions();

		this.options = options;

		for (index => option in options) {
			var button = new ScaleGrid(bgTile, 4, 4, this);

			if (index == currentSelectedOptionIndex) {
				button.filter = new Glow();
			}

			var text = new HtmlText(Assets.font, button);
			text.setPosition(8, 8);
			text.text = option.text;

			button.width = width;
			button.height = height;

			var i = new Interactive(width, height, button);
			i.onClick = function(e) {
				option.callback();
			};
			i.onOver = function(e) {
				var currHighlight = cast(getChildAt(currentSelectedOptionIndex), Drawable);
				if (currHighlight != null) {
					currHighlight.filter = null;
				}

				var newHighlight = cast(getChildAt(index), Drawable);
				newHighlight.filter = new Glow();
				currentSelectedOptionIndex = index;
			};
			i.onOut = function(e) {
				var thisButton = cast(getChildAt(index), Drawable);
				thisButton.filter = null;
			};
		}
	}

	public function select() {
		if (onSelectCallback != null)
			onSelectCallback();

		options[currentSelectedOptionIndex].callback();
	}

	public function update() {
		if (ca.isPressed(Select)) {
			select();
		}

		if (ca.isPressed(SelectDown)) {
			// unhighlight
			var curButton = cast(getChildAt(currentSelectedOptionIndex), Drawable);
			curButton.filter = null;

			// select new
			currentSelectedOptionIndex = (currentSelectedOptionIndex + 1) % numChildren;

			// highlight
			var newButton = cast(getChildAt(currentSelectedOptionIndex), Drawable);
			newButton.filter = new Glow();
		}

		if (ca.isPressed(SelectUp)) {
			// unhighlight
			var curButton = cast(getChildAt(currentSelectedOptionIndex), Drawable);
			curButton.filter = null;

			// select new
			currentSelectedOptionIndex = currentSelectedOptionIndex - 1;
			if (currentSelectedOptionIndex < 0) {
				currentSelectedOptionIndex = numChildren - 1;
			}

			// highlight
			var newButton = cast(getChildAt(currentSelectedOptionIndex), Drawable);
			newButton.filter = new Glow();
		}

		// NumKeys
		if (numChildren > 0 && ca.isPressed(MenuSelect1)) {
			currentSelectedOptionIndex = 0;
			select();
		}
		if (numChildren > 1 && ca.isPressed(MenuSelect2)) {
			currentSelectedOptionIndex = 1;
			select();
		}
		if (numChildren > 2 && ca.isPressed(MenuSelect3)) {
			currentSelectedOptionIndex = 2;
			select();
		}
		if (numChildren > 3 && ca.isPressed(MenuSelect4)) {
			currentSelectedOptionIndex = 3;
			select();
		}
		if (numChildren > 4 && ca.isPressed(MenuSelect5)) {
			currentSelectedOptionIndex = 4;
			select();
		}
	}
}
