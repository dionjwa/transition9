package transition9.macro;

import haxe.macro.Expr;
import haxe.macro.Context;
import haxe.macro.Type;

using Lambda;

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
	public static function addObjectPooling (?disposeFunctionName :String) :Array<Field>
	{
		var pos = Context.currentPos();
		var fields = Context.getBuildFields();
		var clsType = Context.getLocalClass().get();
		var cls = ComplexType.TPath({name:clsType.name, pack:clsType.pack, params:[]});
		var className = clsType.pack.join(".") + "." + clsType.name;

		var varNext = "_next_" + clsType.name + "Pool";

		if (disposeFunctionName != null) {
			//Find the dispose method, or if none found create one.
			var disposeField :Field = null;
			for (f in fields) {
				if (f.name == disposeFunctionName) {
					disposeField = f;
					break;
				}
			}

			if (disposeField == null) {
				var isOverridingFunction = MacroUtil.classContainsField(clsType, disposeFunctionName);
				var funcExpr = Context.parse("{POOL.put(this);}", pos);
				var access = isOverridingFunction ? [APublic, AOverride] : [APublic];
				var functionExpression = {ret:null, params:[], args:[], expr:funcExpr};
				fields.push({ name : disposeFunctionName, doc : null, meta : [], access : access, kind :FieldType.FFun(functionExpression), pos : pos });
			} else {
				//Add the expression to remove all _disposables on removal to the onRemoved function
				switch(disposeField.kind) {
					case FFun(f):
						//Dispose of the _disposables on component removal
						var expr = Context.parseInlineString("{POOL.put(this);}", pos);
						transition9.macro.MacroUtil.insertExpressionIntoFunction(expr, f);
					default: //Ignored
				}
			}
		}

		//Build the fields for the class that manages the pool
		var poolingClassName = clsType.name + "Pool";
		var poolingClassFields = [];

		poolingClassFields.push({ name : "MAX_SIZE", doc : null, meta : [], access : [APublic], kind : FieldType.FVar(MacroConstants.TYPE_INT, macro -1), pos : pos });
		poolingClassFields.push({ name : "INTERNAL_POOLING_HEAD", doc : null, meta : [], access : [APublic], kind : FieldType.FVar(cls, null), pos : pos });
		poolingClassFields.push({ name : "POOL_SIZE", doc : null, meta : [], access : [APublic], kind : FieldType.FVar(MacroConstants.TYPE_INT, macro 0), pos : pos });
		// var isPoolingSubclass = MacroUtil.classContainsField(clsType, "internalIsInPool");
		var block = Context.parse(
			"{"
			+"	function public__new() {}"
			+"	function public__get() :" + clsType.name
			+"	{"
			+"		var obj = if (INTERNAL_POOLING_HEAD == null) {"
			+"			new " + clsType.name + "();"
			+"		} else {"
			+"			POOL_SIZE--;"
			+"			var next = INTERNAL_POOLING_HEAD;"
			+"			var afterNext = INTERNAL_POOLING_HEAD." + varNext + ";"
			+"			INTERNAL_POOLING_HEAD = afterNext;"
			+"			next;"
			+"		};"
			+"		return obj;"
			+"	}"
			+"	function public__put(obj :" + clsType.name + ")"
			+"	{"
#if debug
			+"		var current = INTERNAL_POOLING_HEAD;"
			+"		while (current != null) {"
			+"			if (current == obj) throw \"Object already exists in pool!\";"
			+"			current = current." + varNext + ";"
			+"		}"
#end
			+"		if(MAX_SIZE > 0 && POOL_SIZE >= MAX_SIZE) {return;}"
			+"		obj." + varNext + " = INTERNAL_POOLING_HEAD;"
			+"		INTERNAL_POOLING_HEAD = obj;"
			+"		POOL_SIZE++;"
			+"	}"
			+"	function public__isInPool(obj :" + clsType.name + ")"
			+"	{"
			+"		var current = INTERNAL_POOLING_HEAD;"
			+"		while(current != null) {"
			+"			if (current == obj) return true;"
			+"			current = current." + varNext + ";"
			+"		}"
			+"		return false;"
			+"	}"
			+"}", Context.currentPos());
	    poolingClassFields = poolingClassFields.concat(MacroUtil.buildFields(block));

	    var type :TypeDefinition = {
			pos:pos,
			params:[],
			pack:clsType.pack,
			name: poolingClassName,
			meta:[],
			kind:haxe.macro.TypeDefKind.TDClass(),
			isExtern:false,
			fields:poolingClassFields
		}
		Context.defineType(type);

		fields.push({ name : varNext, doc : null, meta : [], access : [APublic], kind : FieldType.FVar(cls, null), pos : pos });

		fields = fields.concat(MacroUtil.buildFields(Context.parse(
			"{"
			+"	var public__static__POOL :" + poolingClassName + " = new " + poolingClassName + "();"
			+"	function public__inline__static__fromPool()"
			+"	{"
			+"		return POOL.get();"
			+"	}"
			+"}", Context.currentPos())));

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