package transition9.util;

/**
  * Some logging systems are specific for client code (e.g. Flambe) which is problematic for 
  * shared client/server code.  This class allows switching between loggers without
  * having to rewrite logging/assert calls.
  */

#if cocos2dx
import cc.Cocos2dx;
#end

#if (flambe && !disable_flambe_logging)
/**
 * Flambe's internal logger. Games should use their own by calling System.logger() or extending
 * PackageLog.
 */
class Log extends flambe.util.PackageLog
{
	/**
	  * Additional logging method not in flambe.util.PackageLog
	  */
	inline public static function debug (message :String, ?extra :Dynamic) :Void
	{
		info(message, extra);
	}

	//Webkit extra calls
	inline public static function count (id :String) :Void {}
	inline public static function enterDebugger () :Void {}
	inline public static function group (groupId :String) :Void {}
	inline public static function groupEnd () :Void {}
	inline public static function time (id) :Void {}
	inline public static function timeEnd (id) :Void {}
	inline public static function profile (id) :Void {}
	inline public static function profileEnd (id) :Void {}
}
#elseif (mconsole && !no_console) //This is a pretty good logger in webkit
class Log
{
	private static function __init__() : Void untyped
    {
    	trace("Console.start");
        Console.start();
    }

    inline public static function count (id :String) :Void
	{
		Console.count(id);
	}

	inline public static function enterDebugger () :Void
	{
		Console.enterDebugger();
	}

	inline public static function group (groupId :String) :Void
	{
		Console.group(groupId);
	}

	inline public static function groupEnd () :Void
	{
		Console.groupEnd();
	}

	inline public static function time (id) :Void
	{
		Console.time(id);
	}

	inline public static function timeEnd (id) :Void
	{
		Console.timeEnd(id);
	}

	inline public static function profile (id) :Void
	{
		Console.profile(id);
	}

	inline public static function profileEnd (id) :Void
	{
		Console.profileEnd(id);
	}

	inline public static function debug (message :Dynamic, ?extra: Dynamic, ?pos :haxe.PosInfos) :Void
	{
		if (extra != null) {
			Console.debug([message, extra], pos);
		} else {
			Console.debug(message, pos);
		}
	}

	inline public static function info (message :Dynamic, ?extra: Dynamic, ?pos :haxe.PosInfos) :Void
	{
		if (extra != null) {
			Console.info([message, extra], pos);
		} else {
			Console.info(message, pos);
		}
	}

	inline public static function warn (message :Dynamic, ?extra: Dynamic, ?pos :haxe.PosInfos) :Void
	{
		if (extra != null) {
			Console.warn([message, extra], pos);
		} else {
			Console.warn(message, pos);
		}
	}

	inline public static function error (message :Dynamic, ?extra: Dynamic, ?pos :haxe.PosInfos) :Void
	{
		if (extra != null) {
			Console.error([message, extra], pos);
		} else {
			Console.error(message, pos);
		}
	}
}
#elseif cocos2dx
class Log
{
	inline public static var NO_FORWARD :String = "SCRIPT: ";
	inline public static function debug (?message :Dynamic, ?extra :Dynamic, ?pos :haxe.PosInfos) :Void
	{
		CC.log(NO_FORWARD + message + (extra != null ? " [" + extra.join(", ") + "]" : ""));
	}

	inline public static function info (?message :Dynamic, ?extra :Dynamic, ?pos :haxe.PosInfos) :Void
	{
		CC.log(NO_FORWARD + message + (extra != null ? " [" + extra.join(", ") + "]" : ""));
	}

	inline public static function warn (?message :Dynamic, ?extra :Dynamic, ?pos :haxe.PosInfos) :Void
	{
		CC.log(NO_FORWARD + message + (extra != null ? " [" + extra.join(", ") + "]" : ""));
	}

	inline public static function error (?message :Dynamic, ?extra :Dynamic, ?pos :haxe.PosInfos) :Void
	{
		CC.log(NO_FORWARD + message + (extra != null ? " [" + extra.join(", ") + "]" : ""));
	}

	//Webkit extra calls
	inline public static function count (id :String) :Void {}
	inline public static function enterDebugger () :Void {}
	inline public static function group (groupId :String) :Void {}
	inline public static function groupEnd () :Void {}
	inline public static function time (id) :Void {}
	inline public static function timeEnd (id) :Void {}
	inline public static function profile (id) :Void {}
	inline public static function profileEnd (id) :Void {}

}
#elseif !disable_logging
class Log
{
	inline public static function debug (?message :Dynamic, ?extra :Dynamic, ?pos :haxe.PosInfos) :Void
	{
		haxe.Log.trace(message + (extra != null ? " [" + extra.join(", ") + "]" : ""), pos);
	}

	inline public static function info (?message :Dynamic, ?extra :Dynamic, ?pos :haxe.PosInfos) :Void
	{
		haxe.Log.trace(message + (extra != null ? " [" + extra.join(", ") + "]" : ""), pos);
	}

	inline public static function warn (?message :Dynamic, ?extra :Dynamic, ?pos :haxe.PosInfos) :Void
	{
		haxe.Log.trace(message + (extra != null ? " [" + extra.join(", ") + "]" : ""), pos);
	}

	inline public static function error (?message :Dynamic, ?extra :Dynamic, ?pos :haxe.PosInfos) :Void
	{
		haxe.Log.trace(message + (extra != null ? " [" + extra.join(", ") + "]" : ""), pos);
	}

	//Webkit extra calls
	inline public static function count (id :String) :Void {}
	inline public static function enterDebugger () :Void {}
	inline public static function group (groupId :String) :Void {}
	inline public static function groupEnd () :Void {}
	inline public static function time (id) :Void {}
	inline public static function timeEnd (id) :Void {}
	inline public static function profile (id) :Void {}
	inline public static function profileEnd (id) :Void {}
}
#else //Remove logging
class Log
{
	inline public static function debug (?message :Dynamic, ?extra :Dynamic) :Void {}
	inline public static function info (?message :Dynamic, ?extra :Dynamic) :Void {}
	inline public static function warn (?message :Dynamic, ?extra :Dynamic) :Void {}
	inline public static function error (?message :Dynamic, ?extra :Dynamic) :Void {}
	inline public static function assert (condition :Bool, ?message :String, ?extra :Dynamic) :Void {}

	//Webkit extra calls
	inline public static function count (id :String) :Void {}
	inline public static function enterDebugger () :Void {}
	inline public static function group (groupId :String) :Void {}
	inline public static function groupEnd () :Void {}
	inline public static function time (id) :Void {}
	inline public static function timeEnd (id) :Void {}
	inline public static function profile (id) :Void {}
	inline public static function profileEnd (id) :Void {}
}
#end
