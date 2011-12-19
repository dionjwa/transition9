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
import org.transition9.geom.bounds.BoundsForwarding;
import org.transition9.geom.bounds.BoundsLine;
import org.transition9.geom.bounds.BoundsPoint;
import org.transition9.geom.bounds.BoundsPolygon;
import org.transition9.geom.bounds.BoundsUtil;
import org.transition9.geom.bounds.IBounds;
import org.transition9.rtti.ReflectUtil;

import de.polygonal.motor.geom.math.Vec2;

using org.transition9.geom.CircleUtil;
using org.transition9.geom.Vec2Tools;

class BoundsCircle extends AbstractBounds<BoundsCircle>
{
	public function new (c :Circle)
	{
		super();
		_boundsCircle = c;
		_boundsRect = new Rectangle();
		set_center(new Vec2(c.x, c.y));
	}

	override function get_center ():Vec2
	{
		return _boundsCircle.center;
	}

	override function set_center (v :Vec2) :Vec2
	{
		_boundsCircle.center = v;
		_center = _boundsCircle.center; 
		_boundsRect.x = _center.x - _boundsCircle.radius;
		_boundsRect.y = _center.y - _boundsCircle.radius;
		_boundsRect.width = _boundsRect.height = _boundsCircle.radius * _boundsCircle.radius;
		return v;
	}

	override public function clone () :BoundsCircle
	{
		return new BoundsCircle(_boundsCircle.clone());
	}

	override public function containsPoint (v :Vec2) :Bool
	{
		return _boundsCircle.containsPoint(v);
	}

	override public function distance (b :IBounds<Dynamic>) :Float
	{
		if (Std.is(b, BoundsForwarding)) {
			return distance(cast(b, BoundsForwarding<Dynamic>).getForwarded()); 
		}
		
		if (Std.is(b, BoundsPoint)) {
			return BoundsUtil.distancePointCircle(cast(b), this);
		} else if (Std.is(b, BoundsPolygon)) {
			return BoundsUtil.distanceCirclePolygon(this, cast(b));
		} else if (Std.is(b, BoundsCircle)) {
			return BoundsUtil.distanceCircleCircle(this, cast(b));
		} 
		// else if (Std.is(b, BoundsLine)) {
		//	 return BoundsUtil.distancePointLine(this, cast(b));
		// }
		throw "Not implemented between " + ReflectUtil.getClassName(this) +
			" and " + ReflectUtil.getClassName(b);
		return Math.NaN;
	}

	override public function distanceToPoint (v :Vec2) :Float
	{
		return _boundsCircle.distancePoint(v);
	}
	
	override public function isWithinDistance(b :IBounds<Dynamic>, d :Float) :Bool
	{
		if (Std.is(b, BoundsForwarding)) {
			return isWithinDistance(cast(b, BoundsForwarding<Dynamic>).getForwarded(), d); 
		}
		
		if (Std.is(b, BoundsPoint)) {
			return BoundsUtil.isWithinDistancePointCircle(cast(b), this, d);
		} else if (Std.is(b, BoundsPolygon)) {
			return BoundsUtil.isWithinDistanceCirclePolygon(this, cast(b), d);
		} else if (Std.is(b, BoundsCircle)) {
			return BoundsUtil.isWithinDistanceCircleCircle(this, cast(b), d);
		} 
		// else if (Std.is(b, BoundsLine)) {
			
		//	 return BoundsUtil.distancePointLine(this, cast(b), d);
		// }
		throw "Not implemented between " + ReflectUtil.getClassName(this) +
			" and " + ReflectUtil.getClassName(b);
		return false;
	}

	// override public function getBoundedPoint (v :Vec2, ?v :Vec2) :Vec2
	// {
	//	 if (v != null) {
	//		 v.x = _center.x;
	//		 v.y = _center.y;
	//		 return v;
	//	 } else {
	//		 return _center;
	//	 }
	// }

	// override public function getBoundedPointFromMove (originX :Float, originY :Float,
	//	 targetX :Float, targetY :Float, ?v :Vec2) :Vec2
	// {
	//	 return _center;
	// }

	public function toString () :String
	{
		return ReflectUtil.tinyClassName(this) + "[" + _boundsCircle + "]";
	}
	
}
