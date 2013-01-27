package transition9.util;


#if (flash || cpp || neko || jeash)
	typedef ImageType = flash.display.Bitmap;
#elseif js
	typedef ImageType = Image;
#end
