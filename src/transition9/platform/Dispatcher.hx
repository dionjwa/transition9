package transition9.platform;


// Designed to pass on platform/ui/signal events between platforms, and
// bridge websockets/html callbacks, and UI events.
class Dispatcher
{
	public static var global :Dispatcher = new Dispatcher();

	var _maxMessagesPerTick :Int = 1;
	var _queue :

	function new()
	{

	}

	public function onMessageRecieved(msgId :String, ?payload :Dynamic)
	{

	}

	public function dispatch(msgId :String, ?payload :Dynamic)
	{

	}

	public function setMaxMessagesPerTick(val :Int) :Dispatcher
	{
		_maxMessagesPerTick = val;
		return this;
	}

	public function onTick(dt :Float)
	{

	}
}

@:build(transition9.macro.ClassMacros.addObjectPooling())
class Message
{
	public function new()
	{

	}
}