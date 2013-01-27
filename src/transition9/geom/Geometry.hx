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

class Geometry
{
	inline public static var PI_HALF:Float = Math.PI / 2;
	inline public static var PI_2:Float = Math.PI * 2;
	inline public static var SQRT2 :Float = Math.sqrt(2);
	inline public static var DEG_TO_RAD :Float = (Math.PI / 180);
	inline public static var RAD_TO_DEG :Float = (180 / Math.PI);
	
	inline public static function distance (x1 :Float, y1 :Float, x2 :Float, y2 :Float) :Float
	{
		return Math.sqrt(distanceSq(x1, y1, x2, y2));
	}
	
	inline public static function distanceSq (x1 :Float, y1 :Float, x2 :Float, y2 :Float) :Float
	{
		return  (x2 - x1) * (x2 - x1) + (y2 - y1) * (y2 - y1);
	}
	
	/**
	 * Determines which direction a point should rotate to match rotation the quickest
	 * @param objectRotationRadians The object you would like to rotate
	 * @param radianBetween the angle from the object to the point you want to rotate to
	 * @return -1 if left, 0 if facing, 1 if right
	 *
	 */
	public static function getSmallestRotationDirection (objectRotationRadians :Float,
		radianBetween :Float, ?errorRadians :Int = 0) :Int
	{
		objectRotationRadians = simplifyRadian(objectRotationRadians);
		radianBetween = simplifyRadian(radianBetween);

		radianBetween += -objectRotationRadians;
		radianBetween = simplifyRadian(radianBetween);
		objectRotationRadians = 0;
		if (radianBetween < -errorRadians) {
			return -1;
		} else if (radianBetween > errorRadians) {
			return 1;
		}
		return 0;
	}
	
	public static function simplifyRadian (radian :Float) :Float
	{
		if (radian > Math.PI || radian < -Math.PI) {
			var newRadian:Float;
			newRadian = radian - (radian / (Math.PI * 2)) * (Math.PI * 2);
			if (radian > 0) {
				if (newRadian < Math.PI) {
					return newRadian;
				} else {
					newRadian = -(Math.PI * 2 - newRadian);
					return newRadian;
				}
			} else {
				if (newRadian > -Math.PI) {
					return newRadian;
				} else {
					newRadian = ((Math.PI * 2) + newRadian);
					return newRadian;
				}
			}
		}
		return radian;
	}
	
	// public static function rand (min :Int, max :Int) :Int
	// {
	// 	return min + Math.floor(Math.random() * (max - min + 1));
	// }

	/**
	 * Converts degrees to radians.
	 */
	inline public static function toRadians (degrees :Float) :Float
	{
		return degrees * Math.PI / 180;
	}

	/**
	 * Normalizes an angle in radians to occupy the [0, 2pi) range.
	 */
	inline public static function normalizeRadians (radians :Float) :Float
	{
		var twopi = Math.PI * 2;
		var norm = radians % twopi;
		return (norm >= 0) ? norm : (norm + twopi);
	}

	/**
	 * Converts radians to degrees.
	 */
	inline public static function toDegrees (radians :Float) :Float
	{
		return radians * 180 / Math.PI;
	}

	/**
	 * Normalizes an angle in degrees to occupy the [0, 360) range.
	 */
	inline public static function normalizeDegrees (degrees :Float) :Float
	{
		var norm = degrees % 360;
		return (norm >= 0) ? norm : (norm + 360);
	}
	
	/**
	 * Returns the closest point to A from a list of points.
	 * @param A the point to check against.
	 * @param otherPoints an arbitrary number of other points.
	 * @return the closest point to A.
	 *
	 */
	public static function closestPoint(A :Vec2, otherPoints:Array<Dynamic>):Vec2
	{
		var closestDistance = Math.POSITIVE_INFINITY;
		var closestPoint :Vec2 = null;

		for (v in otherPoints)
		{
			var d = Vec2Tools.distanceSq(v, A);
			if(d < closestDistance) {
				closestDistance = d;
				closestPoint = v;
			}
		}
		return closestPoint;
	}

	/**
	 * Determines how far along a ray an intersection occurs.
	 * @param rayOrigin start point of the ray
	 * @param rayHeading vector rotation heading of the ray
	 * @param planePoint any point on the plane
	 * @param planeNormal the normal vector of the plane
	 * @return returns negative if the ray is parallel, else the distance along the ray to the intersection.
	 *
	 */
	public static function distToRayPlaneIntersect(rayOrigin:Vec2, rayHeading:Vec2, planePoint:Vec2, planeNormal:Vec2):Float{
		var d		= -planeNormal.dot(planePoint);
		var numer	= planeNormal.dot(rayOrigin) + d;
		var denom	= planeNormal.dot(rayHeading);

		if ((denom < 0.00001) && (denom > -0.00001)) return -1; //parallel

		return -(numer / denom);
	}

	/**
	 * Determines where a point is in relation to a plane
	 * @param point the point to check
	 * @param pointOnPlane any point on the plane
	 * @param planeNormal the vector normal of the plane
	 * @return -1 if point is behind plane. 0 if point is on plane. 1 if point is in front of plane.
	 *
	 */
	public static function whereIsPoint (point :Vec2, pointOnPlane :Vec2,
		planeNormal :Vec2) :Int
	{
		var dir = pointOnPlane.subtract(point);

		var d = dir.dot(planeNormal);

		if(d < -0.00001) return 1;

		if(d > 0.00001) return -1;

		return 0;
	}

	/**
	 * Determines the distance to the first intersecting point of a ray / circle collision
	 * @param rayOrigin the start point of the ray
	 * @param rayHeading the rotation vector of the ray
	 * @param circleCenter the middle point of the circle
	 * @param radius radius of the circle
	 * @return returns the distance, or -1 if there is no intersection
	 *
	 */
	public static function getRayCircleIntersect (rayOrigin :Vec2, rayHeading :Vec2,
		circleCenter :Vec2, radius :Float) :Float
	{
		var toCircle	= circleCenter.subtract(rayOrigin);
		var length	   = toCircle.getLength();
		var v			= toCircle.dot(rayHeading);
		var d			= radius * radius - (length * length - v * v);

		if (d < 0) return (-1);

		return (v - Math.sqrt(d));
	}

	/**
	 * Same as 'getRayCircleIntersect' except this returns IF there is an intersect to save time on sqrt check
	 * @param rayOrigin the start point of the ray
	 * @param rayHeading the rotation vector of the ray
	 * @param circleCenter the middle point of the circle
	 * @param radius radius of the circle
	 * @return returns true if intersecting else false
	 *
	 */
	public static function doesRayIntersectCircle (rayOrigin :Vec2, rayHeading :Vec2,
		circleCenter :Vec2, radius :Float) :Bool
	{
		var toCircle = circleCenter.subtract(rayOrigin);
		var length		 = toCircle.getLength();
		var v			= toCircle.dot(rayHeading);
		var d			= radius * radius - (length * length - v * v);

		return (d < 0);
	}

	/**
	 * Given a point 'P' and a circle of radius 'R' centered at 'C' this function
	 * determines the two points on the circle that intersect with the tangents
	 * from P to the circle. The points will be given through the
	 * 'tangent1' and 'tangent2' variables.
	 * @param C point circle is centered on
	 * @param R radius of the circle
	 * @param P point to check
	 * @param tangent1 the first tangent to be constructed
	 * @param tangent2 the 2nd tangent to be constructed
	 * @return false if 'P' is within the circle
	 *
	 */
	public static function getTangentPoints (C :Vec2, R :Float, P :Vec2, tangent1 :Vec2,
		tangent2 :Vec2) :Bool
	{
		var PmC = P.subtract(C);
		var sqrLen = PmC.lengthSq();
		var rSqr = R*R;
		if(sqrLen <= rSqr) {
			return false;
		}

		var invSqrLen	= 1 / sqrLen;
		var root			= Math.sqrt(Math.abs(sqrLen - rSqr));

		tangent1.x = C.x + R*(R*PmC.x - PmC.y*root)*invSqrLen;
		tangent1.y = C.y + R*(R*PmC.y - PmC.x*root)*invSqrLen;
		tangent2.x = C.x + R*(R*PmC.x - PmC.y*root)*invSqrLen;
		tangent2.y = C.y + R*(R*PmC.y - PmC.x*root)*invSqrLen;

		return true;
	}

//		/**
//		 * Given a line segment AB and a point P, this function calculates the
//		 * perpendicular distance between them.
//		 * @param A the first point of the line segment
//		 * @param B the 2nd point of the line segment
//		 * @param P the point to check against
//		 * @return the distance from P -> AB
//		 *
//		 */
//		public static function distToLineSegment (A :Vec2, B :Vec2, P :Vec2) :Number
//		{
//			return Math.sqrt(distToLineSegmentSq(A, b, P));
//		}

//	/**
//	 * Given a line segment AB and a point P, this function calculates the
//	 * perpendicular distance [Squared] between them to avoid the sqrt.
//	 * @param A the first point of the line segment
//	 * @param B the 2nd point of the line segment
//	 * @param P the point to check against
//	 * @return the distance from P -> AB
//	 *
//	 */
//	public static function distToLineSegmentSq (A:Vec2, B:Vec2, P:Vec2) :Number
//	{
//		var dotA:Number = (P.x - A.x)*(B.x - A.x) + (P.y - A.y)*(B.y - A.y);
//
//		if (dotA <= 0) returnVec2Tools.distanceSq(A, P);
//
//		var dotB:Number = (P.x - B.x)*(A.x - B.x) + (P.y - B.y)*(A.y - B.y);
//
//		if (dotB <= 0) returnVec2Tools.distanceSq(B, P);
//
//		// .. Find closest point to P on line segment ...
//		var point:Vec2 = B.subtract(A);
//		point.scaleLocal(dotA);
//		point.scaleLocal(1/(dotA+dotB));
//		point.addLocal(A);
//
//		returnVec2Tools.distanceSq(P, point);
//	}

//	public static function distToPolygonEdge(P :Vec2, polygon :Array) :Number
//	{
//		var minDistance :Number = Math.POSITIVE_INFINITY;
//		var distance :Number;
//		for(var i :int = 0; i < polygon.length - 1; i++) {
//			distance = distToLineSegment(polygon[i], polygon[i + 1], P);
//			minDistance = Math.min(minDistance, distance);
//		}
//		return minDistance;
//	}
//
//	public static function normalOfClosestPolygonEdge(P :Vec2, polygon :Array) :Number
//	{
//		var minDistance :Number = Math.POSITIVE_INFINITY;
//		var minDistanceVertexIndex1 :int = 0;
//		var minDistanceVertexIndex2 :int = 0;
//		var distance :Number;
//		for(var i :int = 0; i < polygon.length - 1; i++) {
//			distance = distToLineSegment(polygon[i], polygon[i + 1], P);
//			if(distance < minDistance) {
//				minDistanceVertexIndex1 = i;
//				minDistanceVertexIndex2 = i + 1;
//				minDistance = distance;
//			}
//		}
//		distance = distToLineSegment(polygon[0], polygon[polygon.length - 1], P);
//		if(distance < minDistance) {
//			minDistanceVertexIndex1 = 0;
//			minDistanceVertexIndex2 = polygon.length - 1;
//			minDistance = distance;
//		}
//		var segmentAngle :Number = angleFrom(polygon[minDistanceVertexIndex1].x, polygon[minDistanceVertexIndex1].y, polygon[minDistanceVertexIndex2].x, polygon[minDistanceVertexIndex2].y);
//		segmentAngle = Geometry.normalizeRadians(segmentAngle - Math.PI / 2);
//		return segmentAngle;
//	}

//	public static function getAllEdgeMidpointsAsPolygon(polygon :Array) :Array
//	{
//		var midpoints :Array = new Array();
//		for(var i :int = 0; i < polygon.length - 1; i++) {
//			midpoints.push(Vec2.interpolate(polygon[i], polygon[i + 1], 0.5));
//		}
//		return midpoints;
//	}

//	public static function polygonFromBoundingBox(rect :Rectangle) :Array
//	{
//		var p :Array = new Array();
//		p.push(new Vec2(rect.x, rect.y));
//		p.push(new Vec2(rect.x + rect.width, rect.y));
//		p.push(new Vec2(rect.x + rect.width, rect.y + rect.height));
//		p.push(new Vec2(rect.x, rect.y  + rect.height));
//		p.push(p[0]);
//		return p;
//	}
//
//	public static function boundingBoxFromPolygon(poly :Array) :Rectangle
//	{
//		var width :Number = width(poly);
//		var height :Number = height(poly);
//		var minX :Number = minX(poly);
//		var minY :Number = minY(poly);
//		var rect :Rectangle = new Rectangle();
//
//		rect.x = minX;
//		rect.y = minY;
//		rect.width = width;
//		rect.height = height;
//
//		return rect;
//	}

//	/**
//	* Pad polygon, i.e. enlarge by <padding>.  This ensures that
//	* a big fat pathfinder will not hit the walls.  This can be a negative number to unpad.
//	*/
//	public static function padPolygon(polygon :Array, padding :Number) :void
//	{
//		log.info("padPolygon", "polygon", polygon, "padding", padding);
//		var ii :int;
//
//		//Create an array of line segments
//		var sides :Array = [];
//		for(ii = 0; ii < polygon.length - 1; ii++) {
//			sides.push([Vec2(polygon[ii]).clone(), Vec2(polygon[ii + 1]).clone()]);
//		}
//		sides.push([Vec2(polygon[polygon.length - 1]).clone(), Vec2(polygon[0]).clone()]);
//
//		var side :Array;
//		for each (side in sides) {
//			var v1 :Vec2 = side[0] as Vec2;
//			var v2 :Vec2 = side[1] as Vec2;
//			var normal :Number = Vec2Tools.simplifyRadian(angleFromVectors(v1, v2) + Math.PI / 2);
//			var transform :Vec2 = Vec2.fromAngle(normal, padding);
//			v1.addLocal(transform);
//			v2.addLocal(transform);
//		}
//
////		function computeInter
////
////		for (ii = 0; ii < sides.length; ++ii) {
////
////		}
//
//
//
//
//
//
//
//
//
//		var center :Vec2 = getPolygonCenter(polygon);
//		//Go through all edges.
//		var anglesToProjectAlong :Array = [];
//		for(var k :int = 0; k < polygon.length; k++) {
//
////			if (k == polygon.length - 1 && polygon[0] == polygon[polygon.length - 1]) {
////				continue;
////			}
//
//			var v1 :Vec2 = polygon[k] as Vec2;
//			var v2 :Vec2 = k < polygon.length - 1 ? polygon[k + 1] as Vec2 : polygon[0] as Vec2;
//			var v3 :Vec2 = k > 0 ? polygon[k - 1] as Vec2 : polygon[polygon.length - 1] as Vec2;
//
//			var anglev1v2 :Number = Geometry.angleFromVectors(v1, v2);
//			var angleFromP1 :Number =
//				Vec2Tools.simplifyRadian(Math.PI + anglev1v2 + differenceAngles(anglev1v2, Geometry.angleFromVectors(v1, v3)) / 2);
//			anglesToProjectAlong.push(angleFromP1);
//
////			padEdge(polygon[k], polygon[ k + 1 ], center);
//
//
//		}
//
//		for (k = 0; k < anglesToProjectAlong.length; ++k) {
//			trace("adding to", polygon[k],  Vec2.fromAngle(anglesToProjectAlong[k], padding * Math.SQRT2), ", length=" + Vec2.fromAngle(anglesToProjectAlong[k], padding * Math.SQRT2).length);
//			Vec2(polygon[k]).addLocal(Vec2.fromAngle(anglesToProjectAlong[k], padding * Math.SQRT2));
//		}
//
////
////		function padEdge(v1 :Vec2, v2 :Vec2, center :Vec2) :void
////		{
////			//Get the normal
////			var normalAngle :Number = Geometry.normalizeRadians(angleFrom(v1.x, v1.y, v2.x, v2.y) + Math.PI / 2);
////			//Create the transform vector from the normal angle and the padding
////			var transform :Vec2 = Vec2.fromAngle(normalAngle);
////			//Check if the angle is pointing the wrong way (to the center instead of away)
////			var middlePoint :Vec2 = new Vec2(v1.x + (v2.x - v1.x) / 2, v1.y + (v2.y - v1.y) / 2);
////
////			if(distance(center, middlePoint) > distance(center, middlePoint.clone().addLocal(transform))) {
////				transform = Vec2.fromAngle(Geometry.normalizeRadians(normalAngle + Math.PI));
////			}
////			transform.scaleLocal(padding);
////			//Change the vertex positions
////			v1.addLocal(transform);
////			v2.addLocal(transform);
////		}
//	}

//	/**
//	 * Given 2 lines in 2D space AB, CD this returns true if an intersection occurs
//	 * @param A Start point of line 1.
//	 * @param B End point of line 1.
//	 * @param C Start point of line 2.
//	 * @param D End point of line 2.
//	 * @return true if intersection occurs
//	 *
//	 */
//	public static function isLineIntersecting (A:Vec2, B:Vec2, C:Vec2, D:Vec2):Boolean{
//		var rTop:Number = (A.y-C.y)*(D.x-C.x)-(A.x-C.x)*(D.y-C.y);
//		var sTop:Number = (A.y-C.y)*(B.x-A.x)-(A.x-C.x)*(B.y-A.y);
//		var bot:Number	 = (B.x-A.x)*(D.y-C.y)-(B.y-A.y)*(D.x-C.x);
//
//		if(bot == 0) return false; //parallel
//
//		var invBot:Number	 = 1 / bot;
//		var r:Number		= rTop * invBot;
//		var s:Number		= sTop * invBot;
//
//		if((r > 0) && (r < 1) && (s > 0) && (s < 1)) return true;
//
//		return false;
//	}

//	//---------------------------------------------------------------
//	//Checks for intersection of Segment if as_seg is true.
//	//Somewhat more reliabel than the above
//	//Checks for intersection of Line if as_seg is false.
//	//Return intersection of Segment "AB" and Segment "EF" as a Point
//	//Return null if there is no intersection
//	//---------------------------------------------------------------
//	protected function lineIntersectLine(A:Vec2,B:Vec2,E:Vec2,F:Vec2,as_seg:Boolean=true):Vec2
//	{
//		var ip:Vec2;
//		var a1:Number;
//		var a2:Number;
//		var b1:Number;
//		var b2:Number;
//		var c1:Number;
//		var c2:Number;
//
//		a1= B.y-A.y;
//		b1= A.x-B.x;
//		c1= B.x*A.y - A.x*B.y;
//		a2= F.y-E.y;
//		b2= E.x-F.x;
//		c2= F.x*E.y - E.x*F.y;
//
//		var denom:Number=a1*b2 - a2*b1;
//		if(denom == 0){
//			return null;
//		}
//		ip=new Vec2();
//		ip.x=(b1*c2 - b2*c1)/denom;
//		ip.y=(a2*c1 - a1*c2)/denom;
//
//		//---------------------------------------------------
//		//Do checks to see if intersection to endpoints
//		//distance is longer than actual Segments.
//		//Return null if it is with any.
//		//---------------------------------------------------
//		if(as_seg){
//			if(distance(ip,B) > distance(A,B)){
//				return null;
//			}
//			if(distance(ip,A) > distance(A,B)){
//				return null;
//			}
//
//			if(distance(ip,F) > distance(E,F)){
//				return null;
//			}
//			if(distance(ip,E) > distance(E,F)){
//				return null;
//			}
//		}
//		return ip;
//	}

//	/**
//	 * Returns true if any points are an edge of the polygon.
//	 * @param P1 Array of Vec2 points, with the first point also last in the array.
//	 */
//	public static function isLineOnPolygonEdge(P1 :Vec2, P2 :Vec2, polygon :Array) :Boolean
//	{
//		for(var k :int = 0; k < polygon.length - 1; k++) {
//
//			var p1 :Vec2 = polygon[k] as Vec2;
//			var p2 :Vec2 = polygon[k + 1] as Vec2;
//
//			var distancep1ToEdge :Number = distToLineSegment(polygon[k], polygon[k + 1], P1);
//			var distancep2ToEdge :Number = distToLineSegment(polygon[k], polygon[k + 1], P2);
//
//			if(distancep1ToEdge == 0 && distancep2ToEdge == 0) {
//				return true;
//			}
//		}
//
//		return false;
//	}

//	/**
//	 * Returns true if any points are an edge of the polygon.
//	 * @param P1 Array of Vec2 points, with the first point also last in the array.
//	 */
//	public static function numberVerticesOfPolygonTouchingLine(P1 :Vec2, P2 :Vec2, polygon :Array) :int
//	{
//		var vertexCount :int = 0;
//		for(var k :int = 0; k < polygon.length - 1; k++) {
//
//			var v :Vec2 = polygon[k] as Vec2;
//
//			if(distToLineSegment(P1, P2, polygon[k]) == 0) {
//				vertexCount++;
//			}
//		}
//
//		return vertexCount;
//	}

//	/**
//	 * Returns true if any points are an edge of the polygon.
//	 * @param P1 Array of Vec2 points, with the first point also last in the array.
//	 */
//	public static function getVerticesOfPolygonTouchingLine(P1 :Vec2, P2 :Vec2, polygon :Array) :Array
//	{
//		var vertices :Array = new Array();
//		for(var k :int = 0; k < polygon.length - 1; k++) {
//
//			var v :Vec2 = polygon[k] as Vec2;
//
//			if(distToLineSegment(P1, P2, polygon[k]) == 0) {
//				vertices.push(v);
//			}
//		}
//
//		return vertices;
//	}

//	/**
//	 * Given 2 lines in 2D space AB, CD this returns true if an intersection occurs
//	 * @param A Start point of line 1.
//	 * @param B End point of line 1.
//	 * @param C Start point of line 2.
//	 * @param D End point of line 2.
//	 * @param point A Vector which is set to the point of intersection if one does occur.
//	 * @return -1 if no intersection occurs, else returns the distance
//	 *
//	 */
//	public static function lineIntersection(A:Vec2, B :Vec2, C :Vec2, D :Vec2, point :Vec2):Number{
//		var rTop:Number = (A.y-C.y)*(D.x-C.x)-(A.x-C.x)*(D.y-C.y);
//		var sTop:Number = (A.y-C.y)*(B.x-A.x)-(A.x-C.x)*(B.y-A.y);
//		var rBot:Number = (B.x-A.x)*(D.y-C.y)-(B.y-A.y)*(D.x-C.x);
//		var sBot:Number = (B.x-A.x)*(B.y-A.y)-(B.y-A.y)*(B.x-A.x);
//
//		if((rBot == 0) || (sBot == 0)){
//			//lines are parallel
//			return -1;
//		}
//
//		var r:Number = rTop/rBot;
//		var s:Number = sTop/sBot;
//
//		if((r>0) && (r<1) && (s>0) && (s<1)){
//
//			//A + r * (B - A)
//			point = B.subtract(A);
//			point.scaleLocal(r);
//			point.addLocal(A);
//
//			return distance(A, B) * r;
//		} else {
//			return -1;
//		}
//	}

//
//	//---------------------------------------------------------------
//	//Checks for intersection of Segment if as_seg is true.
//	//Checks for intersection of Line if as_seg is false.
//	//Return intersection of Segment "AB" and Segment "EF" as a Point
//	//Return null if there is no intersection
//	//Replacement for lineIntersection, which does not work
//	//---------------------------------------------------------------
//	public static function lineIntersectLine(A:Vec2,B:Vec2,E:Vec2,F:Vec2,as_seg:Boolean=true):Vec2
//	{
//		var ip:Vec2;
//		var a1:Number;
//		var a2:Number;
//		var b1:Number;
//		var b2:Number;
//		var c1:Number;
//		var c2:Number;
//
//		a1= B.y-A.y;
//		b1= A.x-B.x;
//		c1= B.x*A.y - A.x*B.y;
//		a2= F.y-E.y;
//		b2= E.x-F.x;
//		c2= F.x*E.y - E.x*F.y;
//
//		var denom:Number=a1*b2 - a2*b1;
//		if(denom == 0){
//			return null;
//		}
//		ip=new Vec2();
//		ip.x=(b1*c2 - b2*c1)/denom;
//		ip.y=(a2*c1 - a1*c2)/denom;
//
//		//---------------------------------------------------
//		//Do checks to see if intersection to endpoints
//		//distance is longer than actual Segments.
//		//Return null if it is with any.
//		//---------------------------------------------------
//		if(as_seg){
//			if(distance(ip,B) > distance(A,B)){
//				return null;
//			}
//			if(distance(ip,A) > distance(A,B)){
//				return null;
//			}
//
//			if(distance(ip,F) > distance(E,F)){
//				return null;
//			}
//			if(distance(ip,E) > distance(E,F)){
//				return null;
//			}
//		}
//		return ip;
//	}
//
//	/**
//	 * Tests two polygons for intersection. *does not check for enclosure*
//	 * @param object1 an array of Vector points comprising polygon 1
//	 * @param object2 an array of Vector points comprising polygon 2
//	 * @return true is intersection occurs
//	 *
//	 */
//	public static function isObjectOverlapping(object1:Array, object2:Array):Boolean{
//		for (var i:int=0; i < object1.length; i++){
//			for (var j:int=0; j < object2.length; j++){
//				if(isLineIntersecting(object2[j],object2[j+1],object1[i],object1[i+1])) return true;
//			}
//		}
//		return false;
//	}

//	/**
//	 * Tests a line segment for collision against a polygon *does not check for enclosure*
//	 * @param A The start point of the line segment.
//	 * @param B The end point of the line segment.
//	 * @param object An array of vector points comprising the polygon.  The first point must be
//	 *  also in the last position.
//	 * @return true if intersection occurs
//	 *
//	 */
//	public static function isLineIntersectingPolygon(A:Vec2, B:Vec2, object:Array):Boolean{
//		for (var i:int=0; i<object.length - 1; i++){
//			if(isLineIntersecting(A,B,object[i],object[i+1])) return true;
//		}
//		if(isLineIntersecting(A,B,object[object.length - 1],object[0])) return true;
//		return false;
//	}

//	/**
//	 * Tests a line segment for collision or enclosure against a polygon.
//	 * @param A The start point of the line segment.
//	 * @param B The end point of the line segment.
//	 * @param object An array of vector points comprising the polygon.  The first point must be
//	 *  also in the last position.
//	 * @return true if intersection or enclosure occurs
//	 *
//	 */
//	public static function isSegmentOverlappingPolygon (A :Vec2, B :Vec2, object:Array) :Boolean{
//		for (var i:int=0; i<object.length - 1; i++){
//			if(isLineIntersecting(A,B,object[i],object[i+1])) return true;
//		}
//		if(isLineIntersecting(A,B,object[object.length - 1],object[0])) return true;
//
//		if (isPointInPolygon(A, object) || isPointInPolygon(B, object)) {
//			return true;
//		}
//
//		return false;
//	}

//	public static function getPointsWhereLineIntersectsPolygon(A:Vec2, B:Vec2, polygon:Array):Array
//	{
//		var intersectingPoints :Array = new Array();
//		for (var i:int = 0; i < polygon.length - 1; i++){
//			var point :Vec2 = lineIntersectLine(A, B, polygon[i], polygon[i+1]);
//			if(point != null) {
//				if(!point.equals(A) && !point.equals(B)) {
//					intersectingPoints.push(point);
//				}
//			}
//		}
//		return intersectingPoints;
//	}

	/**
	 * Checks to see if two circles are overlapping
	 * @param circle1 center point of the 1st circle.
	 * @param radius1 radius of circle 1.
	 * @param circle2 center point of the 2nd circle.
	 * @param radius2 radius of circle 2.
	 * @return true if circles are overlapping.
	 *
	 */
	public static function isCircleOverlapping(circle1:Vec2, radius1:Float, circle2:Vec2, radius2:Float):Bool{
		var distSq =Vec2Tools.distanceSq(circle1, circle2);
		 var range = radius1 + radius2;
		 if(distSq < range * range){
			 return true;
		 }
		 return false;
	}

	/**
	 * Given two circles this function calculates the intersection points
	 * of any overlap
	 * @param circle1 center point of the 1st circle.
	 * @param radius1 radius of circle 1.
	 * @param circle2 center point of the 2nd circle.
	 * @param radius2 radius of circle 2.
	 * @param point1 A Vector returned with the 1st point of intersection.
	 * @param point2 A Vector returned with the 2nd point of intersection.
	 * @return false if no overlap is found.
	 *
	 */
	public static function getCircleIntersectionPoints (circle1:Vec2, radius1:Float, circle2:Vec2, radius2:Float, point1:Vec2, point2:Vec2):Bool{
		if(!isCircleOverlapping(circle1,radius1,circle2,radius2)) return false;

		var dist = Vec2Tools.distance(circle1, circle2);

		var a	= (radius1 - radius2 + (dist*dist)) / (2 * dist);
		var b	= (radius2 - radius1 + (dist*dist)) / (2 * dist);

		var p2:Vec2 = new Vec2();
		p2.x = circle1.x + a * (circle2.x - circle1.x) / dist;
		p2.y = circle1.y + a * (circle2.y - circle1.y) / dist;

		var h1 = Math.sqrt(radius1*radius1 - a*a);
		point1.x = p2.x - h1 * (circle2.y - circle1.y) / dist;
		point1.y = p2.y - h1 * (circle2.x - circle1.x) / dist;

		var h2 = Math.sqrt(radius2*radius2 - a*a);
		point2.x = p2.x - h2 * (circle2.y - circle1.y) / dist;
		point2.y = p2.y - h2 * (circle2.x - circle1.x) / dist;

		return true;
	}

	/**
	 * If the two circles overlap, then this function will calculate the area of the union
	 * @param circle1 center point of the 1st circle.
	 * @param radius1 radius of circle 1.
	 * @param circle2 center point of the 2nd circle.
	 * @param radius2 radius of circle 2.
	 * @return the area of the union, or 0 if no overlap occurs
	 *
	 */
	public static function getCircleIntersectionArea(circle1:Vec2, radius1:Float, circle2:Vec2, radius2:Float):Float{
		if(!isCircleOverlapping(circle1,radius1,circle2,radius2)) return 0; // no overlap

		var dist = Math.sqrt((circle1.x-circle2.x) * (circle1.x-circle2.x) + (circle1.y-circle2.y) * (circle1.y-circle2.y));

		var CBD = 2 * Math.acos((radius2*radius2 + dist*dist - radius1*radius1) / (radius2 * dist * 2));
		var CAD = 2 * Math.acos((radius1*radius1 + dist*dist - radius2*radius2) / (radius1 * dist * 2));

		var area:Float =	 .5*CBD*radius2*radius2 - .5*radius2*radius2*Math.sin(CBD) +
							.5*CAD*radius1*radius1 - .5*radius1*radius1*Math.sin(CAD);

		return area;
	}

	/**
	 * Calculates the area of a circle.
	 * @param radius radius of the circle
	 * @return the area of the circle
	 *
	 */
	public static function circleArea(radius:Float):Float{
		return Math.PI * radius * radius;
	}

	/**
	 * Determines if a point is within a circle
	 * @param circle the center point of the circle
	 * @param radius radius of the circle.
	 * @param point the point to check
	 * @return true if the point is within the circle
	 *
	 */
	public static function isPointInCircle(point:Vec2, circle:Vec2, radius:Float):Bool{
		var distSq = point.subtract(circle).lengthSq();
		 if(distSq < (radius * radius)) return true;

		 return false;
	}

	/**
	 * Determines if a line segment intersects with a circle.
	 * @param A Start point of the line.
	 * @param B End point of the line.
	 * @param circle position of the circle.
	 * @param radius radius of the circle.
	 * @return true if circle overlaps the line segment
	 *
	 */
	public static function isCircleOverlappingSegment(A:Vec2, B:Vec2, circle:Vec2, radius:Float):Bool{

		var distSq = LineSegment.distToLineSegmentSq(A,B,circle);
		if (distSq < radius * radius) return true;
		return false;
	}

	/**
	 * Determines if a point is contained within a (rotated) rectangle.
	 * @param A Point.
	 * @param B Center of rectangle.
	 * @return true if point is contained within the rectangle
	 *
	 */
	public static function isPointInsideRotatedRect(A:Vec2, locX :Float, locY :Float, width :Float, height :Float, angle :Float):Bool
	{
		var relativePoint:Vec2 = new Vec2(A.x - locX, A.y - locY);
		if(angle != 0) {
			relativePoint.rotateLocal(-angle);
		}
		return relativePoint.x >= -width/2 &&
			   relativePoint.x <= width/2 &&
			   relativePoint.y <= height/2 &&
			   relativePoint.y >= -height/2;
	}

	public static function isPointInsideRect(A:Vec2, x :Float, y :Float, w :Float, h:Float):Bool
	{
		return A.x >= x &&
			   A.x <= x + w &&
			   A.y >= y &&
			   A.y <= y + h;
	}

	/**
	 * Determines if a line and circle intersects, and if so stores the closest intersection
	 * point in 'intersectionPoint'
	 * @param A Start point of the line.
	 * @param B End point of the line.
	 * @param circle position of the circle.
	 * @param radius radius of the circle.
	 * @param intersectionPoint A Vector to store the closest intersection point in.
	 * @return false if the two do not intersect.
	 *
	 */
	public static function getLineCircleClosestIntersection (A:Vec2, B:Vec2, circle:Vec2, radius:Float, intersectionPoint:Vec2):Bool
	{
		   throw "Not implemented";
		   return false;
//		var toBNorm:Vec2 = B.subtract(A).normalize();
//
//		var localPos:Vec2 = Transformations.pointToLocalSpace(circle,toBNorm,toBNorm.getPerp(),A);
//
//		var ipFound:Bool = false;
//
//		if((localPos.x + radius >= 0) && (localPos.x-radius) <=Vec2Tools.distanceSq(B, A)){
//			if(Math.abs(localPos.y) < radius){
//				var a = localPos.x;
//				var b = localPos.y;
//
//				var ip = a - Math.sqrt(radius*radius - b*b);
//
//				if (ip <= 0) ip = a + Math.sqrt(radius*radius - b*b);
//
//				ipFound = true;
//
//				intersectionPoint = A.addLocal(toBNorm.scale(ip));
//			}
//		}
//
//		return ipFound;
	}

//  /**
//	 * Given a line segment AB and a point P, this function calculates the
//	 * perpendicular distance between them.
//	 * @param A the first point of the line segment
//	 * @param B the 2nd point of the line segment
//	 * @param P the point to check against
//	 * @return the distance from P -> AB
//	 *
//	 */
//	public static function distToLineSegment (A :Vec2, B :Vec2, P :Vec2, closestPoint :Vec2 = null) :Number
//	{
//
//
//		var dotA:Number = (P.x - A.x)*(B.x - A.x) + (P.y - A.y)*(B.y - A.y);
//
//		if (dotA <= 0) {
//			if(closestPoint != null) {
//				closestPoint.x = A.x;
//				closestPoint.y = A.y;
//			}
//
//			return distance(A, P);
//		}
//
//		var dotB:Number = (P.x - B.x)*(A.x - B.x) + (P.y - B.y)*(A.y - B.y);
//
//		if (dotB <= 0) {
//			if(closestPoint != null) {
//				closestPoint.x = B.x;
//				closestPoint.y = B.y;
//			}
//			return distance(B, P);
//		}
//
//		// .. Find closest point to P on line segment ...
//		var point:Vec2 = B.subtract(A);
//		point.scaleLocal(dotA);
//		point.scale(1 / (dotA+dotB));
//		point.addLocal(A);
//
//		if(closestPoint != null) {
//			closestPoint.x = point.x;
//			closestPoint.y = point.y;
//		}
//
//		return distance(P, point);
//	}

//	/**
//	 * Given a line segment AB and a point P, this function calculates the
//	 * perpendicular distance between them.
//	 * @param A the first point of the line segment
//	 * @param B the 2nd point of the line segment
//	 * @param P the point to check against
//	 * @return the distance from P -> AB
//	 *
//	 */
//	public static function closestPointOnPolygon(P:Vec2, arrayOfPolygonPoints :Array):Vec2
//	{
//		var polygon :Array = arrayOfPolygonPoints.slice();
//		if(arrayOfPolygonPoints[0] != arrayOfPolygonPoints[ arrayOfPolygonPoints.length - 1]) {
//			polygon.push(polygon[0]);
//		}
//
//		var distance :Number = Math.POSITIVE_INFINITY;
//		var closestVector :Vec2;
//		for(var k :int = 0; k < polygon.length - 1; k++) {
//			var point :Vec2 = new Vec2();
//			var currentDistance :Number = Geometry.distToLineSegment(polygon[k], polygon[k + 1], P, point);
//			if( currentDistance < distance) {
//				distance = currentDistance;
//				closestVector = point;
//			}
//		}
//		return closestVector;
//
//	}
//
//	public static function isCircleIntersectingPolygon(P :Vec2, radius :Number, polygon :Array) :Boolean
//	{
//		var closestPointOnPolygon :Vec2 = closestPointOnPolygon(P, polygon);
//		return distance(closestPointOnPolygon, P) <= radius;
//	}

//	public static function getPolygonCenter(arrayOfPolygonPoints :Array, center :Vec2 = null):Vec2
//	{
//		var minX :Number = Math.POSITIVE_INFINITY;
//		var maxX :Number = Math.NEGATIVE_INFINITY;
//		var minY :Number = Math.POSITIVE_INFINITY;
//		var maxY :Number = Math.NEGATIVE_INFINITY;
//
//		for each (var v :Vec2 in arrayOfPolygonPoints) {
//			minX = Math.min(minX, v.x);
//			maxX = Math.max(maxX, v.x);
//			minY = Math.min(minY, v.y);
//			maxY = Math.max(maxY, v.y);
//		}
//
//		if(center == null) {
//			center = new Vec2(minX + (maxX - minX) / 2, minY + (maxY - minY) / 2);
//		}
//		else {
//			center.x = minX + (maxX - minX) / 2;
//			center.y = minY + (maxY - minY) / 2;
//		}
//		return center;
//
//	}

//	public static function maxY(arrayOfPolygonPoints :Array) :Number
//	{
//		var maxY :Number = Math.NEGATIVE_INFINITY;
//		for each (var v :Vec2 in arrayOfPolygonPoints) {
//			maxY = Math.max(maxY, v.y);
//		}
//		return maxY;
//	}
//
//
//	public static function minY(arrayOfPolygonPoints :Array) :Number
//	{
//		var minY :Number = Math.POSITIVE_INFINITY;
//		for each (var v :Vec2 in arrayOfPolygonPoints) {
//			minY = Math.min(minY, v.y);
//		}
//		return minY;
//	}
//	public static function height(arrayOfPolygonPoints :Array) :Number
//	{
//		var maxY :Number = Math.NEGATIVE_INFINITY;
//		var minY :Number = Math.POSITIVE_INFINITY;
//		for each (var v :Vec2 in arrayOfPolygonPoints) {
//			maxY = Math.max(maxY, v.y);
//			minY = Math.min(minY, v.y);
//		}
//		return maxY - minY;
//	}
//
//	public static function width(arrayOfPolygonPoints :Array) :Number
//	{
//		var maxX :Number = Math.NEGATIVE_INFINITY;
//		var minX :Number = Math.POSITIVE_INFINITY;
//		for each (var v :Vec2 in arrayOfPolygonPoints) {
//			maxX = Math.max(maxX, v.x);
//			minX = Math.min(minX, v.x);
//		}
//		return maxX - minX;
//	}
//
//	public static function maxX(arrayOfPolygonPoints :Array) :Number
//	{
//		var maxX :Number = Math.NEGATIVE_INFINITY;
//		for each (var v :Vec2 in arrayOfPolygonPoints) {
//			maxX = Math.max(maxX, v.x);
//		}
//		return maxX;
//	}
//
//	public static function minX(arrayOfPolygonPoints :Array) :Number
//	{
//		var minX :Number = Math.POSITIVE_INFINITY;
//		for each (var v :Vec2 in arrayOfPolygonPoints) {
//			minX = Math.min(minX, v.x);
//		}
//		return minX;
//	}

//	/**
//	 * Given two polygons, returns true if they intersect on the y axis.  Note, the x axis is
//	 * INGORED, so the polygons may not actually intersect in 2D space.
//	 *
//	 * @param p1 a polygon as an array of points, with the first vertex also in the last position
//	 * @param p1 a polygon as an array of points, with the first vertex also in the last position
//	 * @return true if the y spaces intersect.
//	 *
//	 */
//	public static function isVerticalIntersection(p1 :Array, p2 :Array) :Boolean
//	{
//		var minY1 :Number = minY(p1);
//		var maxY1 :Number = maxY(p1);
//
//		var minY2 :Number = minY(p2);
//		var maxY2 :Number = maxY(p2);
//
//		if(isNumberWithinRange(minY2, minY1, maxY1) ||
//			isNumberWithinRange(maxY2, minY1, maxY1) ||
//			isNumberWithinRange(minY1, minY2, maxY2) ||
//			isNumberWithinRange(maxY1, minY2, maxY2)) {
//				return true;
//			}
//
//		return false
//
//	}

	/**
	* Is one polygon vertically contained in the other.  Checks for both.
	*/
//	public static function isVerticalContained(p1 :Array, p2 :Array) :Boolean
//	{
//		var minY1 :Number = minY(p1);
//		var maxY1 :Number = maxY(p1);
//
//		var minY2 :Number = minY(p2);
//		var maxY2 :Number = maxY(p2);
//
//		if((isNumberWithinRange(minY2, minY1, maxY1) &&
//			isNumberWithinRange(maxY2, minY1, maxY1)) ||
//			(isNumberWithinRange(minY1, minY2, maxY2) &&
//			isNumberWithinRange(maxY1, minY2, maxY2))) {
//				return true;
//			}
//
//		return false
//
//	}

//	/**
//	 * Given two polygons, returns true if they intersect on the x axis.  Note, the y axis is
//	 * INGORED, so the polygons may not actually intersect in 2D space.
//	 *
//	 * @param p1 a polygon as an array of points, with the first vertex also in the last position
//	 * @param p1 a polygon as an array of points, with the first vertex also in the last position
//	 * @return true if the x spaces intersect.
//	 *
//	 */
//	public static function isHorizontalIntersection(p1 :Array, p2 :Array) :Boolean
//	{
//		var minX1 :Number = minX(p1);
//		var maxX1 :Number = maxX(p1);
//
//		var minX2 :Number = minX(p2);
//		var maxX2 :Number = maxX(p2);
//
//		if(isNumberWithinRange(minX2, minX1, maxX1) ||
//			isNumberWithinRange(maxX2, minX1, maxX1) ||
//			isNumberWithinRange(minX1, minX2, maxX2) ||
//			isNumberWithinRange(maxX1, minX2, maxX2)) {
//				return true;
//			}
//
//		return false
//
//	}

//	public static function isHorizontallyContained(p1 :Array, p2 :Array) :Boolean
//	{
//		var minX1 :Number = minX(p1);
//		var maxX1 :Number = maxX(p1);
//
//		var minX2 :Number = minX(p2);
//		var maxX2 :Number = maxX(p2);
//
//		if((isNumberWithinRange(minX2, minX1, maxX1) &&
//			isNumberWithinRange(maxX2, minX1, maxX1)) ||
//			(isNumberWithinRange(minX1, minX2, maxX2) &&
//			isNumberWithinRange(maxX1, minX2, maxX2))) {
//				return true;
//			}
//
//		return false
//
//	}

//
//	 /**
//	 * Returns the closest vertex of the polygon (an array of points) to P
//	 */
//	public static function getClosestVertex(P :Vec2, polygon :Array) :Vec2
//	{
//		var distance :Number = Math.POSITIVE_INFINITY;
//		var closestVector :Vec2;
//		for(var k :int = 0; k < polygon.length; k++) {
//			var currentDistance :Number = Geometry.distance(P, polygon[k]);
//			if( currentDistance < distance) {
//				distance = currentDistance;
//				closestVector = polygon[k];
//			}
//		}
//		return closestVector;
//	}

//	 /**
//	 * Returns the closest vertex of the polygon (an array of points) to P
//	 */
//	public static function getVerticesInOrderOfDistanceToPoint(P :Vec2, polygon :Array) :Array
//	{
//		var sortedArray :Array = polygon.slice();
//
//		sortedArray.sort(function compareFunction(v1 :Vec2, v2 :Vec2) :int  {
//		   var d1 :Number =Vec2Tools.distanceSq(v1, P);
//		   var d2 :Number =Vec2Tools.distanceSq(v2, P);
//		   if(d1 < d2) { return -1; }
//		   else if(d1 > d2) { return 1;}
//		   return 0;
//		});
//
//		return sortedArray;
//	}

	/**
	 * Returns true if all the given points are equal to one of the polygon points.
	 */
//	public static function isPolygonVertex (polygon :Array, P :Vec2) :Boolean
//	{
//		for each (var polygonPoint :Vec2 in polygon) {
//			if(polygonPoint.x == P.x && polygonPoint.y == P.y) {
//				return true;
//			}
//		}
//		return false;
//	}

//	public static function isPointsEqualToPolygonEdge(A :Vec2, B :Vec2, polygon :Array) :Boolean
//	{
//		for(var k :int = 0; k < polygon.length - 1; k++) {
//			var v1 :Vec2 = polygon[k] as Vec2;
//			var v2 :Vec2 = polygon[k + 1] as Vec2;
//			if((A.equals(v1) && B.equals(v2)) || (A.equals(v2) && B.equals(v1))) {
//				return true;
//			}
//		}
//		return false;
//	}

//	public static function isPointOnPolygonEdge(P :Vec2, polygon :Array) :Boolean
//	{
//		for(var k :int = 0; k < polygon.length - 1; k++) {
//			if(distToLineSegment(polygon[k], polygon[k + 1], P) == 0) {
//				return true;
//			}
//		}
//		return false;
//	}

//	/**
//	 * Orders a set of points so that no line segments intersect.
//	 */
//	public static function orderPointsToCreatePolygon(points :Array) :Array
//	{
////			function lineSegmentsIntersect(polygon :Array) :Boolean
////			{
////				var intersects :Boolean = false;
////				for(var k :int = 0; k < polygon.length - 1; k++) {
////
////				}
////			}
//		return points;
//	}

//	/**
//	 * Given two polygons, returns all intersection points and points contained in the other polygon.
//	 * NB: the returned list of points is not a true polygon because the order is arbitrary.
//	 * @param p1 a polygon as an array of points, with the first vertex also in the last position
//	 * @param p1 a polygon as an array of points, with the first vertex also in the last position
//	 * @return an Array containing all points contained in the other polygon and all intersection points.
//	 *
//	 */
//	public static function getIntersectionBoundingBox(p1 :Array, p2 :Array) :Array
//	{
//		var containedPoints :Array = new Array();
//		var v :Vec2;
//		var k :int;
//		var kk :int;
//
//		//Get the vertices within the other polygon
//		for(k = 0; k < p1.length - 1; k++) {
//			v = p1[k] as Vec2;
//			if(Geometry.isPointInPolygon(v, p2) && !Lambda.has(containedPoints, v) && v != null) {
//				containedPoints.push(v);
//			}
//		}
//		for(k = 0; k < p2.length - 1; k++) {
//			v = p2[k] as Vec2;
//			if(Geometry.isPointInPolygon(v, p1) && !Lambda.has(containedPoints, v) && v != null) {
//				containedPoints.push(v);
//			}
//		}
//
//		var intersectionPoints :Array = new Array();
//		//Create the intersection points
//		for(k = 0; k < p1.length - 1; k++) {
//			for(kk = 0; kk < p2.length - 1; kk++) {
//				if(Geometry.isLineIntersecting(p1[k], p1[k + 1], p2[kk], p2[kk + 1])) {
//					var intersectingPoint :Vec2 = Geometry.lineIntersectLine(p1[k], p1[k + 1], p2[kk], p2[kk + 1]);
//					if(intersectingPoint != null) {
//						intersectionPoints.push(intersectingPoint);
//					}
//				}
//			}
//		}
//
//		containedPoints = containedPoints.concat(intersectionPoints);
//		return containedPoints;
//	}

//	public static function makeAllPointsLessThanX(points :Array, X :Number) :void
//	{
//		points.forEach(function(point :Vec2, ...ignored) :void {
//			  if(point.x > X) {
//				  point.x = X;
//			  }
//		  });
//	}
//	public static function makeAllPointsMoreThanX(points :Array, X :Number) :void
//	{
//		points.forEach(function(point :Vec2, ...ignored) :void {
//			  if(point.x < X) {
//				  point.x = X;
//			  }
//		  });
//	}

//	/**
//	 * Same as <code>distance</code> but avoids the square root.
//	 * Use this any time the exact distance isn't exactly required.
//	 * @param v1 The first Vec2 to test distance with.
//	 * @param v2 The second Vec2 to test distance with.
//	 * @return The resulting distance * distance between
//	 *
//	 */
//	public static functionVec2Tools.distanceSq (v1 :Vec2, v2 :Vec2) :Number
//	{
//		var xSep:Number = v1.x - v2.x;
//		var ySep:Number = v1.y - v2.y;
//		return ySep*ySep + xSep*xSep;
//	}
//
//	public static function distance (vector1 :Vec2, vector2 :Vec2) :Number
//	{
//		var xSep:Number = vector1.x - vector2.x;
//		var ySep:Number = vector1.y - vector2.y;
//		return Math.sqrt(ySep*ySep + xSep*xSep);
//	}

	public static function bezier (v1 :Vec2, v2 :Vec2, v3 :Vec2, t :Float,
		?v :Vec2 = null) :Vec2
	{
		var fac1 = Math.pow(1 - t, 2);
		var fac2 = 2 * t * (1 - t);
		var fac3 = Math.pow(t, 2);
		var x = fac1 * v1.x + fac2 * v2.x + fac3 * v3.x;
		var y = fac1 * v1.y + fac2 * v2.y + fac3 * v3.y;
		if (v == null) {
			return new Vec2(x, y);
		} else {
			v.x = x;
			v.y = y;
		}
		return v;

	}

}
