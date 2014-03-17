package transition9.macro;

import haxe.macro.Expr;
import haxe.macro.Context;

//Useful constants that are a pain to declare
class MacroConstants
{
	public static var TYPE_BOOL = TPath({ sub:null, name:"Bool", pack:[], params:[] });
	public static var TYPE_INT = TPath({ sub:null, name:"Int", pack:[], params:[] });
	public static var TYPE_FLOAT = TPath({ sub:null, name:"Float", pack:[], params:[] });
	public static var TYPE_STRING= TPath({ sub:null, name:"String", pack:[], params:[] });
}