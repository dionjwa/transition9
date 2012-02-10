/*******************************************************************************
 * Hydrax: haXe port of the PushButton Engine
 * Copyright (C) 2010 Dion Amago
 * For more information see http://github.com/dionjwa/Hydrax
 *
 * This file is licensed under the terms of the MIT license, which is included
 * in the License.html file at the root directory of this SDK.
 ******************************************************************************/
package org.transition9.geom.bounds;

import org.transition9.geom.Rectangle;
import Vec2;
import org.transition9.rtti.ReflectUtil;

import de.polygonal.core.math.Vec2;

class BoundsNone extends AbstractBounds<BoundsNone> 
{
	public function new()
	{
		super();
	}

	override function get_center ():Vec2
	{
		throw "Abstract method";
		return null;
	}

	public override function clone () :BoundsNone
	{
		return new BoundsNone();
	}

	public override function distance (b :IBounds<Dynamic>) :Float
	{
		return 0;
	}

	public override function distanceToPoint (p :Vec2) :Float
	{
		return 0;
	}
}
