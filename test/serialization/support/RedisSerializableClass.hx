package serialization.support;

typedef PIndex = { name:String, filter:Dynamic->String };

class RedisSerializableClass
	implements haxe.rtti.Infos
{
	#if nodejs
	static var _indexOn :Array<PIndex> = [
		{name :"var2",filter :function(el :Dynamic) :String {return "" + cast(el, RedisSerializableClass).var2;}}
	];
	#end
	
	public var _id :String;
	public var var1 :String;
	public var var2 (get_var2, set_var2) :Int;
	@ignore
	var _var2 :Int;
	function get_var2 () :Int
	{
		return _var2;
	}
	
	public var var3 :Array<Int>;
	
	function set_var2 (val :Int) :Int
	{
		_var2 = val;
		return val;
	}
	
	
	public function new ()
	{
		var1 = "default";
		var2 = 0;
		var3 = [1, 2, 3];
	}
	
	public function toString () :String
	{
		return "[var1=" + var1 + ", var2=" + var2 + ",]";
	}

}
