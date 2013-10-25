package transition9.macro;

import haxe.macro.Expr;
import haxe.macro.Context;
import haxe.macro.Type;

class ClassMacros
{
	/**
	 * Adds object pooling to the static class.
	 */
	public static function addObjectPooling () :Array<Field>
	{
		var pos = Context.currentPos();
		var fields = Context.getBuildFields();
		var clsType = Context.getLocalClass().get();
		var cls = ComplexType.TPath({name:clsType.name, pack:clsType.pack, params:[]});
		var className = clsType.pack.join(".") + "." + clsType.name;

		//Find the dispose method, or if none found create one.
		var disposeField :Field = null;
		for (f in fields) {
			if (f.name == "dispose") {
				disposeField = f;
				break;
			}
		}

		if (disposeField == null) {
			// Context.warning("building new disposeField", pos);
			disposeField = MacroUtil.buildFields(macro {
				function public__dispose () :Void {
#if debug
					disposed = true;
#end
					if (POOL_LIMIT <= 0 || POOL.length < POOL_LIMIT) {
						POOL.push(this);
					}
				}
			})[0];
			fields.push(disposeField);
		} else {
			//Add the expression to remove all _disposables on removal to the onRemoved function
			switch(disposeField.kind) {
				case FFun(f):
					//Dispose of the _disposables on component removal
#if debug
					var expr = Context.parseInlineString("{disposed = true; if (POOL_LIMIT <= 0 || POOL.length < POOL_LIMIT) { POOL.push(this); }}", pos);
#else
					var expr = Context.parseInlineString("{if (POOL_LIMIT <= 0 || POOL.length < POOL_LIMIT) { POOL.push(this); }}", pos);
#end
					transition9.macro.MacroUtil.insertExpressionIntoFunction(expr, f);
				default: //Ignored
			}
		}

		fields = fields.concat(MacroUtil.buildFields(macro {

			var public__static__POOL :Array<$cls> = [];
			var public__static__POOL_LIMIT :Int = -1; //-1 == no limit

#if debug
			var private__disposed :Bool = true;
			function inline__public__isDisposed() :Bool
			{
				return disposed;
			}
#end

		}));

		var block = Context.parse(
			"{function public__static__get() :" + clsType.name
			+"{   if (POOL.length > 0) {"
			+"		var element = POOL.pop();"
#if debug
			+"		element.disposed = false;"
#end
			+"		return element;"
			+"	} else {"
			+"		return new " + clsType.name + "();"
			+"	}"
			+"}}", Context.currentPos());

		fields = fields.concat(MacroUtil.buildFields(block));

		return fields;
	}

	/**
	 * Adds linked list behavior to the class
	 */
	macro public static function addLinkedListBehaviour () :Array<Field>
	{
		var pos = Context.currentPos();

		var fields = Context.getBuildFields();
		var clsType = Context.getLocalClass().get();
		var cls = ComplexType.TPath({name:clsType.name, pack:clsType.pack, params:[]});

		fields = fields.concat(MacroUtil.buildFields(macro {

			var public__before :$cls;
			var public__after :$cls;

			function public__addAfter(other :$cls) :Void
			{
				after = other.after;
		        before = other;
		        before.after = this;
		        if (after != null) {
		        	after.before = this;
		        }
			}

			function public__addBefore (other :$cls) :Void
		    {
		        after = other;
		        before = other.before;
		        if (before != null) {
		        	before.after = this;
		        }
		        after.before = this;
		    }

		    function public__remove () :Void
		    {
		        before.after = after;
		        after.before = before;
		    }

		}));

		return fields;
	}
}