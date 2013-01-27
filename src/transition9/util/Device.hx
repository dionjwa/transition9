package transition9.util;

import de.polygonal.core.math.Vec2;

using transition9.geom.Vec2Tools;

class Device
{
	#if js
	public static var isRetinaDisplay = {
		untyped __js__("window.devicePixelRatio !== undefined && window.devicePixelRatio >= 2"); 
	}
	
	public static var browser :Browser = {
		if (js.Lib.window.navigator.userAgent.indexOf("Android") > -1) {
			Browser.ANDROID;
		} else if (js.Lib.window.navigator.userAgent.indexOf("Chrome") > -1) {
			Browser.CHROME;
		} else if (js.Lib.window.navigator.userAgent.indexOf("iPhone") > -1) {
			Browser.SAFARI_IOS;
		} else if (js.Lib.window.navigator.userAgent.indexOf("Safari") > -1) {
			Browser.SAFARI_OSX;
		} else if (js.Lib.window.navigator.userAgent.indexOf("Firefox") > -1) {
			Browser.FIREFOX;
		} else if (js.Lib.window.navigator.userAgent.indexOf("Chrome") > -1) {
			Browser.CHROME;
		}
	};
	
	public static var isMobileBrowser = {
		browser == Browser.SAFARI_IOS || browser == Browser.ANDROID;//TODO: Android browsers.  How to detect?
	}
	
	public static function getScreenDimensions () :Vec2
	{
		if (isMobileBrowser) {
			switch (browser) {
				case ANDROID: return new Vec2(js.Lib.window.screen.width, js.Lib.window.screen.height);
				case SAFARI_IOS: return new Vec2(320, 480);
				default:  throw "I don't know what device this is";
			}
		} else {
			#if js
			return new Vec2(js.Lib.window.screen.width, js.Lib.window.screen.height);
			#end
		}
		
	}
	
	#end
}
