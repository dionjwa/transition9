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
import org.transition9.util.Cloneable;

import de.polygonal.motor.geom.math.Vec2;

interface IBounds<T> 
	implements Cloneable<T>//, implements ISpatialObject2D
{
	public var center(get_center, set_center) : Vec2;
	public var topLeft(get_topLeft, set_topLeft) : Vec2;
	// public var boundingRect (get_boundingRect, null) :Rectangle;
	public var boundingCircle (get_boundingCircle, null) :Circle;

	public function distance (b :IBounds<Dynamic>) :Float;
	public function containsBounds (b :IBounds<Dynamic>) :Bool;
	public function isWithinDistance(b :IBounds<Dynamic>, d :Float) :Bool;
	
	public function containsPoint (v :Vec2) :Bool;
	// public function distanceToPoint (v :Vec2) :Float;
	// public function getBoundedPoint (v :Vec2, ?v :Vec2) :Vec2;
	// public function getBoundedPointFromMove (originX :Float, originY :Float, targetX :Float, targetY :Float, ?v :Vec2) :Vec2;
}
