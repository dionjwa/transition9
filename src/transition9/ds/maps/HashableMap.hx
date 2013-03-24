/*******************************************************************************
 * Hydrax: haXe port of the PushButton Engine
 * Copyright (C) 2010 Dion Amago
 * For more information see http://github.com/dionjwa/Hydrax
 *
 * This file is licensed under the terms of the MIT license, which is included
 * in the License.html file at the root directory of this SDK.
 ******************************************************************************/

package transition9.ds.maps;

import transition9.ds.Collection;
import transition9.ds.Hashable;

import de.polygonal.ds.Map;

import haxe.FastList;

//OBSOLETE
/**
 * Keys are objects that implement Hashable, useful for platforms 
 * where no object dictionary exists, such as js, php (others?).
 * It's not as fast as a String or Int key based map however.
 */
class HashableMap<K :Hashable, V> extends TransformKeyMap<K, Int, V>
{
	/**
	  * Tests existance of Hashable key ignoring the key type class. 
	  */
	public static function existsHashable (collection :Collection<Hashable>, element :Hashable) :Bool
	{
		return collection.exists(element);    
	}
	
	public static function removeHashable (collection :Collection<Hashable>, element :Hashable) :Void
	{
		//Will be a set or map.  The remove method should be identical
		untyped collection.remove(element);
	}
	
	public static function getValue <T>(map :Map<Dynamic, T>, key :Hashable) :T
	{
		//Retrieves a value
		return untyped map.get(key);
	}
	
	public static function getHashCode (key :Hashable) :Int
	{
		return key == null ? 0 : key.hashCode();
	}
	
	public function new()
	{ 
		super(getHashCode, new IntHashMap());
	}
}
