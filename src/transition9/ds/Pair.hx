/*******************************************************************************
 * Hydrax: haXe port of the PushButton Engine
 * Copyright (C) 2010 Dion Amago
 * For more information see http://github.com/dionjwa/Hydrax
 *
 * This file is licensed under the terms of the MIT license, which is included
 * in the License.html file at the root directory of this SDK.
 ******************************************************************************/
package transition9.ds;
import transition9.util.HashUtil;
import transition9.util.StringUtil;
import de.polygonal.ds.Hashable;

// #if (flash || cpp || cs || java)
// @:generic
// #end
class Pair<T:de.polygonal.ds.Hashable> implements Hashable
#if (flash || cpp || cs || java)
    ,implements haxe.rtti.Generic // Generate typed templates on static targets
#end
{
	// static var temp :Pair<Dynamic> = new Pair(null, null);
	
	// public static function containsPair (c :Collection<Dynamic>, v1 :Dynamic, v2 :Dynamic) :Bool
	// {
	// 	// temp.set(v1, v2);
	//     // var isValue = c.exists(temp);
	//     // temp.clear();
	//     // return isValue;
	    
	//     temp.set(v1, v2);
	//     var isValue = c.exists(new Pair(v1, v2));
	//     temp.clear();
	//     return isValue;
	// }
	
	public static function comparePairs (a :Pair<Dynamic>, b :Pair<Dynamic>) :Int
	{
		return transition9.util.Comparators.compareInts(a.key, b.key);    
	}
	
	public var v1 (default, null) :T;
	public var v2 (default, null) :T;
	public var key :Int;
	
	public function new (v1 :T, v2 :T)
	{
		__internal__set(v1, v2);
	}
	
	// public function hashCode () :Int
	// {
	// 	return _hashCode;
	// }
	
	public function equals (other :Pair<T>) :Bool
	{
		// return v1.equals(other.v1) && v2.equals(other.v2);//other.hashCode() == this.hashCode();
		return v1 == other.v1 && v2 == other.v2;//other.hashCode() == this.hashCode();
	}
	
	//Bad idea?  It would fuck up Tuple map keys
	//OTOH, it lets us cache keys.
	public function __internal__set (v1 :T, v2 :T) :Pair <T>
	{
		this.v1 = v1;
		this.v2 = v2;
		if (v1 == null && v2 == null) {
			key = 0;
		} else if (v1 == null){
			key = v2.key;
		} else if (v2 == null){
			key = v1.key;
		}else {
			//Collisions when the values are close together
			// _hashCode = v1.hashCode() ^ v2.hashCode();
			key = StringUtil.hashCode(haxe.SHA1.encode(v1.key + ":" + v2.key));
		}
		return this;
	}

	// var _hashCode :Int;
	
	#if debug
	public function toString () :String
	{
		return "Pair[" + v1 + ", " + v2 + "]";
	}
	#end
}
