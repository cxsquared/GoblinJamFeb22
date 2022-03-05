package dialogue.command;

class ExampleCommand implements ICommandHandler {
	public var commandName:String = "example";

	public function handleCommand(args:Array<String>):Bool {
		trace(args);
		return true;
	}
}
