package dialogue.command;

interface ICommandHandler {
	var commandName:String;
	function handleCommand(args:Array<String>):Bool;
}
