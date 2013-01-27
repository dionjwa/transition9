package ;

class Tests
{
	public static function main () :Void
	{
		transition9.unit.AsyncTestTools.runTestsOn(cast [
			async.StepTest,
		]);
	}
}
