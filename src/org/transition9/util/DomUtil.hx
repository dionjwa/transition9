package org.transition9.util;

#if js
import js.Dom;
#end

using org.transition9.util.StringUtil;

class DomUtil
{
	public static function setStyle (style :String, name :String, value :String) :String
	{
		if (style.isBlank() && value.isBlank()) {
			return "";
		}
		
		if (style.isBlank()) {
			return name + ":" + value;
		}
		
		var styleTokens = style.split(";");
		for (ii in 0...styleTokens.length) {
			if (styleTokens[ii].split(":")[0].trim() == name) {
				if (value.isBlank()) {
					styleTokens.splice(ii, 2);
				} else {
					styleTokens[ii] = name + ":" + value;
				}
				return styleTokens.join(";");
			}
		}
		
		return style + ";" + name + ":" + value;
	}
	
	#if js
	public static function removeAllChildren (dom :HtmlDom) :HtmlDom
	{
		while (dom.lastChild != null) {
			dom.removeChild(dom.lastChild);
		}
		return dom;
	}
	#end
	
}
