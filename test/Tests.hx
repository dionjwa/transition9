package ;

class Tests
{
	public static function main () :Void
	{

		// new async.Continuation();

#if mconsole
		Console.start();
#end
#if nodejs
		haxe.unit.TestRunner.print = function(v :Dynamic) :Void { untyped __js__("console.log(v)");};
#end
		var r = new haxe.unit.TestRunner();
		r.add(new macros.TestMacros());
		r.add(new platform.TestDispatcher());
		// your can add others TestCase here
		// finally, run the tests
		r.run();

		trace("async tests:");
#if (nodejs && !travis)
		try {
			untyped __js__("if (require.resolve('source-map-support')) {require('source-map-support').install();}");
		} catch (e :Dynamic) {}
#end
		transition9.unit.AsyncTestTools.runTestsOn(cast [
			async.StepTest,
		]);

	}
}
