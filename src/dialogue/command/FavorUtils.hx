package dialogue.command;

class FavorUtils {
	public static function getAmount(sign:String, amount:String):Int {
		var amount = Std.parseInt(amount);
		if (sign == "-") {
			amount *= -1;
		}

		return amount;
	}
}
