package macros;

class TestMacros extends haxe.unit.TestCase
{
	public function testMacroTemplate() :Void
	{
		var templateContent = sys.io.File.getContent("test/macros/out.txt");
		assertTrue(templateContent == "My name is a test string and I'm 55 years old.");
	}

	public function testTypedefCompletion () :Void
	{
		var thing = transition9.macro.JsonObjectBuilder.buildObjectFromJsonFile("test/macros/Strings.json");
		assertTrue(thing.String1 == "String1");
		assertTrue(thing.String2 == "String2");

		var data = transition9.macro.JsonObjectBuilder.buildObjectFromJsonFile("test/macros/Data.json");
		assertTrue(data.String1 == "a test string");
		assertTrue(data.ANumber == 55);
	}

	public function testPooledMacro () :Void
	{
		var p1 = PooledClass.get();
		var p2 = PooledClass.get();
		assertTrue(p1 != null);
		assertTrue(p2 != null);
		assertTrue(p1 != p2);
		assertTrue(PooledClass.POOL.length == 0);

		p2.dispose();
		assertTrue(PooledClass.POOL.length == 1);

		var p3 = PooledClass.get();
		assertTrue(PooledClass.POOL.length == 0);

		assertTrue(p2 == p3);

		var p2 = PooledClass.get();

		assertTrue(p2 != p3);
		assertTrue(p2 != p1);

		p1.dispose();
		#if debug
		assertTrue(p1.isDisposed());
		#end

		p2.dispose();
		p3.dispose();
		assertTrue(PooledClass.POOL.length == 3);
	}

	public function testPooledWithExistingDisposeMacro () :Void
	{
		var p1 = PooledClassWithExistingDispose.get();
		var p2 = PooledClassWithExistingDispose.get();
		assertTrue(p1 != null);
		assertTrue(p2 != null);
		assertTrue(p1 != p2);
		assertTrue(PooledClassWithExistingDispose.POOL.length == 0);

		p2.dispose();
		assertTrue(PooledClassWithExistingDispose.POOL.length == 1);
		assertTrue(p2.isDisposeCalled);
		p2.isDisposeCalled = false; //Reset it

		var p3 = PooledClassWithExistingDispose.get();
		assertTrue(PooledClassWithExistingDispose.POOL.length == 0);

		assertTrue(p2 == p3);

		var p2 = PooledClassWithExistingDispose.get();

		assertTrue(p2 != p3);
		assertTrue(p2 != p1);

		p1.dispose();
		assertTrue(p1.isDisposeCalled);
		p1.isDisposeCalled = false; //Reset it
		#if debug
		assertTrue(p1.isDisposed());
		#end

		p2.dispose();
		p3.dispose();
		assertTrue(PooledClassWithExistingDispose.POOL.length == 3);

		assertTrue(p2.isDisposeCalled);
		assertTrue(p3.isDisposeCalled);
	}

	public function testLinkedListMacro () :Void
	{
		var p1 = new LinkedListClass();
		var p2 = new LinkedListClass();
		var p3 = new LinkedListClass();

		assertTrue(p1.before == null);
		assertTrue(p1.after == null);
		assertTrue(p2.before == null);
		assertTrue(p2.after == null);
		assertTrue(p3.before == null);
		assertTrue(p3.after == null);

		p3.addAfter(p1);

		assertTrue(p1.before == null);
		assertTrue(p1.after == p3);
		assertTrue(p3.before == p1);
		assertTrue(p3.after == null);

		p2.addBefore(p3);

		assertTrue(p1.before == null);
		assertTrue(p1.after == p2);
		assertTrue(p2.before == p1);
		assertTrue(p2.after == p3);
		assertTrue(p3.before == p2);
		assertTrue(p3.after == null);

		p2.remove();

		assertTrue(p1.before == null);
		assertTrue(p1.after == p3);
		assertTrue(p3.before == p1);
		assertTrue(p3.after == null);
	}
}
