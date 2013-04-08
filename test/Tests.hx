package ;

class Tests
{
	public static function main () :Void
	{
		#if (nodejs_std || nodejs)
		untyped __js__("if (require.resolve('source-map-support')) {require('source-map-support').install();}");
		#end
		Console.start();
		transition9.unit.AsyncTestTools.runTestsOn(cast [
			async.StepTest,
		]);
		
	}
}
