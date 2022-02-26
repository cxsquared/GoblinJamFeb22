package constant;

class Skill {
	public var name:SkillName;
	public var level:SkillLevel;

	public function new(name:SkillName, level:SkillLevel) {
		this.name = name;
		this.level = level;
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
}

enum SkillLevel {
	None;
	Basic;
	Advanced;
}
