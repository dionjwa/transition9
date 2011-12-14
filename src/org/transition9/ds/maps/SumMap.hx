package org.transition9.ds.maps;

import org.transition9.ds.Maps;
import org.transition9.ds.maps.DefaultValueMap;

import Type;

class SumMap<T> extends DefaultValueMap<T, Float>
{
	public function new (type :ValueType)
	{
		super(Maps.newHashMap(type), 0);
	}

	/** Adds to existing value rather than replacing*/
	override public function set (key :T, value :Float) :Float
	{
		var prev = get(key);
		org.transition9.util.Assert.isFalse(Math.isNaN(prev));
		org.transition9.util.Assert.isFalse(Math.isNaN(value));
		super.set(key, prev + value);
		return prev;
	}
	
	public function add (key :T, value :Float) :Float
	{
	    return set(key, value);
	}
}
