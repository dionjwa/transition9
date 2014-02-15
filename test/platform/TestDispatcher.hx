package platform;

import transition9.platform.Dispatcher;

class TestDispatcher extends haxe.unit.TestCase
{
	function dispatcherQueuing (dispatcher :Dispatcher, tick :Void->Void) :Void
	{
		var events = [];
		var eventsDispatched = [];
		for (i in 0...4) {
			events.push("event" + i);
			eventsDispatched.push(false);

			var index = i;
			dispatcher.addListener1(events[index],
				function(payload){
					eventsDispatched[index] = true;
					for (x in 0...index) {
						if (eventsDispatched[x]) {
							assertTrue(false);
						}
					}

				});
		}

		dispatcher.onMessageRecieved(events[0], null, 0);
		dispatcher.onMessageRecieved(events[2], null, 2);
		dispatcher.onMessageRecieved(events[3], null, 3);
		dispatcher.onMessageRecieved(events[1], null, 1);

		assertTrue(dispatcher.size == 4);

		tick();
		assertTrue(dispatcher.size == 3);
		tick();
		assertTrue(dispatcher.size == 2);
		tick();
		assertTrue(dispatcher.size == 1);
		tick();
		assertTrue(dispatcher.size == 0);

		for (x in 0...events.length) {
			assertTrue(eventsDispatched[x]);
		}
	}

	#if (flambe && nodejs)
	public function testDispatcherQueuingFlambe () :Void
	{
		var dispatcher = new Dispatcher();
		var platform :flambe.platform.node.NodePlatform = Reflect.field(flambe.System, "_platform");
		platform.stopMainLoop();
		dispatcher.useFlambeMainloop();
		var tick = function() {
			platform.step(0.03);
		}
		dispatcherQueuing(dispatcher, tick);
	}
	#end

	public function testDispatcherQueuing () :Void
	{
		var dispatcher = new Dispatcher();
		var tick = function() {
			dispatcher.onTick(0.03);
		}
		dispatcherQueuing(dispatcher, tick);
	}

	public function testLongProcesses () :Void
	{
		var dispatcher = new Dispatcher();

		var events = [];
		var eventsDispatched = [];
		for (i in 0...4) {
			events.push("event" + i);
			eventsDispatched.push(false);

			var index = i;
			dispatcher.addListener1(events[index],
				function(payload){
					eventsDispatched[index] = true;
					for (x in 0...index) {
						if (eventsDispatched[x]) {
							assertTrue(false);
						}
					}

				});
		}

		var total :Int = 0;
		var longProcess = function(dt :Float) :Bool {
			//Make sure all the other events are done
			for(v in eventsDispatched) {
				assertTrue(v);
			}

			total++;
			return total >= 4;
		}

		var isComplete = false;
		var longProcessComplete = function() {
			isComplete = true;
		}

		dispatcher.addTask("someid", longProcess, -1, longProcessComplete);

		dispatcher.onMessageRecieved(events[0], null, 0);
		dispatcher.onMessageRecieved(events[2], null, 2);
		dispatcher.onMessageRecieved(events[3], null, 3);
		dispatcher.onMessageRecieved(events[1], null, 1);

		assertTrue(dispatcher.size == 5);

		dispatcher.onTick(0.03);
		assertTrue(dispatcher.size == 4);
		assertTrue(total == 0);
		dispatcher.onTick(0.03);
		assertTrue(dispatcher.size == 3);
		dispatcher.onTick(0.03);
		assertTrue(dispatcher.size == 2);
		dispatcher.onTick(0.03);
		assertTrue(total == 0);
		assertTrue(dispatcher.size == 1);

		dispatcher.onTick(0.03);
		assertTrue(total == 1);
		assertTrue(dispatcher.size == 1);
		assertFalse(isComplete);

		dispatcher.onTick(0.03);
		assertFalse(isComplete);
		assertTrue(dispatcher.size == 1);

		dispatcher.onTick(0.03);
		assertFalse(isComplete);
		assertTrue(dispatcher.size == 1);

		dispatcher.onTick(0.03);
		assertTrue(isComplete);
		assertTrue(dispatcher.size == 0);

#if flambe
		dispatcher.useFlambeMainloop();
#end
	}
}