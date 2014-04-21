package transition9.async;

using Lambda;

typedef Err=Dynamic;

class AsyncLambda
{
	/**
	  * Asynchronously calls f on the elements of it.
	  * f takes a finish callback for that element, where the argument
	  * is an error or null if called successfully.
	  * onFinish will return with an error with the first error thrown, it will not continue iterating.
	  */
	public static function iter<T> (it :Iterable<T>, f :T->(Err->Void)->Void, onFinish :Err->Void) :Void
	{
		var iterator = it.iterator();
		var asyncCall = null;
		asyncCall = function (err :Err) :Void {
			if (err != null) {
				onFinish(err);
			} else if (iterator.hasNext()) {
					f(iterator.next(), asyncCall);
			} else {
				onFinish(null);
			}
		}
		asyncCall(null);
	}

	/**
	  * Asynchronously calls f on the elements of it.
	  * f is the element processing function that takes a finish callback for that element, where the argument
	  * is an error or null if called successfully.
	  * onFinish will return with an error with the first error thrown, unless onError is
	  * given and returns true for that error. If so, that error is not returned for the final onFinish.
	  */
	public static function iter2<T> (it :Iterable<T>, f :T->(Err->Void)->Void, onFinish :Void->Void, onError :T->Err->Bool) :Void
	{
		var iterator = it.iterator();

		//Handle empty iterables
		if (!iterator.hasNext()) {
			onFinish();
			return;
		}

		var asyncCall = null;
		var current :T = iterator.next();
		asyncCall = function (err :Err) :Void {
			if (err != null) {
				//If there's no error handler assume we stop iterating
				if (!onError(current, err)) {
					onFinish();
				}
			}
			if (iterator.hasNext()) {
				current = iterator.next();
				f(current, asyncCall);
			} else {
				onFinish();
			}
		}
		f(current, asyncCall);
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
