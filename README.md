[haxe]: http://haxe.org
[nodejs]: http://nodejs.org/
[step]: https://github.com/creationix/step
[haxelib]: http://lib.haxe.org/p/async-tools

## A collection of utilities for [Haxe][haxe].

### Tools for asynchronous programming in [Haxe][haxe], targeted at [Node.js][nodejs].

[Node.js][nodejs] is a single-threaded asynchronous server, particularly well suited for high performance servers such as game back-ends.  Writing your Node.js code in [Haxe][haxe] is provides so many advantages there are almost too many to list.

The standard Haxe library is generally aimed at synchronous programming.  This is a small collection of tools that I proved useful when writing async code. For the most part, these tools reduce the amount of code and make it easier to read, since async programming can often become verbose, especially when processing a long chain of async callbacks. 

### Step

Inspired directly from [Step][step].  I wrote a haxe version of this as an exercise in async programming.

Since Node.js is built around async callbacks, a series of sequential async steps can become rather verbose with a lot of indenting, and it becomes rather ugly when you want to do parallel async tasks:

	doSomething1(arg, function (err, result) {
		doSomething2(result, function (err, result) {
			doSomething3(result, function (err, result) {
				doSomething4(result, function (err, result) {
					//I'm indented quite a lot!
				});
			});
		});
	});
	
Step allows you to pass a series of functions, some of which can be performed in parallel, or as a group.  The resulting code is much easier on the eye. Uncaught errors are caught and passed to the next function:

	var step = new Step();
	step.chain([
		function () {
			readFileAsync(fileName, step.cb);
		},
		function (err, fileData) {
			doFooParallel(arg1, step.parallel());
			doFooParallel(arg2, step.parallel());
			doFooParallel(arg3, step.parallel());
		},
		function (err, foo1, foo2, foo3) {//Parallel results from previous call passed as function arguments
			doFooGroup(arg1, step.group());
			doFooGroup(arg2, step.group());
			doFooGroup(arg3, step.group());
		},
		function (err, fooArray) {//Group results from previous added as an array argument
			doSomethingElseAsync(fooArray, step.cb);
		},
		function (err, arg) {
			//ok we're finished here, call the final callback supplied by the parent function
		},
	]);


### AsyncLambda

Contains some functions for operating asynchronously on iterables.  For example, map values from an array to another
array:

	var fromArray = [1, 2, 3, 4];
	
	var onElement = function (element :Int, cb :String->Void) {
		haxe.Timer.delay(function () {
			cb("Some int=" + element);
		}, 100);
		
	}
	
	var onFinish = function (err :Dynamic, result :Array<String>) {
		if (err != null) trace("Oh no: " + err);
		trace("result=" + result);
	}
	
	AsyncLambda.map(fromArray, onElement, onFinish);



    
