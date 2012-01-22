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
				if (Math.isNaN(i)) {
					throw "NaN";
				}
				Reflect.setField(obj, fieldName, i);
			} catch (e :Dynamic) {
				if (fieldValue == 'true' || fieldValue == 'false') {
					Reflect.setField(obj, fieldName, fieldValue == 'true');
				} else {
					Reflect.setField(obj, fieldName, fieldValue);
				}
			}
		}
	}
	
}
