package macros;

@:build(t9.macro.ClassMacros.addObjectPooling("dispose"))
class PooledClassWithExistingDispose
{
	public var isDisposeCalled :Bool;

	public function new()
	{
		isDisposeCalled = false;
	}

	public function dispose()
	{
		isDisposeCalled = true;
	}
}