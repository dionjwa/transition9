/*******************************************************************************
 * Hydrax: haXe port of the PushButton Engine
 * Copyright (C) 2010 Dion Amago
 * For more information see http://github.com/dionjwa/Hydrax
 *
 */
package transition9.util;

import Type;

import transition9.util.Preconditions;
import transition9.rtti.ReflectUtil;

#if nodejs
import js.Node;
#end

using StringTools;

/**
 * Contains useful static function for performing operations on Strings.
 */
class StringUtil
{
	public static function add (s1 :Void->String, s2 :Void->String) :String
	{
		 return s1() + s2();
	}
	
	inline public static function isBlank (s :String) :Bool
	{
		return s == null || s == "";
	}
	
	public static function getFileExtension (file :String):String
	{
		var extensionIndex = file.lastIndexOf(".");
		if (extensionIndex == -1) {
			//No extension
			return "";
		} else {
			return file.substr(extensionIndex + 1,file.length);
		}
	}
	 
	// public static function objectToString (obj :Dynamic, ?fields :Array<String>) :String
	// {
	// 	if (obj == null ) {
	// 		return "null";
	// 	}
		
	// 	switch (Type.typeof(obj)) {
	// 		case TNull: return "null";
	// 		case TInt: return Std.string(obj);
	// 		case TFloat: return Std.string(obj);
	// 		case TBool: return Std.string(obj);
	// 		case TObject: return Std.string(obj);// Type.getClassName(obj);//Assume it's a class
	// 		case TClass(c):
	// 			if (c == String) {
	// 				return Std.string(obj);
	// 			}
	// 		// case TEnum(e): return Type.enumConstructor(e).substr(Type.enumConstructor(e).lastIndexOf(".") + 1);
	// 		case TUnknown: Std.string(obj);
	// 		default://Keep going
	// 	}
		
	// 	var s :StringBuf = new StringBuf();
	// 	var clsName = "";
		
	// 	try {
	// 		clsName = Type.getClass(obj) != null ? ReflectUtil.tinyClassName(obj) : "Dynamic";
	// 		fields = fields == null && Type.getClass(obj) != null ? Type.getInstanceFields(Type.getClass(obj)) : fields;
	// 	} catch (e :Dynamic) {
	// 		clsName = "Dynamic";
	// 	}
	// 	s.add("[" + clsName);
		
	// 	fields = fields == null ? [] : fields;
	// 	for (f in fields) {
	// 		if (!Reflect.isFunction(Reflect.field(obj, f))) {
	// 			s.add(", " + f + "=" + ReflectUtil.field(obj, f));
	// 		}
	// 	}
	// 	s.add("]");
	// 	return s.toString();
	// }
	
	 /**
	  * By default, Std.string(someClass) produces something like:
	  * [class Sprite].  The Std.string(someclass) string doesn't include the entire 
	  * package name, leading to collisions if classes are used as
	  * keys in maps.
	  */
	 public static function getStringKey (obj :Dynamic) :String
	 {
	 	 if (obj == null) {
	 	 	 return "";
		 } else if (Std.is(obj, String)) {
			 return cast(obj, String);
		 } else {
		 	 var typ = Type.typeof(obj);
		 	 if (typ != null) {
				 return switch (typ) {
					case TObject://We assume it's a class or interface
						Type.getClassName(obj);
					case TEnum (e)://We assume it's a class or interface
						// Type.getEnumName(e) + "." + 
						Type.enumConstructor(obj);
					default :
						Std.string(obj);
				 }
			 } else {
			 	 return Std.string(obj);
			 }
		 }
	 }

	/**
	 * Get a hashCode for the specified String. null returns 0.
	 * This hashes identically to Java's String.hashCode(). This behavior has been useful
	 * in various situations.
	 */
	public static function hashCode (str :String) :Int
	{
		transition9.util.Assert.isNotNull(str, ' str is null');
		var code :Int = 0;
		if (str.length == 0) return code;
		for (ii in 0...str.length) {
			#if js
				code = ((code<<5)-code) + untyped str.cca(ii);
				code = code & code; // Convert to 32bit integer
			#else
			//Flash, other platforms?
				code = 31 * code + untyped str.cca(ii);
			#end
		}
		return code;
	}

	/**
	 * Format the specified uint as a String color value, for example "0x000000".
	 *
	 * @param c the uint value to format.
	 * @param prefix the prefix to place in front of it. @default "0x", other possibilities are
	 * "#" or "".
	 */
	public static function toColorString (c :Int, ?prefix :String = "0x") :String
	{
		// return prefix + prepad(StringTools.hex(c), 6, "0");
		return prefix + StringTools.hex(c).lpad("0", 6);
	}

	/**
	 * @return true if the specified String is == to a single whitespace character.
	 */
	public static function isWhitespace (character :String) :Bool
	{
		switch (character) {
		case " ":
			return true;
		case "\t":
			return true;
		case "\r":
			return true;
		case "\n":
			return true;
		default:
			return false;
		}
	}
}
