package org.transition9.serialization;

import haxe.rtti.CType;
import org.transition9.rtti.ReflectUtil;
import org.transition9.rtti.MetaUtil;

using Lambda;
using StringTools;

interface SerializableDynamic 
{
	function serializeDynamic () :Dynamic;
	function deserializeDynamic (from :Dynamic) :Void;
}

/*
 * Copied and modified from bdog.Serialize.	
 * A simple serializer that converts a class to a dynamic object, in the process
 * tweaking arrays to be arrays of objects (rather than classes) and enums to be
 * string constructors.
 *
 * Allows field metadata:
 * @ignore		:ignores the field
 */

class Serialization
{
	// 	/** Convert to base64 encoded String */
	// public static function encode (bytes :haxe.io.BytesData) :String
	// {
	// 	#if flash
	// 	//It's fast.  Polygonal?
	//     return jpauclair.Base64.encode(bytes);
	//     #else
	//     throw "What is the Base64 encoder for this platform?";
	//     return null;
	//     #end
	// }
	
	// /** Convert from base64 encoded String */
	// public static function decode (base64Encoded :String) :haxe.io.BytesData
	// {
	// 	#if flash
	// 	//It's fast.  Polygonal?
	//     return jpauclair.Base64.decode(base64Encoded);
	//     #else
	//     throw "What is the Base64 encoder for this platform?";
	//     return null;
	//     #end
	// }
	
	// #if polygonal
	// public static function xyArrayToFloatArray (xys :Array<de.polygonal.motor2.geom.math.XY>) :Array<Float>
	// {
	// 	var arr = [];
	// 	for (v in xys) {
	// 		arr.push(v.x);
	// 		arr.push(v.y);
	// 	}
	// 	return arr;
	// }
	
	// public static function floatArrayToXYArray (floats :Array<Float>) :Array<de.polygonal.motor2.geom.math.XY>
	// {
	// 	var arr = new Array<de.polygonal.motor2.geom.math.XY>();
	// 	var ii = 0;
	// 	while (ii < floats.length) {
	// 		arr.push(new com.pblabs.geom.Vector2(floats[ii], floats[ii + 1]));
	// 		ii += 2;
	// 	}
	// 	return arr;
	// }
	// #end
	
	public static function floatArrayToBytes (floats :Array<Float>) :haxe.io.Bytes
	{
		var output = new haxe.io.BytesOutput();
		floats.iter(output.writeFloat);
		output.close();
		return output.getBytes();
	}
	
	public static function bytesToFloatArray (bytes :haxe.io.Bytes) :Array<Float>
	{
		var arr = [];
		var input = new haxe.io.BytesInput(bytes);
		for (ii in 0...Std.int(bytes.length / 4)) {
			arr.push(input.readFloat());
		}
		input.close();
		return arr;
	}
	
	public static function classToDoc(o :Dynamic) :Dynamic 
	{
		if (Std.is(o, SerializableDynamic)) {
			return cast(o, SerializableDynamic).serializeDynamic(); 
		}
		// throw "Not working properly yet";
		var final :Dynamic = null;
		switch(Type.typeof(o)) {
			case TNull :final = null;
			case TClass(kls):
				
				if (kls == String || kls == Int || kls == Float || kls == Date) {
					return o;
				}
				// switch (kls) {
				// 	case String:
				// 	case Int:
				// 	case Float:
				// 	case Date:
				// 		return o;
				// 	default:
				// }
			
			
			
				var z = {};
				for (f in Type.getInstanceFields(kls)) {
					if (MetaUtil.isFieldMetaData(kls, f, "ignore")) {
						continue;
					}
					
					var val :Dynamic = Reflect.field(o,f);

					// if (f == "_id" && val != null) {
					// 	Reflect.setField(z, "_id", untyped ObjectId(val)); 
					// 	continue;
					// }

					if (val != null && !Reflect.isFunction(val)) {
					switch(Type.typeof(val)) {
						case TInt, TBool, TFloat:
							Reflect.setField(z,f, val);
						case TClass(c ) :
							var cn = Type.getClassName(c);
							
							switch (cn) {
								case "Array":
									var na = new Array<Dynamic>();
									if (val != null) {
										for (el in cast(val,Array<Dynamic>)) {
											na.push(classToDoc(el));
										}
									}
									Reflect.setField(z,f, na);
								case "String":
									Reflect.setField(z,f, val);
								case "Date":
									Reflect.setField(z,f, Date.fromString(Std.string(val)));
								default:
									Reflect.setField(z, f, classToDoc(val));
							}
							
							// if (cn == "Array") {
								
							// } else {
							// 	if (cn != "String")
									
							// 	else
							// 		val;
							// }
						case TEnum(_) : 
							Reflect.setField(z,f, Type.enumConstructor(val));		  
						default :
							Reflect.setField(z,f, val);
					};
					}
				}
				final = z;
			case TEnum(e) : final = Type.enumConstructor(o);
			default :
				if (!Reflect.isFunction(o))
					final = o;
		}
		return final;
	}
	
	static function deserClass(o, resolved :Class<Dynamic>, ?newObj :Dynamic) :Dynamic 
	{
		// trace("deserClass " + Std.string(o) + ", type=" + Type.getClassName(resolved));
		// org.transition9.util.Assert.isNotNull(resolved, " resolved is null");
		
		// if (resolved == Int || resolved == Float) {
		// 	return o;
		// }
		
		var rtti = ReflectUtil.getRttiTypeTree(resolved);
		if (rtti == null) {
			// org.transition9.util.Log.error(Type.getClassName(resolved) + " has no rtti info");
			// if (newObj == null) trace(Type.getClassName(resolved) + " has no rtti info");
			return newObj != null ? newObj : Type.createEmptyInstance(resolved);
		}
		
		if (newObj == null) {
			newObj = Type.createEmptyInstance(resolved);
		}
		
		switch(rtti) {
			case TClassdecl(typeInfo) :
				Lambda.iter(typeInfo.fields,function(el) {
					var val = Reflect.field(o, el.name);
					// trace('el=' + JSON.stringify(el));
					classFld(newObj, el.name, val, el.type);
				});
			default :
		}
		
		if (Type.getSuperClass(resolved) != null) {
			// trace("deserializing from superclass, " + Type.getClassName(resolved) + "->" + Type.getClassName(Type.getSuperClass(resolved))); 
			deserClass(o, Type.getSuperClass(resolved), newObj); 
		}
		
		return newObj;
	}
	
	static function classFld(newObj :Dynamic, name :String, val :Dynamic, el :CType)
	{
		if (val == null) {
			return;
		}
		
		switch(el) {
			case CClass(kls,subtype) :
				switch(kls) {
					case "String":
						Reflect.setField(newObj, name, Std.string(val));
					case "Float", "Int":
							Reflect.setField(newObj, name, val);
					case "Date":
						Reflect.setField(newObj, name, Date.fromString(Std.string(val)));
					case "Array":
						var na = [];//new Array<Dynamic>(),
						var st = subtype.first();
						// trace("array, first=" + Std.string(st));
						if (val != null) {
							for (i in cast(val,Array<Dynamic>)) {
								if (i == null) {
									na.push(null);
								} else { 
									switch(st) {
										case CClass(path,_):
											if (path == "Int" || path == "Float" || path == "String") {
												na.push(i);
											} else if (path == "Date") {
												na.push(Date.fromString(Std.string(i)));
											} else {
												na.push(deserClass(i,Type.resolveClass(path)));
											}
										case CEnum(enumPath,_) :
											var e = Type.resolveEnum(enumPath);
											org.transition9.util.Assert.isNotNull(i);
											na.push(Type.createEnum(e,i));
										default :
											na.push(i);
									}
								}
							}
						}
		
						Reflect.setField(newObj,name,na);
		
					default :
						Reflect.setField(newObj,name,deserClass(val,Type.resolveClass(kls)));
				}
		
			case CEnum(enumPath, params) :
				if (enumPath == "Bool") {
					Reflect.setField(newObj, name, val);
				} else {
					var e = Type.resolveEnum(enumPath);
					org.transition9.util.Assert.isNotNull(e, ' e is null');
					org.transition9.util.Assert.isNotNull(val, ' val is null');
					Reflect.setField(newObj, name, Type.createEnum(e, val));
				}
				
			default :
		//	  trace("other deser type"+el);
		}
	}  
	
	public static function docToClass(o :Dynamic, myclass :Class<Dynamic>) :Dynamic 
	{
		if (o == null) return null;
		
		var newObj = Type.createEmptyInstance(myclass);
		if (Std.is(newObj, SerializableDynamic)) {
			cast(newObj, SerializableDynamic).deserializeDynamic(o);
			return newObj;
		}
		// throw "Not working properly yet";
		return deserClass(o,myclass);
	}
	
	/**
	  * Converts an object instance into an array of ["field1Name", field1Value, "field2Name", field2Value, ...]
	  * This is designed to be stored as a Redis hash.
	  * Complex (class) fields are serialized using the Haxe Serializer
	  */
	public static function classToArray(o :Dynamic) :Array<Dynamic> 
	{
		var arr :Array<Dynamic> = []; 
		switch(Type.typeof(o)) {
			case TNull : //Do nothing
			case TClass(kls):
				// arr.push("class");
				// arr.push(Type.getClassName(kls));
				for (f in Type.getInstanceFields(kls)) {
					if (MetaUtil.isFieldMetaData(kls, f, "ignore")) {
						continue;
					}
					var val :Dynamic = ReflectUtil.field(o, f);
					if (val == null || Reflect.isFunction(val)) {
						continue;
					}
					arr.push(f);
					arr.push(switch(Type.typeof(val)) {
						case TInt, TBool, TFloat : Std.string(val);
						case TClass(c):
							var cn = Type.getClassName(c);
							if (cn == "String") {
								val;
							} else if (cn == "Date") {
								Std.string(val);
							} else {
								haxe.Serializer.run(val);
							}
						case TEnum(_) : Type.enumConstructor(val);
						default : trace("Unserialized type=" + f); null;
					});
				}
			case TEnum(e) : Type.enumConstructor(o);
			default :trace("Unhandled  type=" + Type.typeof(o));
		}
		return arr;
	}
	
	public static function arrayToClass<T>(arr :Array<Dynamic>, cls :Class<T>) :T 
	{
		// var clsName = arr[1];
		// var resolved = Type.resolveClass(clsName);
		var obj = Type.createInstance(cls, EMPTY_ARRAY);
		
		var m = haxe.rtti.Meta.getFields(cls);
		// trace("fields metadata=" + Std.string(m));
		
		var rtti = ReflectUtil.getRttiTypeTree(cls);
		if (rtti == null) {
			trace("No rtti info for class " + Type.getClassName(cls));
			return obj;
		}
		
		switch(rtti) {
			case TClassdecl(typeInfo):
				var ii :Int = 0;
				// var map = new Hash<String>();
				while (ii < arr.length) {
					var fieldName = arr[ii];
					var fieldStringVal = arr[ii + 1];
					// map.set(arr[ii], );
					// trace('typeInfo=' + Std.string(typeInfo));
					// trace("");
					var fieldMeta :Dynamic = null;
					for (m in typeInfo.fields) {
						if (m.name == fieldName) {
							fieldMeta = m;
							break;
						}
					}
					
					// var fieldMeta = Reflect.field(typeInfo.fields, fieldName);
					
					
					
					// trace(fieldName + "=" + Std.string(typeInfo));
					// trace('fieldMeta=' + Std.string(fieldMeta));
					if (fieldMeta != null && !Reflect.isFunction(Reflect.field(obj, fieldName)) && !MetaUtil.isFieldMetaData(cls, fieldName, "ignore")) {
						// trace("checking " + (fieldMeta == null ? "null" : fieldMeta.name)); 
						switch(fieldMeta.type) {
							case CClass(kls,subtype) :
								switch(kls) {
									case "Int": ReflectUtil.setField(obj, fieldName, Std.parseInt(fieldStringVal));
									case "Float": ReflectUtil.setField(obj, fieldName, Std.parseFloat(fieldStringVal));
									case "String": ReflectUtil.setField(obj, fieldName, fieldStringVal);
									case "Bool": ReflectUtil.setField(obj, fieldName, fieldStringVal == "true");
									case "Date": ReflectUtil.setField(obj, fieldName, Date.fromString(fieldStringVal));
									default: ReflectUtil.setField(obj, fieldName, haxe.Unserializer.run(fieldStringVal));
								}
							case CEnum(enumPath, _):
								var e = Type.resolveEnum(enumPath);
								org.transition9.util.Assert.isNotNull(e, ' e is null');
								org.transition9.util.Assert.isNotNull(fieldStringVal, ' fieldStringVal is null');
								ReflectUtil.setField(obj, fieldName, Type.createEnum(e,fieldStringVal));
							default : trace("Cannot deserialize type " + fieldMeta.type);
						}
						// classFldFromString(obj, fieldMeta.name, fieldStringVal, fieldMeta);
					}
					
					ii += 2;
				}
				// trace(Std.string(typeInfo));
				// Lambda.iter(typeInfo.fields,function(el) {
				// 	var val = map.get(el.name);
				// 	trace(el.name + '=' + val);
				// 	classFld(obj,el.name,val,el.type);
				// });
			default :trace("rtti type not supported " +Type.getClassName(cls));
		}
		return obj;
	}
	
	// public static function objectToString(o :Dynamic) :String 
	// {
	// 	return switch(Type.typeof(o)) {
	// 		case TNull : null;
	// 		case TInt, TFloat, TBool: Std.string(o);
	// 		case TFunction: trace("cannot convert a TFunction to String"); null;
	// 		case TClass(kls): 
	// 		case TEnum(e) : Type.enumConstructor(o);
	// 		default : throw "Unhandled type -> String"; null;
	// 	}
	// }
	
	// static function createClassFieldFromString(val :String, meta :Dynamic) :Dynamic
	// {
	// 	switch(meta.type) {
	// 		case CClass(kls,subtype) :
	// 			switch(kls) {
	// 				case "Int": return Std.parseInt(val);
	// 				case "Float": return Std.parseFloat(val);
	// 				case "String": return val;
	// 				case "Array":
	// 					var
	// 					na = new Array<Dynamic>(),
	// 					st = subtype.first();
	// 					if (val != null) {
	// 						for (i in cast(val,Array<Dynamic>)) {
	// 							switch(st) {
	// 								case CClass(path,_) :
	// 									na.push(deserClass(i,Type.resolveClass(path)));
	// 								case CEnum(enumPath,_) :
	// 									var e = Type.resolveEnum(enumPath);
	// 									na.push(Type.createEnum(e,i));
	// 								default :
	// 									na.push(i);
	// 							}
	// 						}
	// 					}
		
	// 					Reflect.setField(newObj,name,na);
		
	// 				default :
	// 					Reflect.setField(newObj,name,deserClass(val,Type.resolveClass(kls)));
	// 			}
		
	// 		case CEnum(enumPath,_) :
	// 			var e = Type.resolveEnum(enumPath);
	// 			Reflect.setField(newObj,name,Type.createEnum(e,val));
		
	// 		default :
	// 	//	  trace("other deser type"+el);
	// 	}
	// } 
	
	static var EMPTY_ARRAY :Array<Dynamic> = new Array();
}
