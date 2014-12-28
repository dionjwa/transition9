package transition9.platform;

import de.polygonal.ds.Prioritizable;

class Message
	implements transition9.macro.Pooling
	implements Prioritizable
{
	public var priority:Float;
	public var position:Int;

	public var messageId :String;
	public var payload :Dynamic;

	//If this is non-null, is called and the listeners aren't dispatched until it completes.
	public var onTick :Float->Bool;
	public var onComplete :Void->Void;
	public var onDispose :Void->Void;

	public function new()
	{
		priority = 0;
		position = 0;
	}

	public function dispose()
	{
		if (onDispose != null) {
			onDispose();
			onDispose = null;
		}
		priority = 0;
		position = 0;
		messageId = null;
		payload = null;
		onTick = null;
		onComplete = null;
	}
}