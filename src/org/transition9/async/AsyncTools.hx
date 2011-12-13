package org.transition9.async;

class AsyncTools
{
	/**
	  * Converts the callback function into a Node.js compatible one, where the first arg is an error.
	  */
	public static function addErrorArg <T>(f :T->Void, ?onError :Dynamic->Void) :Dynamic->T->Void
	{
		return function (err :Dynamic, val :T) :Void {
			if (err) {
				if (onError != null) onError(err);
				f(null);
			} else {
				f(val);
			}
		}
	}
	
	/**
	  * Converts the callback function into a Node.js compatible one, where the first arg is an error.
	  */
	public static function addErrorArg1 (f :Void->Void, ?onError :Dynamic->Void) :Dynamic->Dynamic->Void
	{
		return function (err :Dynamic, ignored :Dynamic) :Void {
			if (err) {
				if (onError != null) onError(err);
				f();
			} else {
				f();
			}
		}
	}
}
