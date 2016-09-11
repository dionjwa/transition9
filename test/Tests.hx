package ;

class Tests
{
	public static function main () :Void
	{

#if mconsole
		Console.start();
#end
#if nodejs
		haxe.unit.TestRunner.print = function(v :Dynamic) :Void { untyped __js__("console.log(v)");};
#end
		var r = new haxe.unit.TestRunner();
		r.add(new macros.TestMacros());
		r.add(new platform.TestDispatcher());
		r.run();

	}
}
