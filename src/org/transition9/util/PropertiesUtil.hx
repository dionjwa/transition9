package org.transition9.util;

using StringTools;

class PropertiesUtil
{
	public static function setFieldFromString (obj :Dynamic, fieldName :String, fieldValue :String) :Void
	{
		fieldValue = fieldValue.trim();
		fieldName = fieldName.trim();
		
		try {
			var f = Std.parseFloat(fieldValue);
			if (Math.isNaN(f)) {
				throw "NaN";
			}
			Reflect.setField(obj, fieldName, f);
		} catch (e :Dynamic) {
			try {
				var i = Std.parseInt(fieldValue);
				if (i == null || Math.isNaN(i)) {
					throw "NaN";
				}
				Reflect.setField(obj, fieldName, i);
			} catch (e :Dynamic) {
				if (fieldValue.toLowerCase() == 'true' || fieldValue.toLowerCase() == 'false') {
					Reflect.setField(obj, fieldName, fieldValue.toLowerCase() == 'true');
				} else {
					trace(fieldName + "=String");
					Reflect.setField(obj, fieldName, fieldValue);
				}
			}
		}
	}
}
