package transition9.util;

import transition9.util.Preconditions;

/**
  * Extend Enumerable to accept haxe enum types as contructor arguments.
  * This allows enum specific compiler features such as detected if all enums
  * are present in switch statements.
  *
  * TODO: choose a better class name, I don't like this one.
  */
class EnumWrappedEnumerable<T, E> extends transition9.util.Enumerable<T>
{
	/** Corresponding enum.  Used for haxe compiler enum functionality e.g. switches. */
	public var e (get_enum, never) :E;
	
	/**
	  * Keep the constructor private
	  */
	private function new (en :E) 
	{
		Preconditions.checkNotNull(en);
		Preconditions.checkArgument(switch(Type.typeof(en)) {
			case TEnum(e): true;
			default: false;
		}, "en must be an Enum");
		_enum = en;
		super(Type.enumConstructor(cast(en)));
	}
	
	inline function get_enum () :E
	{
		return _enum;
	}
	
	var _enum :E;
}
