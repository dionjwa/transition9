/*******************************************************************************
 * Hydrax: haXe port of the PushButton Engine
 * Copyright (C) 2010 Dion Amago
 * For more information see http://github.com/dionjwa/Hydrax
 *
 * This file is licensed under the terms of the MIT license, which is included
 * in the License.html file at the root directory of this SDK.
 ******************************************************************************/
package transition9.util;

import de.polygonal.ds.Hashable;

class HashUtil
{
	inline public static function computeTwoIntHash (v1 :Int, v2 :Int) :Int
	{
		//Collisions when the values are close together
		// _hashCode = v1.hashCode() ^ v2.hashCode();
		// key = StringUtil.hashCode(haxe.SHA1.encode(v1.key + ":" + v2.key));
		return (17 * 31 + v1) * 31 + v2;
	}
	
	public static function computeHashCodeFromHashables (v1 :Hashable, v2 :Hashable) :Int
	{
		return computeTwoIntHash((v1 == null ? 0 : v1.key), (v2 == null ? 0 : v2.key));
	}
}
