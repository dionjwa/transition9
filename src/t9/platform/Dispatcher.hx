package t9.platform;

import de.polygonal.ds.PriorityQueue;
import de.polygonal.ds.Prioritizable;

// import t9.remoting.jsonrpc.RPC;

@:coreType abstract Seconds from Float to Float { }

typedef Disposable = {var dispose:Void->Void;};

/**
 * Designed to pass on platform/ui/signal events between platforms, and
 * bridge websockets/html callbacks, and UI events.
 * AND integrating long running/cpu blocking processes that
 * would interfere with UI events.
 */
@:build(t9.macro.ClassMacros.addSingletonPattern())
class Dispatcher
#if flambe
	implements flambe.platform.Tickable
#end
{
	var _maxMessagesPerTick :Int = 1;
	var _queue :PriorityQueue<Message>;
	var _maxTimePerTick :Seconds; //Seconds
	var _listeners0 :Map<String, Array<Void->Void>>;
	var _listeners1 :Map<String, Array<Dynamic->Void>>;
	var _timer :haxe.Timer;

	public var size (get, null) :Int;

	public function new()
	{
		_queue = new PriorityQueue();
		_maxTimePerTick = 50;
		_maxMessagesPerTick = 1;
		_listeners0 = new Map<String, Array<Void->Void>>();
		_listeners1 = new Map<String, Array<Dynamic->Void>>();

		#if flambe
		_addedToMainLoop = false;
		#end
	}

	public function addListener0(eventId :String, handler :Void->Void) :Disposable
	{
		if (!_listeners0.exists(eventId)) {
			_listeners0.set(eventId, []);
		}
		var list = _listeners0.get(eventId);

		var index = -1;
		for (i in 0...list.length) {
			if (list[i] == null) {
				index = i;
				break;
			}
		}
		if (index == -1) {
			index = list.length;
		}

		list.insert(index, handler);

		var dispose = function() :Void {
			list[index] = null;
		}

		return {dispose:dispose};
	}

	public function addListener1(eventId :String, handler :Dynamic->Void) :Disposable
	{
		if (!_listeners1.exists(eventId)) {
			_listeners1.set(eventId, []);
		}
		var list = _listeners1.get(eventId);

		var index = -1;
		for (i in 0...list.length) {
			if (list[i] == null) {
				index = i;
				break;
			}
		}
		if (index == -1) {
			index = list.length;
		}

		list.insert(index, handler);

		var dispose = function() {
			list[index] = null;
		}

		return {dispose:dispose};
	}

	public function addMessageToQueue(messageId :String, ?payload :Dynamic, ?priority :Float = 0)
	{
		var msg = Message.fromPool();
		msg.messageId = messageId;
		msg.payload = payload;
		msg.priority = priority;
		_queue.enqueue(msg);
	}

	public function addTask(id :String, onTick :Float->Bool, ?priority :Float = -1, ?onComplete :Void->Void) :Disposable //Priority is less than the default
	{
		var msg = Message.fromPool();
		msg.priority = priority;
		msg.onTick = onTick;
		msg.onComplete = onComplete;
		_queue.enqueue(msg);
		var isDisposed = false;
		msg.onDispose = function() {
			isDisposed = true;
		};

		return {dispose:function() {
			if (isDisposed) {
				return;
			}
			_queue.remove(msg);
			msg.dispose();
		}};
	}

	public function setMaxMessagesPerTick(val :Int) :Dispatcher
	{
		_maxMessagesPerTick = val;
		return this;
	}

	public function setMaxTimePerTick(val :Float) :Dispatcher
	{
		_maxTimePerTick = val;
		return this;
	}

	/** Plug this into your timer of choice. */
	public function onTick(dt :Seconds)
	{
		// trace("dispatcher.onTick");
		var elapsed :Seconds = 0;
		var processedMessages = 0;

		while (_queue.size() > 0 && elapsed < _maxTimePerTick && processedMessages < _maxMessagesPerTick) {
			var msg = _queue.peek();

			var now :Seconds = haxe.Timer.stamp();
			if (msg.onTick != null) {
				var isFinished = msg.onTick(dt);
				if (isFinished) {
					//Ok, we're finished
					if (msg.onComplete != null) {
						msg.onComplete();
					}
					dispatchMessage(msg);
					_queue.dequeue().dispose();
				}//Otherwise it's not finished.
			} else {
				dispatchMessage(msg);
				_queue.dequeue().dispose();
			}
			elapsed += haxe.Timer.stamp() - now;
			processedMessages++;
		}
	}

	/** Sends the message to listeners */
	function dispatchMessage(message :Message)
	{
		if (_listeners0.exists(message.messageId)) {
			var list = _listeners0.get(message.messageId);
			for (i in 0...list.length) {
				if (list[i] != null) {
					list[i]();
				}
			}
		}

		if (_listeners1.exists(message.messageId)) {
			var list = _listeners1.get(message.messageId);
			for (i in 0...list.length) {
				if (list[i] != null) {
					list[i](message.payload);
				}
			}
		}
	}

	public function useDefaultTimer(ms :Int = 17) :Dispatcher
	{
		if (_timer != null) {
			_timer.stop();
		}
		_timer = new haxe.Timer(ms);
		var prev :Seconds = haxe.Timer.stamp();
		var now :Seconds = haxe.Timer.stamp();
		var dt :Seconds = 0;
		_timer.run = function() {
			now = haxe.Timer.stamp();
			dt = now - prev;
			onTick(dt);
			prev = now;
		}
		return this;
	}

	function get_size() :Int
	{
		return _queue.size();
	}

#if flambe
	var _addedToMainLoop :Bool;
	public function useFlambeMainloop()
	{
		if (_timer != null) {
			_timer.stop();
			_timer = null;
		}
		if (!_addedToMainLoop) {
			flambe.System.init();
			var mainLoop :flambe.platform.MainLoop = Reflect.field(Reflect.field(flambe.System, "_platform"), "mainLoop");
			mainLoop.addTickable(this);
			_addedToMainLoop = true;
		}
	}

	public function update (dt :Float) :Bool
	{
		onTick(dt);
		return false;
	}
#end
}

