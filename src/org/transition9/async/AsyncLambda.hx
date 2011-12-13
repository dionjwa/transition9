package org.transition9.async;

using Lambda;

typedef Err=Dynamic;

class AsyncLambda
{
	/**
	  * Asynchronously calls f on the elements of it.  f takes a finish callback for that element, where the argument 
	  * is an error or null if called successfull.
	  * onFinish will return with an error with the first error thrown, it will not continue iterating.
	  */
	public static function iter<T> (it :Iterable<T>, f :T->(Void->Void)->Void, onFinish :Err->Void) :Void
	{
		var iterator = it.iterator();
		var asyncCall = null;
		asyncCall = function () :Void {
			if (iterator.hasNext()) {
				try {
					f(iterator.next(), asyncCall);
				} catch (err :Dynamic) {
					onFinish(err);	
				}
			} else {
				onFinish(null);
			}
		}
		asyncCall();
	}
	
	/**
	  * Asynchronously maps an iterable to an Array.
	  * f is the function called on each element.  When mapped, call the supplied callback. 
	  * onFinish is called when complete, or if an error is thrown.
	  */
	public static function map<A, B> (it :Iterable<A>, f :A->(B->Void)->Void, onFinish :Err->Array<B>->Void) :Void
	{
		var mappedElements = [];
		
		var iterator = it.iterator();
		var asyncCall = null;
		asyncCall = function () :Void {
			if (iterator.hasNext()) {
				try {
					f(iterator.next(), function (b :B) {
						mappedElements.push(b);
						asyncCall();
					});
				} catch (err :Dynamic) {
					onFinish(err, null);	
				}
			} else {
				onFinish(null, mappedElements);
			}
		}
		asyncCall();
	}
}
