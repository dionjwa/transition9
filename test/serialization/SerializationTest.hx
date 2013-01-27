package serialization;

import serialization.support.RedisSerializableClass;
import transition9.serialization.Serialization;
// import utest.Assert;
import transition9.util.Assert;

using Lambda;

/**
 * Serialization tests
 */
class SerializationTest 
{
	public function new() 
	{
		
	}
	
	@BeforeClass
	public function beforeClass():Void
	{
	}
	
	@AfterClass
	public function afterClass():Void
	{
	}
	
	@Before
	public function setup():Void
	{
	}
	
	@After
	public function tearDown():Void
	{
	}
	
	/**
	  * Redis can store objects as hashes (key, values).
	  */
	@Test
	public function testRedisSerialization():Void
	{
		var toSerialize = new RedisSerializableClass();
		
		var var1 = "someTestString";
		var var2 = 7;
		var var3 = [1, 2, 3];
		
		
		toSerialize.var1 = var1;
		toSerialize.var2 = var2;
		toSerialize.var3 = var3;
		
		var array = Serialization.classToArray(toSerialize);
		
		Assert.isTrue(array.length == 6, "array.length == 6, array.length=" + array.length);
		
		var deserialized :RedisSerializableClass = Serialization.arrayToClass(array, RedisSerializableClass);
		
		Assert.isTrue(toSerialize.var1 == deserialized.var1);
		Assert.isTrue(toSerialize.var2 == deserialized.var2);
		Assert.isTrue(deserialized.var3 != null);
		Assert.isTrue(deserialized.var3.length == var3.length);
		Assert.isTrue(deserialized.var3[1] == var3[1]);
		
	}
}
