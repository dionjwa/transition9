/*******************************************************************************
 * Hydrax: haXe port of the PushButton Engine
 * Copyright (C) 2010 Dion Amago
 * For more information see http://github.com/dionjwa/Hydrax
 *
 * This file is licensed under the terms of the MIT license, which is included
 * in the License.html file at the root directory of this SDK.
 ******************************************************************************/
package transition9.macro;
#if macro
import haxe.macro.Expr;
import haxe.macro.Type;
import haxe.macro.Context;
#end

using Lambda;
using StringTools;

class Macros
{
	
	macro 
	public static function getDate() 
	{
		var date = Date.now().toString();
		var pos = haxe.macro.Context.currentPos();
		return { expr : EConst(CString(date)), pos : pos };
	}
	
	/**
	  * Returns the name of the field variable instance.
	  *
	  * E.g. public static var Foo :String = Macros.getFieldName();
	  * Foo == "Foo"
	  * 
	  * Careful: the Macros.getFieldName() MUST be on the same 
	  * line as the var declaration!
	  */
	macro 
	public static function getFieldName() {
		var pos = haxe.macro.Context.currentPos();
		
		var posRegex : EReg = ~/^[ \t]*#pos\(([_0-9a-zA-Z\/\.]+\.hx):([0-9]+).*/;
		posRegex.match("" + pos);
		var fileName = posRegex.matched(1);
		var line = Std.parseInt(posRegex.matched(2)) - 1;
		
		var varNameRegex : EReg = ~/^[ \t]*((public|static|private)[ \t]+)*var[ \t]+([_a-zA-Z]+[_a-zA-Z0-9]*)[ \t:]+.*+/;

		var str = sys.io.File.getContent(fileName).split("\n")[line];
		varNameRegex.match(str);
		var varName = varNameRegex.matched(3);
		return { expr :EConst(CString(varName)), pos : pos };
	}
	
	#if (debug && macro)
	@macro
	public static function warn (msg :String) :Void
	{
		haxe.macro.Context.warning(msg, haxe.macro.Context.currentPos());
	}
	#end
}
