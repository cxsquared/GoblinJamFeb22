package constant;

class Skill {
	public var name:SkillName;
	public var level:SkillLevel;

	public function new(name:SkillName, level:SkillLevel) {
		this.name = name;
		this.level = level;
	}

	public static function all():Array<Skill> {
		var skills = [];
		for (s in SkillName.createAll()) {
			skills.push(new Skill(s, SkillLevel.None));
		}

		return skills;
	}

	public static function isValid(name:String):Bool {
		for (n in SkillName.createAll()) {
			if (n.getName() == name) {
				return true;
			}
		}
		return false;
	}
}

enum SkillName {
	SwordFighting;
	Swimming;
	BreakDancing;
	Beyblading;
	TrashTalking;
	ShakespeareanKnowledge;
	Magic;
	Drinking;
	Drunking;
	WaitingTables;
	Sneak;
	Sprinting;
	Herbology;
	AnimalPetting;
	MooseKnowledge;
	LuteShredding;
	Programming;
	Housekeeping;
	Cooking;
}

enum SkillLevel {
	None;
	Basic;
	Advanced;
}
