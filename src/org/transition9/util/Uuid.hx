package org.transition9.util;

import org.transition9.util.Rand;

class Uuid
{
	/** Random stream id */
	static var RAND_UUID_STREAM :Int = -1;
	/**
	From casalib
	Creates an "universally unique" identifier (RFC 4122, version 4).
	
	@return Returns an UUID.
	*/
	public static function uuid() :String 
	{
		if (RAND_UUID_STREAM == -1) {
			//Divide by 1000 so it's less than the maxa seed value for ParkMiller (2147483646)
			RAND_UUID_STREAM = Rand.addStream(Std.int(Date.now().getTime() / 1000));
		}
		return createRandomIdentifier(8, 15) + '-' + createRandomIdentifier(4, 15) + '-4' + createRandomIdentifier(3, 15) + '-' + specialChars[Rand.nextIntInRange(0, 3 - 1)] + createRandomIdentifier(3, 15) + '-' + createRandomIdentifier(12, 15);
	}
	
	/**
		From casalib
		Creates a random identifier of a specified length and complexity.
		
		@param length: The character length of the random identifier.
		@param radix: The number of unique/allowed values for each character (61 is the maximum complexity).
		@return Returns a random identifier.
		@usageNote For a case-insensitive identifier pass in a max <code>radix</code> of 35, for a numberic identifier pass in a max <code>radix</code> of 9.
	*/
	#if flash
	public static function createRandomIdentifier(length:UInt, radix:UInt = 61):String 
	#else
	public static function createRandomIdentifier(length:Int, radix:Int = 61):String
	#end
	{
		#if js
		Preconditions.checkArgument(length >= 0 && radix >= 0);
		#end	
		var id = new Array<String>();
		radix = (radix > 61) ? 61 : radix;
		
		while (length-- > 0) {
			id.push(characters[Rand.nextIntInRange(0, radix - 1, RAND_UUID_STREAM)]);
		}
		
		return id.join('');
	}
	
	static var specialChars = ['8', '9', 'A', 'B'];
	static var characters = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9', 'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', 'N', 'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z', 'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 'k', 'l', 'm', 'n', 'o', 'p', 'q', 'r', 's', 't', 'u', 'v', 'w', 'x', 'y', 'z'];

}
