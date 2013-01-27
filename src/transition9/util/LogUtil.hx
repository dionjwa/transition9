package transition9.util;

class LogUtil
{
	inline public static function getStackTrace () :String
	{
		#if haxe3
			return haxe.CallStack.toString(haxe.CallStack.callStack());
		#else
			return haxe.Stack.toString(haxe.Stack.callStack());
		#end
	}

}
