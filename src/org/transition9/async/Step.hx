package org.transition9.async;

using Lambda;

class Step
{
	var _chain :Array<Dynamic>;
	var _pending :Int;
	var _isParallel :Bool;
	var _pendingResults :Array<Dynamic>;
	var _pendingErrors :Array<Dynamic>;
	
	public function new ()
	{
		_chain = [];
		_isParallel = false;
		_pending = _pending = 0;
	}
	
	/**
	  * Chain a series of functions together.  The callback from the previous 
	  * function is fed into the next function.
	  */
	public function chain (arr :Array<Dynamic>) :Void
	{
		for (f in arr) {
			_chain.push(f);
		}
		Reflect.callMethod(null, _chain.shift(), []);
	}
	
	/**
	  * The callback passed to an async call.  Will pass the result or error
	  * to the next chained function.
	  */
	public function cb (err :Dynamic, result :Dynamic) :Void
	{
		org.transition9.util.Assert.isNotNull(_chain);
		org.transition9.util.Assert.isTrue(_chain.length > 0);
		
		//If there is an error, call the final function
		if (err != null) {
			Reflect.callMethod(null, _chain[_chain.length - 1], [err, null]);
		} else {
			Reflect.callMethod(null, _chain.shift(), [err, err == null ? result : null]);
		}
	}
	
	/**
	  * Adapt the callback to func(err, result)
	  */
	public function cb1 (result :Dynamic) :Void
	{
		cb(null, result);
	}
	
	/**
	  * Adapt the callback to func(err, result)
	  */
	public function cb0 () :Void
	{
		cb(null, null);
	}
	
	public function parallel () :Dynamic->Dynamic->Void
	{
		_isParallel = true;
		return createCallback();
	}
	
	public function group () :Dynamic->Dynamic->Void
	{
		_isParallel = false;
		return createCallback();
	}
	
	function handleError (err :Dynamic) :Void
	{
		org.transition9.util.Assert.isTrue(_chain.length > 0);
		_pendingResults = null;
		_pendingErrors = null;
		_pending = 0;
		Reflect.callMethod(null, _chain.shift(), [err, null]);
	}
	
	function createCallback () :Dynamic->Dynamic->Void
	{
		if (_pending == 0) {
			_pendingResults = [];
		}
		var index = _pending;
		_pending++;
		return function (err :Dynamic, result :Dynamic) :Void {
			
			if (err != null) {
				if (_pendingErrors == null) {
					_pendingErrors = [err];
				} else {
					_pendingErrors.push(err);
				}
			}
			_pending--;
			_pendingResults[index] = result;
			if (_pending == 0) {
				var results = _pendingResults;
				var errors = _pendingErrors;
				_pendingResults = null;
				_pendingErrors = null;
				
				if (_isParallel) {
					results.unshift(errors != null ? errors.join("\n") :null);
					Reflect.callMethod(null, _chain.shift(), results);
				} else {
					Reflect.callMethod(null, _chain.shift(), errors == null ? [null, results] : cast [errors.join("\n"), null]);
				}
			}
		}
	}
}
