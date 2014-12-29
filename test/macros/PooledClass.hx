package macros;

@:build(t9.macro.ClassMacros.addObjectPooling("dispose"))
class PooledClass
{
	public static var NEW_COUNT :Int = 0;
	public function new()
	{
		NEW_COUNT++;
	}

	public function dispose()
	{
		// POOL.put(this);
	}
}