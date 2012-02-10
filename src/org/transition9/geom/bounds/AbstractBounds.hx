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
import org.transition9.geom.Rectangle;
import org.transition9.geom.bounds.IBounds;

import de.polygonal.core.math.Vec2;

using org.transition9.geom.CircleUtil;
using org.transition9.geom.Vec2Tools;

class AbstractBounds<T>
	implements IBounds<T> 
{
	public var topLeft(get_topLeft, set_topLeft) :Vec2;
	public var center(get_center, set_center) :Vec2;
	public var boundingRect (get_boundingRect, null) :Rectangle;
	public var boundingCircle (get_boundingCircle, null) :Circle;

	public function new ()
	{
		_center = new Vec2();
	}

	function get_center ():Vec2
	{
		return _center;
	}
	
	function set_center (v :Vec2) :Vec2
	{
		throw "Abstract";
		return null;
	}
	
	function get_topLeft () :Vec2
	{
		return cast center.subtract(new Vec2(boundingRect.width / 2, boundingRect.height / 2));
	}
	
	function set_topLeft (val :Vec2) :Vec2
	{
		center = cast val.add(new Vec2(boundingRect.width / 2, boundingRect.height / 2));
		return val;
	}
	
	function get_boundingRect () :Rectangle
	{
		if (_boundsRect == null) {
			_boundsRect = computeBoundingRect();
		}
		return _boundsRect;
	}
	
	function get_boundingCircle () :Circle
	{
		if (_boundsCircle == null) {
			_boundsCircle = get_boundingRect().toCircle();
		}
		return _boundsCircle;
	}
	
	function computeBoundingRect () :Rectangle
	{
		throw "Abstract";
		return null;
	}

	public function clone () :T
	{
		throw "Abstract";
		return null;
	}

	public function containsPoint (v :Vec2) :Bool
	{
		throw "Abstract";
		return false;
	}
	
	public function containsBounds (b :IBounds<Dynamic>) :Bool
	{
		throw "Abstract";
		return false;
	}

	public function distance (b :IBounds<Dynamic>) :Float
	{
		throw "Abstract";
		return 0;
	}
	
	public function isWithinDistance(b :IBounds<Dynamic>, d :Float) :Bool
	{
		throw "Abstract";
		return false;
	}

	public function distanceToPoint (p :Vec2) :Float
	{
		throw "Abstract";
		return 0;
	}

	public function getBoundedPoint (v :Vec2, ?bounded :Vec2) :Vec2
	{
		throw "Abstract";
		return null;
	}

	public function getBoundedPointFromMove (originX :Float, originY :Float, targetX :Float, targetY :Float, ?bounded :Vec2) :Vec2
	{
		throw "Abstract";
		return null;
	}
	
	function clearCache () :Void
	{
		_center = null;
		_boundsRect = null;
		_boundsCircle = null;
	}
	
	var _center :Vec2;
	var _boundsRect :Rectangle;
	var _boundsCircle :Circle;

}
