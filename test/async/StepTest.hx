package async;

import transition9.async.Step;
import transition9.async.AsyncLambda;

import js.Node;

using Lambda;

using StringTools;

/**
 * Step tests
 */
class StepTest
{
	public function new()
	{
	}

	/**
	@Before
	public function setup (cb :Void->Void) :Void
	{
		cb();
	}

	@After
	public function tearDown (cb :Void->Void) :Void
	{
		cb();
	}
	*/

	@AsyncTest
	public function testStep (onTestFinish :Err->Void, assert :Bool->?Dynamic->Void) :Void
	{
		var step = new Step();

		var delayed = function (input :String, cb :Dynamic->String->Void) :Void {
			haxe.Timer.delay(function () {
				cb(null, input);
			}, 100);
		}

		var parallel = function (input :String, cb :Dynamic->String->Void) :Void {
			haxe.Timer.delay(function () {
				cb(null, "p" + input);
			}, 100);
		}

		var parallelNoDelay = function (input :String, cb :Dynamic->String->Void) :Void {
			cb(null, "p" + input);
		}

		var group = function (input :String, cb :Dynamic->String->Void) :Void {
			haxe.Timer.delay(function () {
				cb(null, "g" + input);
			}, 100);
		}

		var parallelResult1 = "p1";
		var parallelResult2 = "p2";

		step.chain(
		[
			function () :Void {
				delayed("begin", step.cb);
			},
			function (err :Dynamic, input :String) :Void {
				parallel("1", step.parallel());
				parallel("2", step.parallel());
			},
			function (err :Dynamic, input1 :String, input2 :String) :Void {
				assert(input1 == parallelResult1, "input1 != parallelResult1");
				assert(input2 == parallelResult2, "input2 != parallelResult2");
				delayed(input1 + input2, step.cb);
			},
			function (err :Dynamic, input :String) :Void {
				assert(input == parallelResult1 + parallelResult2, "input == parallelResult1 + parallelResult2");
				delayed(input, step.cb);
			},
			function (err :Dynamic, input :String) :Void {
				assert(err == null, "err == null");
				parallelNoDelay("1", step.parallel());
				parallelNoDelay("2", step.parallel());
			},
			function (err :Dynamic, input1 :String, input2 :String) :Void {
				assert(input1 == parallelResult1, "input1 != parallelResult1");
				assert(input2 == parallelResult2, "input2 != parallelResult2");

				delayed(null, step.cb);
			},
			function (err :Dynamic, input :String) :Void {
				group("0", step.group());
				group("1", step.group());
				group("2", step.group());
				group("3", step.group());
				group("4", step.group());
			},
			function (err :Dynamic, input :Array<String>) :Void {
				assert(input.length == 5, "input.length == 5");

				for (ii in 0...5) {
					assert(input[ii] == "g" + ii, 'input[ii] == "g" + ii');
				}
				delayed(input.join(", "), step.cb);
			},
			function (err :Dynamic, input :String) :Void {
				onTestFinish(err);
			},
		]);
	}

	@AsyncTest
	public function testStepErrors (onTestFinish :Err->Void, assert :Bool->?Dynamic->Void) :Void
	{
		var step = new Step();

		var delayed = function (input :String, cb :Dynamic->String->Void) :Void {
			haxe.Timer.delay(function () {
				cb(null, input);
			}, 100);
		}

		var delayedError = function (cb :Dynamic->String->Void) :Void {
			haxe.Timer.delay(function () {
				cb("some error", null);
			}, 100);
		}

		step.chain(
		[
			function () :Void {
				delayed("begin", step.cb);
			},
			function (err :Dynamic, input :String) :Void {
				//Test error catching
				delayedError(step.cb);
			},
			function (err :Dynamic, input :String) :Void {
				assert(err != null, "What happened to the delayed error?");
				delayed("ignored", step.cb);
			},
			function (err :Dynamic, input :String) :Void {
				assert(err == null, "err != null");
				onTestFinish(null);
			},
		]);
	}

}
