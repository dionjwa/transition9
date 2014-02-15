package transition9.macro;

import haxe.macro.Expr;
import haxe.macro.Context;
import haxe.macro.Type;

class ClassMacros
{
	/**
	 * Adds object pooling to the static class.
	 * Get a pooled class with:
	 *      var obj = TheClass.get();
	 * And return the object to the pool with:
	 *      obj.dispose();
	 * If the class already has a dispose function,
	 * then the logic for returning to the pool will
	 * inserted into the existing function.
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

			var isOverridingFunction = MacroUtil.classContainsField(clsType, "dispose");
			if (isOverridingFunction) {
					disposeField = MacroUtil.buildFields(macro {
						function override__public__dispose () {
							super.dispose();
#if debug
							disposed = true;
#end
							if (POOL_LIMIT <= 0 || INTERNAL_POOL_SIZE < POOL_LIMIT) {
								this.returnToPool();
							}
						}
					})[0];
				} else {
					disposeField = MacroUtil.buildFields(macro {
						function public__dispose () {
#if debug
							disposed = true;
#end
							if (POOL_LIMIT <= 0 || INTERNAL_POOL_SIZE < POOL_LIMIT) {
								this.returnToPool();
							}
						}
					})[0];
				}
			fields.push(disposeField);
		} else {
			//Add the expression to remove all _disposables on removal to the onRemoved function
			switch(disposeField.kind) {
				case FFun(f):
					//Dispose of the _disposables on component removal
#if debug
					var expr = Context.parseInlineString("{disposed = true; if (POOL_LIMIT <= 0 || INTERNAL_POOL_SIZE < POOL_LIMIT) { this.returnToPool(); }}", pos);
#else
					var expr = Context.parseInlineString("{if (POOL_LIMIT <= 0 || INTERNAL_POOL_SIZE < POOL_LIMIT) { this.returnToPool(); }}", pos);
#end
					transition9.macro.MacroUtil.insertExpressionIntoFunction(expr, f);
				default: //Ignored
			}
		}

		fields = fields.concat(MacroUtil.buildFields(macro {

			var public__static__POOL_LIMIT :Int = -1; //-1 == no limit
			var public__static__INTERNAL_POOLING_HEAD :$cls;
			var public__static__INTERNAL_POOL_SIZE :Int = 0;
			var public__internalPoolingBefore :$cls;
			var public__internalPoolingAfter :$cls;
			var public__internalIsInPool :Bool;

			function private__static__internalGetFromPool()
			{
				var newHead = INTERNAL_POOLING_HEAD.internalPoolingAfter;
				var currentHead = INTERNAL_POOLING_HEAD;
				INTERNAL_POOLING_HEAD = newHead;
				currentHead.internalPoolingRemove();
				INTERNAL_POOL_SIZE--;
				return currentHead;
			}

			function public__returnToPool()
			{
				if (internalIsInPool) {
					Log.error("Already in pool");
				}
				if (INTERNAL_POOLING_HEAD == null) {
					INTERNAL_POOLING_HEAD = this;
				} else {
					var currentHead = INTERNAL_POOLING_HEAD;
					INTERNAL_POOLING_HEAD = this;
					currentHead.internalPoolingAddBefore(this);
				}
				INTERNAL_POOL_SIZE++;
				internalIsInPool = true;
			}

			function public__internalPoolingAddBefore (other :$cls)
		    {
		        internalPoolingAfter = other;
		        internalPoolingBefore = other.internalPoolingBefore;
		        if (internalPoolingBefore != null) {
		        	internalPoolingBefore.internalPoolingAfter = this;
		        }
		        internalPoolingAfter.internalPoolingBefore = this;
		    }

		    function public__internalPoolingRemove ()
		    {
		    	if (internalPoolingBefore != null) {
		        	internalPoolingBefore.internalPoolingAfter = internalPoolingAfter;
		        }
		        if (internalPoolingAfter != null) {
		        	internalPoolingAfter.internalPoolingBefore = internalPoolingBefore;
		        }
		    }

#if debug
			var private__disposed :Bool = true;
			function inline__public__isDisposed() :Bool
			{
				return disposed;
			}
#end

		}));

		var block = Context.parse(
			"{"
			+"	function public__static__get() :" + clsType.name
			+"	{"
			+"		var obj = if (INTERNAL_POOLING_HEAD == null) {"
			+"			new " + clsType.name + "();"
			+"		} else {"
			+"			internalGetFromPool();"
			+"		};"
			+"		obj.internalIsInPool = false;"
			+"		return obj;"
			+"	}"
			+"}", Context.currentPos());

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

			function public__addAfter(other :$cls)
			{
				after = other.after;
		        before = other;
		        before.after = this;
		        if (after != null) {
		        	after.before = this;
		        }
			}

			function public__addBefore (other :$cls)
		    {
		        after = other;
		        before = other.before;
		        if (before != null) {
		        	before.after = this;
		        }
		        after.before = this;
		    }

		    function public__remove ()
		    {
		        before.after = after;
		        after.before = before;
		    }

		}));

		return fields;
	}

	/**
	 * Adds the singleton pattern to the class.
	 */
	public static function addSingletonPattern () :Array<Field>
	{
		var pos = Context.currentPos();
		var fields = Context.getBuildFields();
		var clsType = Context.getLocalClass().get();
		var cls = ComplexType.TPath({name:clsType.name, pack:clsType.pack, params:[]});
		var className = clsType.pack.join(".") + "." + clsType.name;

		var newExpr = Context.parse("i_ = new " + className + "()", pos);

		fields = fields.concat(MacroUtil.buildFields(macro {
			var private__static__i_ :$cls;
			function public__static__get_i()
			{
				if (i_ == null) {
					i_ = $newExpr;
				}
				return i_;
			}
		}));
		fields.push({ name : "i", doc : null, meta : [], access : [APublic, AStatic], kind : FieldType.FProp("get","never",cls, null), pos : pos });
		return fields;
	}
}