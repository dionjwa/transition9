package transition9.util;

class Assert
{
#if (debug || t9_keep_asserts)
	public static function that(condition :Bool, ?message :String, ?extra :Dynamic, ?pos :haxe.PosInfos):Void
	{
	    if(!condition) {
	    	fail(message, extra, pos);
	    }
	}
	public static function fail(message :String, ?extra :Dynamic, ?pos :haxe.PosInfos)
	{
        var error = "Assertion failed!";
        if (message != null) {
            error += " " + message;
        }
#if flambe
        Log.error(error, extra);
#else
		Log.error(error, extra, pos);
#end
        throw error;
	}
#else
	inline public static function that(condition :Bool, message :Dynamic, ?extra :Dynamic) {}
	inline public static function fail(message :String, ?extra :Dynamic) {}
#end
}