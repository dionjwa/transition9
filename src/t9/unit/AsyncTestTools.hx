package t9.unit;

import Type;

import com.dongxiguo.continuation.Async;

import t9.async.AsyncLambda;
import t9.rtti.MetaUtil;

using StringTools;
using Lambda;

/**
  * Simple async testing.  Workds with Node.js
  */
class AsyncTestTools
	implements Async
{
	static var ASYNC_LABEL = "AsyncTest";

	public static function assert (check :Bool, errorCallback :Err->Void) :Void
	{
		if (!check) {
			try {
				throw "Error in async assert";
			} catch (err :Dynamic) {
				errorCallback(err);
			}
		}
	}

	public static function runTestsOn (testClasses :Array<Class<Dynamic>>) :Void
	{
		#if !debug
		throw "You must run the tests with the -debug";
		#end

		var allresults = [];
		AsyncLambda.iter(testClasses,
			function (cls :Class<Dynamic>, elementDone :Err->Void) :Void {
				AsyncTestTools.doTests(cls, function (results :TestResults) {
					allresults.push(results);
					elementDone(null);
				});
			},
			function (err) {

				var allok = true;
				var totalTests = 0;
				for (result in allresults) {
					totalTests += result.totalTests;
					if (result.testsPassed != result.totalTests) {
						Log.error("Failed on " + Type.getClassName(result.cls));
						allok = false;
						break;
					}
				}
				if (allok) {
					Log.info(totalTests + " test" + (totalTests > 1 ? "s" : "") + " completed OK");
					// untyped __js__('process.exit(0)');
					Sys.exit(0);
				} else {
					Log.error("TESTS FAILED: " + err);
					Sys.exit(1);
				}
			});
	}

	public static function doTests (cls :Class<Dynamic>, testsComplete:TestResults->Void)
	{
		var inst = Type.createInstance(cls, []);
		var className = Type.getClassName(cls);

		var syncTestQueue = [];
		var asyncTestQueue = [];

		for (fieldName in Type.getInstanceFields(cls)) {
			if (fieldName.startsWith("test")) {
				if (MetaUtil.isFieldMetaData(cls, fieldName, ASYNC_LABEL)) {
					asyncTestQueue.push(fieldName);
				} else {
					syncTestQueue.push(fieldName);
				}
			}
		}

		var totalTests :Int = syncTestQueue.length + asyncTestQueue.length;

		var testResults = new TestResults(cls, totalTests);

		//This is called when all tests have finished or timed out
		var onFinish = function (err :Err) :Void {
			if (testResults == null) return;
			testResults.err = err;
			testsComplete(testResults);
			testResults = null;
		}

		//Do the sync tests
		for (syncTestName in syncTestQueue) {
			try {
				Reflect.callMethod(inst, Reflect.field(inst, syncTestName), []);
				testResults.testsPassed++;
			} catch (e :Dynamic) {
				Log.error("    " + className + "::" + syncTestName + " Error: " + Std.string(e) + "\n" + haxe.CallStack.toString(haxe.CallStack.exceptionStack()));
			}
		}

		//Async setup and tear down
		var setup = function (cb :Void->Void) :Void {
			if (Type.getInstanceFields(cls).has("setup")) {
				var castedInst :{function setup(cb :Void->Void):Void;} = cast inst;
				castedInst.setup(cb);
			} else {
				cb();
			}
		}

		var tearDown = function (cb :Void->Void) :Void {
			if (Type.getInstanceFields(cls).has("tearDown")) {
				var castedInst :{function tearDown(cb :Void->Void):Void;} = cast inst;
				castedInst.tearDown(
					function() {
						cb();
					});
			} else {
				cb();
			}
		}

		var doAsyncCall = function (asyncFieldName :String, cb :Err->Void) :Void {
			var onTestFinish = function(err) {tearDown(function() {cb(err);});};
			//Call this aftersetup
			var doTest = function () :Void {
				var finished = false;

				// var maxTime = 2000;
				// //Add the timer check, in case the test times out.
				// haxe.Timer.delay(function () {
				// 	if (!finished) {
				// 		finished = true;
				// 		onTestFinish("    " + className + "::" + asyncFieldName + " TIMEDOUT");
				// 	}
				// }, maxTime);

				//test function
				var asyncTestCallback = function (err :Err) :Void {
					if (!finished) {
						finished = true;
						if (err == null) {
							testResults.testsPassed++;
						} else {
							testResults.err = err;
						}
						Log.info("onTestFinish");
						onTestFinish(err);
					}
				}

				var asyncAssert = function(check :Bool, ?description :Dynamic) :Void {
					if(!check && !finished) {
						finished = true;
						onTestFinish(Type.getClassName(cls) + "." + asyncFieldName + ": " + description);
					}
				}

				//Now actually make the call
				try {
					Log.info(asyncFieldName);
					Reflect.callMethod(inst, Reflect.field(inst, asyncFieldName), [asyncTestCallback, function() {trace("Called back from async " + asyncFieldName);}]);
				} catch (e :Dynamic) {
					Log.error("    " + className + "::" + asyncFieldName + " Error: " + Std.string(e));
					if (!finished) {
						finished = true;
						onTestFinish(e);
					}
				}
			}
			setup(doTest);
		}
		AsyncLambda.iter(asyncTestQueue, doAsyncCall, onFinish);
	}
}

class TestResults
{
	public var cls :Class<Dynamic>;
	public var testsPassed :Int;
	public var testsFailed :Int;
	public var totalTests :Int;
	public var err :Dynamic;

	public function new (cls :Class<Dynamic>, totalTests :Int	)
	{
		this.cls = cls;
		this.totalTests = totalTests;
		testsFailed = testsPassed = 0;
	}

	public function toString () :String
	{
		if (err != null) {
			return "    FAIL: " + err;
		} else {
			return "    " + (testsPassed == totalTests ? "OK   " : "FAIL   ") +  Type.getClassName(cls) + "...passed " + testsPassed + " / " + totalTests;
		}
	}
}
