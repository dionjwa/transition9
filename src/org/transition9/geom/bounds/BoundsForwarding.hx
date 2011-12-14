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
import org.transition9.geom.Vector2;
import org.transition9.geom.bounds.AbstractBounds;
import org.transition9.geom.bounds.IBounds;

import de.polygonal.motor2.geom.math.XY;

using org.transition9.geom.CircleUtil;

class BoundsForwarding<T> extends AbstractBounds<T>
{
	public function new (forwadingBounds :Void->AbstractBounds<Dynamic>)
	{
		super();
		_forwarding = forwadingBounds;
	}

	override function get_center ():XY
	{
		return _forwarding().get_center();
	}
	
	override function set_center (v :XY) :XY
	{
		_forwarding().set_center(v);
		return v;
	}
	
	override function get_boundingRect () :Rectangle
	{
		return _forwarding().get_boundingRect();
	}
	
	override function get_boundingCircle () :Circle
	{
		return _forwarding().get_boundingCircle();
	}
	
	override function computeBoundingRect () :Rectangle
	{
		return _forwarding().computeBoundingRect();
	}

	override public function containsPoint (v :XY) :Bool
	{
		return _forwarding().containsPoint(v);
	}
	
	override public function containsBounds (b :IBounds<Dynamic>) :Bool
	{
		return _forwarding().containsBounds(b);
	}

	override public function distance (b :IBounds<Dynamic>) :Float
	{
		return _forwarding().distance(b);
	}
	
	override public function isWithinDistance(b :IBounds<Dynamic>, d :Float) :Bool
	{
		return _forwarding().isWithinDistance(b, d);
	}

	override public function distanceToPoint (p :XY) :Float
	{
		return _forwarding().distanceToPoint(p);
	}
	
	public function getForwarded () :IBounds<Dynamic>
	{
		return _forwarding();
	}

	var _forwarding :Void->AbstractBounds<Dynamic>;
}
