package transition9.unit;

import Type;

import transition9.async.AsyncLambda;

import transition9.rtti.MetaUtil;

#if js
import js.Lib;
#elseif flash
import flash.Lib;
#end

using StringTools;


/**
  * Simple async testing.  Workds with Node.js
  */
class AsyncTestTools
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
		#if !(debug || flambe_keep_asserts)
		throw "You must run the tests with the -debug or -D flambe_keep_asserts for flambe.util.Assert";
		#end
		
		var allresults = [];
		AsyncLambda.iter(testClasses, function (cls :Class<Dynamic>, elementDone :Err->Void) :Void {
			// trace("doTests " + Type.getClassName(cls));
			AsyncTestTools.doTests(cls, function (results :TestResults) {
				allresults.push(results);
				elementDone(null);
			});	
		}, function (err) {
			
			var allok = true;
			for (result in allresults) {
				if (result.testsPassed != result.totalTests) {
					allok = false;
					break;
				}
			}
			
			trace(!allok ? "TESTS FAILED" : "Tests Completed OK");
			
			for (result in allresults) {
				// trace("    " + (result.testsPassed == result.totalTests ? "OK   " : "FAIL   ") +  Type.getClassName(result.cls) + "...passed " + result.testsPassed + " / " + result.totalTests);
				trace(result.toString());
			}
			
			#if nodejs
			untyped __js__('process.exit(0)');
			#end
		});
	}
	
	public static function doTests (cls :Class<Dynamic>, testsComplete :TestResults->Void) :Void
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
		// trace('syncTestQueue.length=' + syncTestQueue.length);
		// trace('asyncTestQueue.length=' + asyncTestQueue.length);
		
		var testResults = new TestResults(cls, totalTests);
		
		//This is called when all tests have finished or timed out
		var onFinish = function (err :Err) :Void {
			// trace("onFinish, err: " + err);
			if (testResults == null) return;
			testResults.err = err;
			testsComplete(testResults);
			testResults = null;
		}
		
		//Do the sync tests
		for (syncTestName in syncTestQueue) {
			try {
				// trace("Sync test: " + syncTestName);
				Reflect.callMethod(inst, Reflect.field(inst, syncTestName), []);
				testResults.testsPassed++;
			} catch (e :Dynamic) {
				// trace("    " + className + "::" + syncTestName + " Error: " + Std.string(e) + "\n" + haxe.Stack.toString(haxe.Stack.exceptionStack()));
				#if haxe3
					trace("    " + className + "::" + syncTestName + " Error: " + Std.string(e) + "\n" + haxe.CallStack.toString(haxe.CallStack.exceptionStack()));
				#else
					trace("    " + className + "::" + syncTestName + " Error: " + Std.string(e) + "\n" + haxe.Stack.toString(haxe.Stack.exceptionStack()));
				#end
			}
		}
		
		//Async setup and tear down
		var setup = function (cb :Void->Void) :Void {
			// trace("setup");
			if (Reflect.field(inst, "setup") != null) {
				// trace("class.setup");
				Reflect.callMethod(inst, Reflect.field(inst, "setup"), [cb]);
			} else {
				cb();
			}
		}
		
		var tearDown = function (err :Err, cb :Err->Void) :Void {
			if (Reflect.field(inst, "tearDown") != null) {
				// trace("tearDown");
				#if haxe3
					Reflect.callMethod(inst, Reflect.field(inst, "tearDown"), [cb.callback(err)]);
				#else
					Reflect.callMethod(inst, Reflect.field(inst, "tearDown"), [callback(cb, err)]);
				#end
			} else {
				cb(err);
			}
		}
		
		var doAsyncCall = function (asyncFieldName :String, cb :Err->Void) :Void {
			// trace("doAsyncCall " + asyncFieldName);
			#if haxe3
				// var onTestFinish = tearDown(cb);
				var onTestFinish = tearDown.callback(_, cb);
			#else
				var onTestFinish = function(err :Err) {tearDown(err, cb);};
			#end
			
			
			
			//Call this aftersetup 
			var doTest = function () :Void {
				// trace("doTest");
				var finished = false;
				// var timedOut = false;
				
				var maxTime = 2000;
				//Add the timer check, in case the test times out.
				haxe.Timer.delay(function () {
					if (!finished) {
						// timedOut = true;
						finished = true;
						// trace("    " + className + "::" + asyncFieldName + " TIMEDOUT");
						// tearDown("    " + className + "::" + asyncFieldName + " TIMEDOUT", cb);
						onTestFinish("    " + className + "::" + asyncFieldName + " TIMEDOUT");
						// onTestFinish();
					} 
					else  {trace('finished=' + finished);} 
				}, maxTime);
				
				//test function
				var asyncTestCallback = function (err :Err) :Void {
					if (!finished) {
						finished = true;
						if (err == null) {
							testResults.testsPassed++;
						} else {
							testResults.err = err;
						}
						onTestFinish(err);
					}
					// if (!finished && err == null) {
					// 	finished = true;
					// 	testResults.testsPassed++;
					// 	onTestFinish();
					// } else if (err != null) {
					// 	finished = true;
					// 	testResults.err = err;
					// }
				}
				
				var asyncAssert = function(check :Bool, ?description :Dynamic) :Void {
					if(!check && !finished) {
						finished = true;
						// trace("CallStack: " + haxe.CallStack.toString(haxe.CallStack.exceptionStack()));
						onTestFinish(Type.getClassName(cls) + "." + asyncFieldName + ": " + description);
					}
				}
				
				//Now actually make the call
				try {
					// trace("Async test: " + asyncFieldName);
					Reflect.callMethod(inst, Reflect.field(inst, asyncFieldName), [asyncTestCallback, asyncAssert]);
				} catch (e :Dynamic) {
					trace("    " + className + "::" + asyncFieldName + " Error: " + Std.string(e));
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
