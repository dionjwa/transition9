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
import org.transition9.geom.Rectangle;
import org.transition9.geom.bounds.AbstractBounds;
import org.transition9.geom.bounds.BoundsPoint;
import org.transition9.geom.bounds.BoundsPolygon;
import org.transition9.geom.bounds.IBounds;
import org.transition9.rtti.ReflectUtil;

import de.polygonal.core.math.Vec2;

class BoundsLine extends AbstractBounds<BoundsLine>
	// implements IBounds<BoundsLine> 
{
	// public var center(get_center, set_center) : Vec2;
	// public var boundingRect (get_boundingRect, null) :Rectangle;
	// public var boundingCircle (get_boundingCircle, null) :Circle;
	public var lineSegment(getLineSegment, null) : LineSegment;

	public function new (x1 :Float, y1 :Float, x2 :Float, y2 :Float)
	{
		super();
		_p1 = new Vec2(x1, y1);
		_p2 = new Vec2(x2, y2);
		_lineSegment = new LineSegment(_p1, _p2);
	}

	function getLineSegment ():LineSegment
	{
		return _lineSegment;
	}

	override function get_center ():Vec2
	{
		return Vec2Tools.interpolate(_p1, _p2, 0.5);
	}
	
	override function computeBoundingRect () :Rectangle
	{
		return new Rectangle(Math.min(_p1.x, _p2.x), Math.min(_p1.y, _p2.y), Math.abs(_p1.x - _p2.x), Math.abs(_p1.y - _p2.y));
	}

	public function toString () :String
	{
		return _lineSegment.toString();
		// return StringUtil.simpleToString(this, [ "lineSegment" ]);
	}

	// public function boundingRect () :Rectangle
	// {
	//	 var minX = Math.min(_p1.x, _p2.x);
	//	 var maxX = Math.max(_p1.x, _p2.x);
	//	 var minY = Math.min(_p1.y, _p2.y);
	//	 var maxY = Math.max(_p1.y, _p2.y);
	//	 return new Rectangle(minX, minY, maxX - minX, maxY - minY);
	// }

	override public function clone () :BoundsLine
	{
		return new BoundsLine(_p1.x, _p1.y, _p2.x, _p2.y);
	}

	override public function containsPoint (v :Vec2) :Bool
	{
		return LineSegment.distToLineSegment(_p1, _p2, v) == 0;
	}

	// public function convertToGlobal (localDisp :DisplayObject) :Bounds<BoundsLine>
	// {
	//	 var p1:Vec2 = Vec2.toVec2(localDisp.localToGlobal(_p1.toPoint()));
	//	 var p2:Vec2 = Vec2.toVec2(localDisp.localToGlobal(_p2.toPoint()));
	//	 return new BoundsLine(p1.x, p1.y, p2.x, p2.y);
	// }

	//TODO: move this to a util class
	#if (flash || cpp)
	public function debugDraw (s :flash.display.Sprite) :Void
	{
		s.graphics.lineStyle(2, 0xff0000);
		s.graphics.moveTo(_p1.x, _p1.y);
		s.graphics.lineTo(_p2.x, _p2.y);
	}
	#end

	override public function distance (b :IBounds<Dynamic>) :Float
	{
		return 0;
		// if (Std.is( b, BoundsPoint)) {
		//	 return distanceToPoint(BoundsPoint(b).point);
		// } else if (Std.is( b, BoundsPolygon)) {
		//	 return _lineSegment.dist(BoundsPolygon(b).polygon.center);
		// } else if (Std.is( b, BoundsLine)) {
		//	 return BoundsLine(b)._lineSegment.distanceToLine(_lineSegment);
		// }
		// throw "Distance not implemented between " + ReflectUtil.tinyClassName(this) +
		//	 " and " + ReflectUtil.tinyClassName(b);

	}

	override public function distanceToPoint (p :Vec2) :Float
	{
		return LineSegment.distToLineSegment(_p1, _p2, p);
	}

	override public function getBoundedPoint (v :Vec2, ?bounded :Vec2) :Vec2
	{
		if (bounded != null) {
			var p = LineSegment.closestPoint(_p1, _p2, v);
			bounded.x = p.x;
			bounded.y = p.y;
			return bounded;
		} else {
			return LineSegment.closestPoint(_p1, _p2, v);
		}
	}

	override public function getBoundedPointFromMove (originX :Float, originY :Float, targetX :Float, targetY :Float, ?bounded :Vec2) :Vec2
	{
		return getBoundedPoint(new Vec2(targetX, targetY));
	}

	var _lineSegment:LineSegment;
	var _p1:Vec2;
	var _p2:Vec2;
}
