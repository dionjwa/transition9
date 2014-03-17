package macros;

@:build(transition9.macro.ClassMacros.addObjectPooling("dispose"))
class PooledClassExtended extends PooledClass
{
	public function new()
	{
		super();
	}
}