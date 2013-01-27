/*******************************************************************************
 * Hydrax: haXe port of the PushButton Engine
 * Copyright (C) 2010 Dion Amago
 * For more information see http://github.com/dionjwa/Hydrax
 *
 * This file is licensed under the terms of the MIT license, which is included
 * in the License.html file at the root directory of this SDK.
 ******************************************************************************/
package transition9.geom;

import transition9.geom.LineSegment;

import de.polygonal.core.math.Vec2;

using transition9.geom.Vec2Tools;

class LineSegmentTools
{

	public static function getMidpoint (line :LineSegment) :Vec2
	{
		return line.a.getMidpoint(line.b);
	}
}

