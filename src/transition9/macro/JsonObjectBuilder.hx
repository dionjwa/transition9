package transition9.macro;

import sys.io.File;
import haxe.io.StringInput;
import haxe.macro.Expr;
import haxe.macro.Context;

using StringTools;

class JsonObjectBuilder
{
	static var TYPE_BOOL = TPath({ sub:null, name:"Bool", pack:[], params:[] });
	static var TYPE_INT = TPath({ sub:null, name:"Int", pack:[], params:[] });
	static var TYPE_FLOAT = TPath({ sub:null, name:"Float", pack:[], params:[] });
	static var TYPE_STRING= TPath({ sub:null, name:"String", pack:[], params:[] });

	macro
	static public function buildObjectFromJsonFile(filePath :String) :Expr
	{
		var pos = Context.currentPos();
		var jsonFileContents = File.getContent(filePath);
		var json = haxe.Json.parse(jsonFileContents);
		// trace(json);

		var filePathTokens = filePath.split("/");
		var typeName = filePathTokens[filePathTokens.length - 1].split(".")[0] + "Json";

		// trace("getClassPath() : " + Context.getClassPath());
		// trace("Type.typeof(json):" + Type.typeof(json));
		var fields :Array<Field> = [];
		switch(Type.typeof(json)) {
			case TClass(c):
				// trace("Type.getClassName(c):" + Type.getClassName(c));
				if (Type.getClassName(c) == "Array") {
					var arr :Array<Dynamic> = json;
					for (element in arr) {
						switch(Type.typeof(element)) {
							case TClass(c):
								if (Type.getClassName(c) == "String") {
									fields.push({
										pos:pos,
										name:element,
										meta:null,
										kind:haxe.macro.FieldType.FVar(TYPE_STRING, Context.makeExpr(element, pos)),
										doc:null,
										access:[haxe.macro.Access.APublic, haxe.macro.Access.AStatic]
									});
								}
							case TInt:
								fields.push({
									pos:pos,
									name:element,
									meta:null,
									kind:haxe.macro.FieldType.FVar(TYPE_INT, macro element),
									doc:null,
									access:[haxe.macro.Access.APublic, haxe.macro.Access.AStatic]
								});
							default: trace("ignored");
						}
					}
				}
			case TObject:
				for (fieldName in Reflect.fields(json)) {
					var element = Reflect.field(json, fieldName);
					switch(Type.typeof(element)) {
						case TClass(c):
							if (Type.getClassName(c) == "String") {
								fields.push({
									pos:pos,
									name:fieldName,
									meta:null,
									kind:haxe.macro.FieldType.FVar(TYPE_STRING, Context.makeExpr(element, pos)),
									doc:null,
									access:[haxe.macro.Access.APublic, haxe.macro.Access.AStatic]
								});
							}
						case TInt:
							fields.push({
								pos:pos,
								name:fieldName,
								meta:null,
								kind:haxe.macro.FieldType.FVar(TYPE_INT, Context.makeExpr(element, pos)),
								doc:null,
								access:[haxe.macro.Access.APublic, haxe.macro.Access.AStatic]
							});
						case TFloat:
							fields.push({
								pos:pos,
								name:fieldName,
								meta:null,
								kind:haxe.macro.FieldType.FVar(TYPE_FLOAT, Context.makeExpr(element, pos)),
								doc:null,
								access:[haxe.macro.Access.APublic, haxe.macro.Access.AStatic]
							});
						default: trace("ignored");
					}
				}
			default: trace("ignored");
		}

		var type :TypeDefinition = {
			pos:pos,
			params:[],
			pack:[],
			name: typeName,
			meta:[],
			kind:haxe.macro.TypeDefKind.TDClass(),
			isExtern:false,
			fields:fields
		}
		Context.defineType(type);

		var x = Context.getType(typeName);

		return {pos:pos, expr:haxe.macro.ExprDef.EConst(haxe.macro.Constant.CIdent(typeName))};
	}
}
