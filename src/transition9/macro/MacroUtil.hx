package transition9.macro;

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
		if (Context.defined("display")) {
			// When running in code completion, skip out early
			return;
		}

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


	//Searches superclass as well
	public static function getAllClassFields(cls :ClassType) :Array<ClassField>
	{
		if (cls == null) {
			return null;
		}

		var fields = [];
		if (cls.fields.get() != null) {
			for (field in cls.fields.get()) {
				fields.push(field);
			}
		}

		if (cls.superClass == null) {
			return fields;
		} else {
			var superFields = getAllClassFields(cls.superClass.t.get());
			if (superFields == null) {
				return fields;
			} else {
				return fields.concat(superFields);
			}
		}
	}

	/**
     * Creates a list of fields from a block expression.
     * From flambe.uti.Macros, here to avoid a package dependency for just one block of code.
     * https://github.com/aduros/flambe/blob/master/LICENSE.txt
     */
    public static function buildFields (block :Expr) :Array<Field>
    {
        var fields :Array<Field> = [];
        switch (block.expr) {
            case EBlock(exprs):
                for (expr in exprs) {
                    switch (expr.expr) {
                        case EVars(vars):
                            for (v in vars) {
                                fields.push({
                                    name: getFieldName(v.name),
                                    doc: null,
                                    access: getAccess(v.name),
                                    kind: FVar(v.type, v.expr),
                                    pos: Context.currentPos(), //v.expr.pos,
                                    meta: []
                                });
                            }
                        case EFunction(name, f):
                            fields.push({
                                name: getFieldName(name),
                                doc: null,
                                access: getAccess(name),
                                kind: FFun(f),
                                pos: f.expr.pos,
                                meta: []
                            });
                        default:
                    }
                }
            default:
        }
        return fields;
    }

    /**
     * From flambe.uti.Macros, here to avoid a package dependency for just one block of code.
     * https://github.com/aduros/flambe/blob/master/LICENSE.txt
     */
    private static function getAccess (name :String) :Array<Access>
    {
        var result = [];
        for (token in name.split("__")) {
            var access = switch (token) {
                case "public": APublic;
                case "private": APrivate;
                case "static": AStatic;
                case "override": AOverride;
                case "dynamic": ADynamic;
                case "inline": AInline;
                default: null;
            }
            if (access != null) {
                result.push(access);
            }
        }
        return result;
    }

    /**
     * From flambe.uti.Macros, here to avoid a package dependency for just one block of code.
     * https://github.com/aduros/flambe/blob/master/LICENSE.txt
     */
    private static function getFieldName (name :String) :String
    {
        var idx = name.lastIndexOf("__");
        return (idx < 0) ? name : name.substr(idx + 2);
    }
}
