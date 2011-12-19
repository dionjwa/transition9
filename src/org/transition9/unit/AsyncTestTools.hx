package org.transition9.unit;

import Type;

import org.transition9.async.AsyncLambda;

import org.transition9.rtti.MetaUtil;

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
	
	public static function runTestsOn (testClasses :Array<Class<Dynamic>>) :Void
	{
		#if js
		haxe.Firebug.redirectTraces();
		#end
		
		var allresults = [];
		AsyncLambda.iter(testClasses, function (cls :Class<Dynamic>, elementDone :Void->Void) :Void {
			AsyncTestTools.doTests(cls, function (results :TestResults) {
				allresults.push(results);
				elementDone();
			});	
		}, function (err) {
			
			var allok = true;
			for (result in allresults) {
				if (result.testsPassed != result.totalTests) {
					allok = false;
					break;
				}
			}
			
			print(!allok ? "TESTS FAILED" : "Tests Completed OK");
			
			for (result in allresults) {
				print("    " + (result.testsPassed == result.totalTests ? "OK   " : "FAIL   ") +  Type.getClassName(result.cls) + "...passed " + result.testsPassed + " / " + result.totalTests);
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
		
		var testResults = new TestResults(cls, totalTests);
		
		//This is called when all tests have finished or timed out
		var onFinish = function (err) :Void {
			testsComplete(testResults);
		}
		
		//Do the sync tests
		for (syncTestName in syncTestQueue) {
			try {
				Reflect.callMethod(inst, Reflect.field(inst, syncTestName), []);
				testResults.testsPassed++;
			} catch (e :Dynamic) {
				print("    " + className + "::" + syncTestName + " Error: " + Std.string(e) + "\n" + haxe.Stack.toString(haxe.Stack.exceptionStack()));
			}
		}
		
		
		//Async setup and tear down
		var setup = function (cb :Void->Void) :Void {
			if (Reflect.field(inst, "setup") != null) {
				Reflect.callMethod(inst, Reflect.field(inst, "setup"), [cb]);
			} else {
				cb();
			}
		}
		
		var tearDown = function (cb :Void->Void) :Void {
			if (Reflect.field(inst, "tearDown") != null) {
				Reflect.callMethod(inst, Reflect.field(inst, "tearDown"), [cb]);
			} else {
				cb();
			}
		}
		
		var doAsyncCall = function (asyncFieldName :String, cb :Void->Void) :Void {
			
			var onTestFinish = callback(tearDown, cb);
			
			//Call this aftersetup 
			var doTest = function () :Void {
				
				var finished = false;
				var timedOut = false;
				
				var maxTime = 2000;
				
				//Add the timer check, in case the test times out.
				haxe.Timer.delay(function () {
					if (!finished) {
						timedOut = true;
						print("    " + className + "::" + asyncFieldName + " TIMEDOUT");
						onTestFinish();
					}
				}, maxTime);
				
				//test function
				var asyncTestCallback = function () :Void {
					if (!finished) {
						finished = true;
						testResults.testsPassed++;
						onTestFinish();
					}
				}
				
				//Now actually make the call
				try {
					Reflect.callMethod(inst, Reflect.field(inst, asyncFieldName), [asyncTestCallback]);
				} catch (e :Dynamic) {
					print("    " + className + "::" + asyncFieldName + " Error: " + Std.string(e));
					if (!finished) {
						finished = true;
						onTestFinish();
					}
				}
			}
			
			setup(doTest);
		}
		
		AsyncLambda.iter(asyncTestQueue, doAsyncCall, onFinish);
	}
	
	public static function print (s :String) :Void
	{
		#if (js && nodejs)
		Lib.print(s);
		#else
		trace(s);
		#end
	}
	
}

class TestResults
{
	public var cls :Class<Dynamic>;
	public var testsPassed :Int;
	public var testsFailed :Int;
	public var totalTests :Int;
	
	public function new (cls :Class<Dynamic>, totalTests :Int	)
	{
		this.cls = cls;
		this.totalTests = totalTests;
		testsFailed = testsPassed = 0;
	}

}
