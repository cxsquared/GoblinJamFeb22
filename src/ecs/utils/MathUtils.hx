package ecs.utils;

import hxd.Rand;
import h2d.col.Point;

class MathUtils {
	static var rand = new Rand(42);

	public static function normalizeToOne(value:Float, min:Float, max:Float):Float {
		return (value - min) / (max - min);
	}

	public static function getFourPointsAroundCenter(center:Point, itemWidth:Float, itemHeight:Float, padding:Float):Array<Point> {
		return [
			new Point(center.x - itemWidth - padding, center.y - itemHeight / 2),
			new Point(center.x - itemWidth / 2, center.y - itemHeight - padding),
			new Point(center.x + padding, center.y - itemHeight / 2),
			new Point(center.x - itemWidth / 2, center.y + padding)
		];
	}

	public static function roll(dice:Int, ?seed:Int):Int {
		if (seed != null)
			rand.init(seed);

		return rand.random(dice) + 1;
	}

	public static function getSign(value:Float):Int {
		return value > 0 ? 1 : value < 0 ? -1 : 0;
	}

	// https://stackoverflow.com/questions/23689001/how-to-reliably-format-a-floating-point-number-to-a-specified-number-of-decimal
	public static function floatToStringPrecision(n:Float, prec:Int) {
		n = Math.round(n * Math.pow(10, prec));
		var str = '' + n;
		var len = str.length;
		if (len <= prec) {
			while (len < prec) {
				str = '0' + str;
				len++;
			}
			return '0.' + str;
		} else {
			return str.substr(0, str.length - prec) + '.' + str.substr(str.length - prec);
		}
	}
}
