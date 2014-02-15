package transition9.util;

/**
  * Some logging systems are specific for client code (e.g. Flambe) which is problematic for 
  * shared client/server code.  This class allows switching between loggers without
  * having to rewrite logging/assert calls.
  */

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
	inline public static function debug (message :String, ?fields :Array<Dynamic>) :Void
	{
		info(message, fields);
	}

	/**
	  * Wrap the flambe assert in the Log class to avoid refactoring when using other libs.
	  */
	inline public static function assert (condition :Bool, ?message :String, ?fields :Array<Dynamic>) :Void
	{
		flambe.util.Assert.that(condition, message, fields);
	}
}
#elseif (mconsole && !no_console) //This is a pretty good logger in webkit
class Log
{
	inline public static function debug (message :Dynamic, ?fields: Dynamic, ?pos :haxe.PosInfos) :Void
	{
		if (fields != null) {
			Console.debug([message, fields], pos);
		} else {
			Console.debug(message, pos);
		}
	}

	inline public static function info (message :Dynamic, ?fields: Dynamic, ?pos :haxe.PosInfos) :Void
	{
		if (fields != null) {
			Console.info([message, fields], pos);
		} else {
			Console.info(message, pos);
		}
	}

	inline public static function warn (message :Dynamic, ?fields: Dynamic, ?pos :haxe.PosInfos) :Void
	{
		if (fields != null) {
			Console.warn([message, fields], pos);
		} else {
			Console.warn(message, pos);
		}
	}

	inline public static function error (message :Dynamic, ?fields: Dynamic, ?pos :haxe.PosInfos) :Void
	{
		if (fields != null) {
			Console.error([message, fields], pos);
		} else {
			Console.error(message, pos);
		}
	}

	inline public static function assert (condition :Bool, ?message :String, ?fields :Dynamic, ?pos :haxe.PosInfos) :Void
	{
		if (fields != null) {
			Console.assert(condition, [message, fields], pos);
		} else {
			Console.assert(condition, message, pos);
		}
	}
}
#elseif !disable_logging
class Log
{
	inline public static function debug (?message :Dynamic, ?fields :Array<Dynamic>, ?pos :haxe.PosInfos) :Void
	{
		haxe.Log.trace(message + (fields != null ? " [" + fields.join(", ") + "]" : ""), pos);
	}

	inline public static function info (?message :Dynamic, ?fields :Array<Dynamic>, ?pos :haxe.PosInfos) :Void
	{
		haxe.Log.trace(message + (fields != null ? " [" + fields.join(", ") + "]" : ""), pos);
	}

	inline public static function warn (?message :Dynamic, ?fields :Array<Dynamic>, ?pos :haxe.PosInfos) :Void
	{
		haxe.Log.trace(message + (fields != null ? " [" + fields.join(", ") + "]" : ""), pos);
	}

	inline public static function error (?message :Dynamic, ?fields :Array<Dynamic>, ?pos :haxe.PosInfos) :Void
	{
		haxe.Log.trace(message + (fields != null ? " [" + fields.join(", ") + "]" : ""), pos);
	}

	inline public static function assert (condition :Bool, ?message :String, ?fields :Array<Dynamic>, ?pos :haxe.PosInfos) :Void
	{
		if (!condition) {
			haxe.Log.trace(message + (fields != null ? " [" + fields.join(", ") + "]" : ""), pos);
			throw message;
		}
	}

}
#else //Remove logging
class Log
{
	inline public static function debug (?message :Dynamic, ?fields :Array<Dynamic>) :Void {}
	inline public static function info (?message :Dynamic, ?fields :Array<Dynamic>) :Void {}
	inline public static function warn (?message :Dynamic, ?fields :Array<Dynamic>) :Void {}
	inline public static function error (?message :Dynamic, ?fields :Array<Dynamic>) :Void {}
	inline public static function assert (condition :Bool, ?message :String, ?fields :Array<Dynamic>) :Void {}
}
#end
