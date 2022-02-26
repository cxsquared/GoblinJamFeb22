package dialogue;

import hxyarn.dialogue.Command;
import hxyarn.dialogue.OptionSet;
import hxyarn.dialogue.Line;
import hxyarn.compiler.Compiler;
import hxyarn.dialogue.StringInfo;
import hxyarn.dialogue.Dialogue;
import hxyarn.dialogue.VariableStorage.MemoryVariableStore;
import hxyarn.dialogue.markup.MarkupParseResult;
import hxyarn.compiler.CompilationJob;
import ecs.event.EventBus;
import dialogue.event.StartNode;
import dialogue.event.DialogueComplete;
import dialogue.event.OptionSelected;
import dialogue.event.OptionsShown;
import dialogue.event.NextLine;
import dialogue.event.LineShown;
import dialogue.event.OptionsShown.OptionChoice;

class DialogueManager {
	var storage = new MemoryVariableStore();
	var dialogue:Dialogue;
	var stringTable:Map<String, StringInfo>;
	var lastNodeName:String;
	var runningDialouge:Bool = false;

	var eventBus:EventBus;

	public var waitingForOption:Bool = false;

	public function new(eventBus:EventBus) {
		this.eventBus = eventBus;
		dialogue = new Dialogue(storage);

		dialogue.logDebugMessage = this.logDebugMessage;
		dialogue.logErrorMessage = this.logErrorMessage;
		dialogue.lineHandler = this.lineHandler;
		dialogue.optionsHandler = this.optionsHandler;
		dialogue.commandHandler = this.commandHandler;
		dialogue.nodeCompleteHandler = this.nodeCompleteHandler;
		dialogue.nodeStartHandler = this.nodeStartHandler;
		dialogue.dialogueCompleteHandler = this.dialogueCompleteHandler;

		eventBus.subscribe(NextLine, this.nextLine);
		eventBus.subscribe(OptionSelected, this.optionSelected);
		eventBus.subscribe(StartDialogueNode, function(event) {
			this.runNode(event.node);
		});
	}

	public function setPlayerName(name:String) {
		storage.setValue("$playerName", name);
	}

	public function load(texts:Array<String>, names:Array<String>) {
		var job = CompilationJob.createFromStrings(texts, names, dialogue.library);
		var compiler = Compiler.compile(job);
		stringTable = compiler.stringTable;

		dialogue.addProgram(compiler.program);
	}

	public function runNode(nodeName:String) {
		dialogue.setNode(nodeName);
		dialogue.resume();
	}

	public function unload() {
		dialogue.unloadAll();
	}

	public function resume() {
		dialogue.resume();
	}

	public function logDebugMessage(message:String):Void {}

	public function logErrorMessage(message:String):Void {}

	public function nextLine(event:NextLine) {
		if (dialogue.isActive())
			dialogue.resume();
	}

	public function stop() {
		eventBus.publishEvent(new DialogueComplete(lastNodeName));
		lastNodeName = "";
		waitingForOption = false;
		runningDialouge = false;
		dialogue.stop();
	}

	public function lineHandler(line:Line) {
		var markupResults = getMarkupForLine(line);
		eventBus.publishEvent(new LineShown(markupResults));
	}

	public function optionsHandler(options:OptionSet) {
		var optionChoices = new Array<OptionChoice>();

		for (i => option in options.options) {
			var text = getComposedTextForLine(option.line);
			optionChoices.push({
				text: text,
				index: i,
				enabled: option.enabled
			});
		}

		eventBus.publishEvent(new OptionsShown(optionChoices));

		waitingForOption = true;
	}

	public function optionSelected(event:OptionSelected) {
		dialogue.setSelectedOption(event.index);
		dialogue.resume();
		waitingForOption = false;
	}

	function getMarkupForLine(line:Line):MarkupParseResult {
		var substitutedText = Dialogue.expandSubstitutions(stringTable[line.id].text, line.substitutions);

		return dialogue.parseMarkup(substitutedText);
	}

	function getComposedTextForLine(line:Line):String {
		return getMarkupForLine(line).text;
	}

	public function commandHandler(command:Command) {}

	public function nodeCompleteHandler(nodeName:String) {
		lastNodeName = nodeName;
	}

	public function nodeStartHandler(nodeName:String) {
		runningDialouge = true;
	}

	public function dialogueCompleteHandler() {
		runningDialouge = false;
		lastNodeName = "";
		eventBus.publishEvent(new DialogueComplete(lastNodeName));
	}

	public function isActive() {
		return runningDialouge;
	}
}
