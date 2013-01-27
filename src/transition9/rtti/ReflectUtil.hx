/*******************************************************************************
 * Hydrax: haXe port of the PushButton Engine
 * Copyright (C) 2010 Dion Amago
 * For more information see http://github.com/dionjwa/Hydrax
 *
 * This file is licensed under the terms of the MIT license, which is included
 * in the License.html file at the root directory of this SDK.
 ******************************************************************************/
package transition9.rtti;

import haxe.rtti.CType;

using Lambda;

using StringTools;

/**
  * Will get/set fields with accessor methods, as long as 
  * the accessor methods are formatted get_xY, set_xY, where
  * xY is the variable.
  */
class ReflectUtil
{
	static var rttiTypeTree = new Hash<haxe.rtti.TypeTree>();
	static var cacheClassdef = new Hash<Classdef>();
	static var fieldTypes = new Hash<CType>();
	static var getters = new Hash<Hash<String>>();
	static var setters = new Hash<Hash<String>>();
	
	public static function tinyClassName (obj :Dynamic) :String
	{
		return tinyName(Type.getClass(obj));
	}
	
	inline public static function tinyName (cls :Class<Dynamic>) :String
	{
		#if debug
		var name = Type.getClassName(cls);
		var tokens = name.split(".");
		return tokens[tokens.length - 1];
		#else
		var tokens = Type.getClassName(cls).split(".");
		return tokens[tokens.length - 1];
		#end
	}
	
	public static function getClassName (obj :Dynamic) :String
	{
		return Type.getClassName(getClass(obj));
	}
	
	public static function isSameClass (obj1 :Dynamic, obj2 :Dynamic) :Bool
	{
		return getClass(obj1) == getClass(obj2);
	}
	
	public static function hasStaticMetadata (cls :Class<Dynamic>, field :String, metaId :String) :Bool
	{
		var m = haxe.rtti.Meta.getStatics(cls);
		if (m != null) {
			if (Reflect.hasField(m, field)) {
				return Reflect.hasField(Reflect.field(m, field), metaId);
			}
		} 
		return false;
	}
	
	/** Alt Std.is implementation for cpp while Std.is bug exists */
	public static function is (instance :Dynamic, type :String) :Bool
	{
		var cls = getClass(instance);
		while (cls != null) {
			var classdef = getClassdef(cls);
			if (classdef != null) {
				if (classdef.path == type) {
					return true;
				}
				for (i in classdef.interfaces) {
					if (i.path == type) {
						return true;
					}
				}
			} else {
				// Log.error("ReflectUtil.is called, but the type has no rtti info: " + Type.getClassName(cls) + " is " + type + "?");
				return false;
			}
			cls = Type.getSuperClass(cls);
		}
		return false;
	}
	
	public static function hasSuperClass (cls :Class<Dynamic>, superClass :Class<Dynamic>) :Bool
	{
		var sc = Type.getSuperClass(cls);
		while (sc != null) {
			if (superClass == sc) {
				return true;
			}
			sc = Type.getSuperClass(sc);
		}
		return false;
	}
	
	public static function getClass (obj :Dynamic) :Class<Dynamic>
	{
		switch (Type.typeof(obj)) {
			case TUnknown:
				throw "Unknown map key type";
			case TObject:
				//Assume obj is a class or interface 
				return obj;
			case TNull:
				return null;
			case TInt:
				return Int;
			case TFunction:
				return null;
			case TFloat:
				return Float;
			case TEnum(e):
				return null;
			case TClass(c):
				return c;
			case TBool:
				return null;
		}
	}
	
	public static function getRttiTypeTree(cls : Class <Dynamic> ) :haxe.rtti.TypeTree
	{
		var name = Type.getClassName(cls);
		if (rttiTypeTree.exists(name)) {
			return rttiTypeTree.get(name);
		}
		var rtti = Reflect.field(cls, "__rtti");
		if (rtti == null) {
			rttiTypeTree.set(name, null);
			return null;
		}
		
		var x = new haxe.rtti.XmlParser().processElement(Xml.parse(rtti).firstElement());
		
		rttiTypeTree.set(name, x);
		return x;
	}
	
	public static function getClassdef (cls : Class< Dynamic>) :Classdef
	{
		var name = Type.getClassName(cls);
		if (cacheClassdef.exists(name)) {
			return cacheClassdef.get(name);
		}

		var typeTree = getRttiTypeTree(cls);
		if (typeTree == null) {
			return null;
		}
		
		var cdef :Classdef = switch (typeTree) {
			case TClassdecl(c): c;
			default: null;
		}
		
		cacheClassdef.set(name, cdef);
		return cdef;
	}
	
	public static function getFieldType (cls : Class< Dynamic>, field :String) :CType
	{
		var id = Type.getClassName(cls) + "." + field;
		if (fieldTypes.exists(id)) {
			return fieldTypes.get(id);
		}
		
		var cdef :Classdef = getClassdef(cls);
		if (cdef == null) {
			return null;
		}
		
		for (f in cdef.fields) {
			if (f.name == field) {
				fieldTypes.set(id, f.type);
				return f.type;
			}
		}
		
		var sp = Type.getSuperClass(cls);
		var type = if (sp == null) null else getFieldType(sp, field);
		fieldTypes.set(id, type);
		return type;
	}
	
	public static function getVarFieldType (cls : Class< Dynamic>, field :String) :Class<Dynamic>
	{
		var type = getFieldType(cls, field);
		if (type != null) {
			switch (type) {
				case CClass(name, params):
				return Type.resolveClass(name);
				default:
				return null;
			}
		}
		return null;
	}
	
	public static function field (obj :Dynamic, field :String) :Dynamic
	{
		processGetterSetterMeta(Type.getClass(obj));
		if (getters.get(Type.getClassName(Type.getClass(obj))).get(field) != null) {
			return Reflect.callMethod(obj, Reflect.field(obj, getters.get(Type.getClassName(Type.getClass(obj))).get(field)), EMPTY_ARRAY);
		} else {
			return Reflect.field(obj, field);
		}
	}
	
	public static function setField (obj :Dynamic, field :String, val :Dynamic) :Void
	{
		processGetterSetterMeta(Type.getClass(obj));
		if (setters.get(Type.getClassName(Type.getClass(obj))).get(field) != null) {
			Reflect.callMethod(obj, Reflect.field(obj, setters.get(Type.getClassName(Type.getClass(obj))).get(field)), [val]);
		} else {
			Reflect.setField(obj, field, val);
		}
	}
	
	static function processGetterSetterMeta (cls :Class<Dynamic>) :Void
	{
		if (getters.get(Type.getClassName(cls)) != null) {
			return;
		}
		var className = Type.getClassName(cls);
		
		getters.set(className, new Hash());
		setters.set(className, new Hash());
		
		var rtti = ReflectUtil.getRttiTypeTree(cls);
		if (rtti == null) {
			// Log.info("No rtti type tree for " + Type.getClassName(cls));
			return;
		}
		switch(rtti) {
			case TClassdecl(typeInfo):
			
				//Recurse into super classes.
				if (Type.getSuperClass(cls) != null) {
					processGetterSetterMeta(Type.getSuperClass(cls));
				}
			
				for (fieldMeta in typeInfo.fields) {
					switch(fieldMeta.get) {
						case RCall(m): getters.get(className).set(fieldMeta.name, m);
						default:
					}
					
					switch(fieldMeta.set) {
						case RCall(m): setters.get(className).set(fieldMeta.name, m);
						default:
					}
				}
			default:
		}
		
		//Add superclass fields
		if (Type.getSuperClass(cls) != null) {
			var superClassName = Type.getClassName(Type.getSuperClass(cls));
			if (getters.get(superClassName) != null) {
				for (key in getters.get(superClassName).keys()) {
					getters.get(className).set(key, getters.get(superClassName).get(key));
				}
			}
			if (setters.get(superClassName) != null) {
				for (key in setters.get(superClassName).keys()) {
					setters.get(className).set(key, setters.get(superClassName).get(key));
				}
			}
		}
	}
	
	static var EMPTY_ARRAY :Array<Dynamic> = new Array();
}
