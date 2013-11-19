package transition9.macro;

// import haxe.macro.Context;

class BuildMacros
{
	/**
	  * Embed a binary resource at compile time, but specified in code rather than in the *hxml file.
	  *
	  * Returns the haxe.Resource key.
	  *
	  * Example:
	  * var embed = transition9.util.Macros.embedBinaryDataResource("build/server.swf", "battlecomputer", 1234);
	  * var bytes = haxe.Resource.getBytes("battlecomputer");
	  * trace("bytes.length=" + (bytes == null ? -1 :bytes.length));
	  * 
	  * var swf = new com.pblabs.engine.resource.flash.SwfResource("swf", com.pblabs.engine.resource.Source.bytes(bytes), 1234);
	  * swf.load(function () :Void {
	  * 	trace("loaded as swf");
	  * 	trace(swf.hasSymbol("turngame.server.compute.BattleComputer"));
	  * 
	  * }, function (e :Dynamic) :Void {
	  * 	trace("error loading  swf " + Std.string(e));
	  * });
	  */
	// macro
	// public static function embedBinaryDataResource(binPath :String, ?resourceId :String = null, ?xorKey :Int = -1)
	// {
	// 	if (Context.defined("display")) {
	// 		// When running in code completion, skip out early
	// 		return { expr: EBlock([]), pos: Context.currentPos()};
	// 	}

	// 	resourceId = resourceId != null ? resourceId : binPath;

	// 	var pos = haxe.macro.Context.currentPos();

	// 	if (!sys.FileSystem.exists(binPath)) {
	// 		Context.warning(binPath + " not found, prepending path with '../' ", pos);
	// 		binPath = "../" + binPath;
	// 	}

	// 	if (!sys.FileSystem.exists(binPath)) {
	// 		Context.error(binPath + " not found", pos);
	// 	}

	// 	var bytes = sys.io.File.getBytes(binPath);
	// 	if (xorKey > 0) {
	// 		bytes = transition9.util.BytesUtil.xorBytes(bytes, xorKey);
	// 	}

	// 	haxe.macro.Context.addResource(resourceId, bytes);
	// 	return { expr : EConst(CString(resourceId)), pos : pos };
	// }

	public static function processTemplateFromJson(templatePath :String, jsonPath :String, outPath :String)
	{
		var jsonFileContents = sys.io.File.getContent(jsonPath);
		var json = haxe.Json.parse(jsonFileContents);
		var templateContent = sys.io.File.getContent(templatePath);
		var t = new haxe.Template(templateContent);
		var output = t.execute(json);
		sys.io.File.saveContent(outPath, output);
	}
}
