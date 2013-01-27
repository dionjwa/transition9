/*******************************************************************************
 * Hydrax: haXe port of the PushButton Engine
 * Copyright (C) 2010 Dion Amago
 * For more information see http://github.com/dionjwa/Hydrax
 *
 * This file is licensed under the terms of the MIT license, which is included
 * in the License.html file at the root directory of this SDK.
 ******************************************************************************/
package transition9.ds.sets;
import transition9.ds.Set;
using transition9.util.ArrayUtil;

class ArraySet<T> implements Set<T>
{
	var _arr :Array<T>;
	
	public function new ()
	{
		_arr = [];
	}
	
	public function add (o :T) :Void
	{
		remove(o);
		_arr.push(o);		
	}
	
	public function remove (o :T) :Bool
	{
		return _arr.removeFirst(o);
	}

	public function isEmpty () :Bool
	{
		return _arr.length == 0;
	}

	public function iterator() : Iterator<T>
	{
		return _arr.iterator();
	}
	
	public function exists (o :T) :Bool
	{
		return _arr.exists(o);
	}

	public function size () :Int
	{
		return _arr.length;
	}

	public function clear () :Void
	{
		_arr = [];
	}
	
	#if debug
	public function toString () :String
	{
		return "(" + Lambda.array(this).join(", ") + ")";
	}
	#end
}
