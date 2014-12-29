package async;

import com.dongxiguo.continuation.Async;

import t9.async.Step;

import js.Node;

using Lambda;
using StringTools;

/**
 * Step tests
 */
class Continuation
	implements Async
{
	public function new()
	{
		doit(function() {});
	}

	@async function doit()
	{
		var s = @await test();
		trace(s);
	}

	@async function test() :Array<String>
	{
		// var s = @await later();

		var items = ["aaa", "bbb", "ccc"];
		var results = [];
		for (item in items) {
			var processed = @await later(item);
			results.push(processed);
		}

		return results;
	}

	function later(s :String, cb :String->Void)
	{
		haxe.Timer.delay(function() {cb(s + "_processed");}, 100);
	}
}
