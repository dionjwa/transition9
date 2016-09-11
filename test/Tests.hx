package ;

class Tests
{
	public static function main () :Void
	{
		var r = new haxe.unit.TestRunner();
		r.add(new macros.TestMacros());
		r.add(new platform.TestDispatcher());
		r.run();
	}
}
