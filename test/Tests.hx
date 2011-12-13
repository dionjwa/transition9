package ;

class Tests
{
	public static function main () :Void
	{
		// try {
		// 	// haxe.Timer.delay(function () {
		// 		throw "Some error";
		// 	// }, 100);
		// } catch (e :Dynamic) {
		// 	trace('caught e=' + e);
		// }
		
		
		org.transition9.unit.AsyncTestTools.runTestsOn(cast [
			async.AsyncTest,
		]);
	}
}
