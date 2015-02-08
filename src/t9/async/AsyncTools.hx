package t9.async;

class AsyncTools
{
	/**
	  * Converts the callback function into a Node.js compatible one, where the first arg is an error.
	  */
	public static function adapt1 <T>(f :T->Void, ?onError :Dynamic->Void) :Dynamic->T->Void
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
	public static function adapt2 (f :Void->Void, ?onError :Dynamic->Void) :Dynamic->Dynamic->Void
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

	/**
	  * To be used inside a callback:
	  * if (AsyncTools.returnIfError(err, cb)) return;
	  */
	public static function returnIfError (err :Dynamic, cb :Dynamic->Dynamic->Void) :Bool
	{
		if (err != null) {
			cb(err, null);
		}
		return err != null;
	}
}
