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
import org.transition9.geom.Geometry;
import org.transition9.geom.Rectangle;
import org.transition9.geom.bounds.AbstractBounds;
import org.transition9.geom.bounds.BoundsLine;
import org.transition9.geom.bounds.BoundsPolygon;
import org.transition9.geom.bounds.BoundsUtil;
import org.transition9.geom.bounds.IBounds;
import org.transition9.rtti.ReflectUtil;

import de.polygonal.motor.geom.math.Vec2;

using org.transition9.geom.Vec2Tools;

class BoundsPoint extends AbstractBounds<BoundsPoint>
{
	public static var FIXED_ZERO_BOUNDS :BoundsPoint = new BoundsPoint(0, 0);

	public function new (x :Float, y :Float)
	{
		super();
		_boundsRect = new Rectangle(x, y, 0, 0);
		_boundsCircle = new Circle(0, x, y);
		set_center(new Vec2(x, y));
	}

	override function get_center ():Vec2
	{
		return _center;
	}

	override function set_center (v :Vec2) :Vec2
	{
		_center = v;
		_boundsRect.x = _center.x;
		_boundsRect.y = _center.y;
		_boundsCircle.x = _center.x;
		_boundsCircle.y = _center.y;
		return v;
	}

	override public function clone () :BoundsPoint
	{
		return new BoundsPoint(_center.x, _center.y);
	}

	override public function containsPoint (v :Vec2) :Bool
	{
		return v.equals(_center);
	}

	// #if (flash || cpp)
	// public function debugDraw (s :flash.display.Sprite) :Void
	// {
	//	 org.transition9.util.DebugUtil.drawDot(s, 0xff0000, 4, _center.x, _center.y);
	// }
	// #end

	override public function distance (b :IBounds<Dynamic>) :Float
	{
		if (Std.is(b, BoundsPoint)) {
			return BoundsUtil.distancePointPoint(this, cast(b));
		} else if (Std.is(b, BoundsPolygon)) {
			return BoundsUtil.distancePointPolygon(this, cast(b));
		} else if (Std.is(b, BoundsLine)) {
			return BoundsUtil.distancePointLine(this, cast(b));
		}
		throw "Not implemented between " + ReflectUtil.getClassName(this) +
			" and " + ReflectUtil.getClassName(b);
		return Math.NaN;
	}

	override public function distanceToPoint (v :Vec2) :Float
	{
		return _center.distance(v);
	}
	
	override public function isWithinDistance(b :IBounds<Dynamic>, d :Float) :Bool
	{
		if (Std.is(b, BoundsPoint)) {
			return BoundsUtil.isWithinDistancePointPoint(this, cast(b), d);
		} else if (Std.is(b, BoundsPolygon)) {
			return BoundsUtil.isWithinDistancePointPolygon(this, cast(b), d);
		} 
		// else if (Std.is(b, BoundsLine)) {
			
		//	 return BoundsUtil.distancePointLine(this, cast(b), d);
		// }
		throw "Not implemented between " + ReflectUtil.getClassName(this) +
			" and " + ReflectUtil.getClassName(b);
		return false;
	}

	override public function getBoundedPoint (v :Vec2, ?v :Vec2) :Vec2
	{
		if (v != null) {
			v.x = _center.x;
			v.y = _center.y;
			return v;
		} else {
			return _center;
		}
	}

	override public function getBoundedPointFromMove (originX :Float, originY :Float,
		targetX :Float, targetY :Float, ?v :Vec2) :Vec2
	{
		return _center;
	}

	public function toString () :String
	{
		return ReflectUtil.tinyName(BoundsPoint) + "[" + _center + "]";
	}

}
