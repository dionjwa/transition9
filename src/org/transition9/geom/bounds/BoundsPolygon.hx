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
import org.transition9.geom.LineSegment;
import org.transition9.geom.Polygon;
import org.transition9.geom.Rectangle;
import org.transition9.geom.bounds.AbstractBounds;
import org.transition9.geom.bounds.BoundsForwarding;
import org.transition9.geom.bounds.BoundsLine;
import org.transition9.geom.bounds.BoundsPoint;
import org.transition9.geom.bounds.BoundsUtil;
import org.transition9.geom.bounds.IBounds;
import org.transition9.util.MathUtil;
import org.transition9.rtti.ReflectUtil;

import de.polygonal.motor.geom.math.Vec2;

using Lambda;

using org.transition9.geom.CircleUtil;
using org.transition9.geom.PolygonTools;
using org.transition9.geom.Vec2Tools;

class BoundsPolygon extends AbstractBounds<BoundsPolygon>
{
	/** Don't modify this outside of the Bounds.  The cached bounds will be wrong*/   
	public var polygon(get_polygon, null) : org.transition9.geom.Polygon;
	public var offset :Vec2;
	
	public function new (polygon :Polygon)
	{
		super();
		set_polygon(polygon);
	}
	
	function set_polygon (p :Polygon) :Void
	{
		_polygon = p;
		_boundsRect = _polygon.boundingBox;
		_boundsCircle = _polygon.boundingCircle;
		this.center = center;
	}

	override function get_center ():Vec2
	{
		return _boundsCircle.center.clone();
	}
	
	override function set_center (val :Vec2) :Vec2
	{
		// var c = get_center();
		// var dx = val.x - c.x;
		// var dy = val.y - c.y;
		// _polygon.translateLocal(dx, dy);
		_polygon.center = val.clone();
		_boundsCircle.center = val.clone();
		// _boundsCircle.center.x += dx;
		// _boundsCircle.center.y += dy;
		_boundsRect.center = val.clone();//x = val.x - _boundsRect.width / 2 - offset.x;
		// _boundsRect.y = val.y - _boundsRect.height / 2 - offset.y;
		// _boundsRect.x += dx;
		// _boundsRect.y += dy;
		return val;
	}

	function get_polygon () :org.transition9.geom.Polygon
	{
		return _polygon;
	}

	override public function containsBounds (b :IBounds<Dynamic>) :Bool
	{
		throw "Not implemented";
		// if (Std.is(b, BoundsPoint)) {
		//	 return contains(cast(b, BoundsPoint).center);
		// } else if (Std.is(b, BoundsLine)) {
		//	 var line = cast(b, BoundsLine).lineSegment;
		//	 return contains(line.a) && contains(line.b);
		// } else if (Std.is(b, BoundsPolygon)) {
		//	 return polygon.contains(cast(b, BoundsPolygon).polygon);
		// }
		// throw "containsBounds not implemented between " + ReflectUtil.tinyClassName(this) +
		//	 " and " + ReflectUtil.tinyClassName(b);
		return false;
	}

	public function toString () :String
	{
		return _polygon.toString();
	}

	override public function clone () :BoundsPolygon
	{
		return new BoundsPolygon(_polygon.clone());
	}

	override public function containsPoint (v :Vec2) :Bool
	{
		if (!_polygon.boundingBox.contains(v.x, v.y)) {
			return false;
		}
		return _polygon.isPointInside(v) || _polygon.isPointOnEdge(v);
	}

	override public function distance (b :IBounds<Dynamic>) :Float
	{
		if (Std.is(b, BoundsForwarding)) {
			return distance(cast(b, BoundsForwarding<Dynamic>).getForwarded()); 
		}
		
		if (Std.is(b, BoundsPoint)) {
			return BoundsUtil.distancePointPolygon(cast(b), this);
		} else if (Std.is(b, BoundsPolygon)) {
			return BoundsUtil.distancePolygonPolygon(cast(b), this);
		} 
		// else if (Std.is( b, BoundsLine)) {
		//	 return _polygon.distanceToLine(cast(b, BoundsLine).lineSegment);
		// }
		throw "Not implemented between " + ReflectUtil.getClassName(this) + " and " + ReflectUtil.getClassName(b);
		return Math.NaN;
	}
	
	override public function isWithinDistance(b :IBounds<Dynamic>, d :Float) :Bool
	{
		if (Std.is(b, BoundsForwarding)) {
			return isWithinDistance(cast(b, BoundsForwarding<Dynamic>).getForwarded(), d); 
		}
		
		if (Std.is(b, BoundsPoint)) {
			return BoundsUtil.isWithinDistancePointPolygon(cast(b), this, d);
		} else if (Std.is(b, BoundsPolygon)) {
			return BoundsUtil.isWithinDistancePolygonPolygon(cast(b), this, d);
		}
		// else if (Std.is( b, BoundsLine)) {
		//	 return _polygon.distanceToLine(cast(b, BoundsLine).lineSegment);
		// }
		throw "Not implemented between " + ReflectUtil.getClassName(this) + " and " + ReflectUtil.getClassName(b);
		return false;
	}

	override public function distanceToPoint (v :Vec2) :Float
	{
		return _polygon.distToPolygonEdge(v);
	}

	override function get_boundingCircle () :Circle
	{
		return _boundsCircle;
	}
	
	override function get_boundingRect () :Rectangle
	{
		return _boundsRect;
	}

	var _polygon :Polygon;
}
