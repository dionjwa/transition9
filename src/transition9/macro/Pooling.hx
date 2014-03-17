package transition9.macro;

 @:autoBuild(transition9.macro.ClassMacros.addObjectPooling("dispose"))
interface Pooling
{
	//Use <Class>.fromPool(); to get an object from the object pool.

	//Returns the object back to the object pool
	function dispose() :Void;
}