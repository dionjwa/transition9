package transition9.util;

import haxe.macro.Expr;
import haxe.macro.Context;
import haxe.macro.Type;

class MacroUtil
{
	/**
     * Inserts an expression into the function block.  
     */
	public static function insertExpressionIntoFunction(exprToAdd :Expr, func :Function, ?beginningOfFunction :Bool = true) :Void
	{
		if (func.expr != null) {
			switch(func.expr.expr) {
				case EBlock(exprs): //exprs : Array<Expr>
					if (exprToAdd != null) {
						if (beginningOfFunction) {
							exprs.unshift(exprToAdd);
						} else {
							exprs.push(exprToAdd);
						}
					}
				default:
			}
		}
	}
	
	//Searches superclass as well
	public static function classContainsField(cls :ClassType, fieldName :String) :Bool
	{
		if (cls == null) {
			return false;
		}
		
		if (cls.fields != null) {
			for (field in cls.fields.get()) {
				if (field.name == fieldName) {
					return true;
				}
			}
		}
		
		return classContainsField(cls.superClass != null ? cls.superClass.t.get() : null, fieldName);
	}
}
