package macros;

@:build(transition9.macro.ClassMacros.addObjectPooling())
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