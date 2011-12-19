/*******************************************************************************
 * Hydrax: haXe port of the PushButton Engine
 * Copyright (C) 2010 Dion Amago
 * For more information see http://github.com/dionjwa/Hydrax
 *
 * This file is licensed under the terms of the MIT license, which is included
 * in the License.html file at the root directory of this SDK.
 ******************************************************************************/
package org.transition9.geom.bounds;

import org.transition9.geom.Circle;
import org.transition9.geom.Polygon;
import org.transition9.geom.Rectangle;
import org.transition9.geom.bounds.BoundsCircle;
import org.transition9.geom.bounds.BoundsForwarding;
import org.transition9.geom.bounds.BoundsPoint;
import org.transition9.geom.bounds.BoundsPolygon;
import org.transition9.geom.bounds.BoundsUtil;
import org.transition9.geom.bounds.IBounds;

import de.polygonal.motor.geom.math.Vec2;

using org.transition9.geom.PolygonTools;
using org.transition9.geom.RectangleTools;

class BoundsRectangle extends BoundsForwarding<BoundsRectangle>
{
	public function new (r :Rectangle)
	{
		_polygonBounds = new BoundsPolygon(r.toPolygon());
		super(get_polygonBounds);
		_boundsRect = r;
		_boundsCircle = new Circle();
		set_center(new Vec2(r.left + r.width / 2, r.top + r.height / 2));
	}

	override function get_center ():Vec2
	{
		return _center;
	}

	override function set_center (v :Vec2) :Vec2
	{
		super.set_center(center);
		_center = _boundsCircle.center = v;
		_boundsCircle.radius = Math.max(_boundsRect.width, _boundsRect.height);
		_boundsRect.x = _center.x - _boundsCircle.radius;
		_boundsRect.y = _center.y - _boundsCircle.radius;
		return v;
	}

	override public function clone () :BoundsRectangle
	{
		return new BoundsRectangle(_boundsRect.clone());
	}

	override public function containsPoint (v :Vec2) :Bool
	{
		return _boundsRect.contains(v.x, v.y);
	}

	override public function distanceToPoint (v :Vec2) :Float
	{
		if (containsPoint(v)) {
			return 0;
		}
		return super.distanceToPoint(v);
	}
	
	override function get_boundingRect () :Rectangle
	{
		return _boundsRect;
	}
	
	override function get_boundingCircle () :Circle
	{
		return _boundsCircle;
	}
	
	override function computeBoundingRect () :Rectangle
	{
		return _boundsRect;
	}
	
	inline function get_polygonBounds () :BoundsPolygon
	{
		return _polygonBounds;
	}
	
	var _polygonBounds :BoundsPolygon;
	
	#if debug
	public function toString () :String
	{
		return org.transition9.rtti.ReflectUtil.getClassName(this) + "[" + _boundsRect + "]";
	}
	#end
}
