package org.transition9.async;

using Lambda;

class Step
{
	var _chain :Array<Dynamic>;
	/** The index of the function in a parallel or grouped function */
	// var _groupedFunctionIndex :Int;
	/** The number of grouped functions pending  */
	// var _pending :Int;
	/** The total number of functions called */
	var _callCount :Int;
	var _groupedCall :GroupedCall;
	// var _pendingResults :Array<Dynamic>;
	// var _pendingErrors :Array<Dynamic>;
	
	public function new ()
	{
		_chain = [];
		_callCount = 0;
		// _pending = _pending = _callCount = _groupedFunctionIndex = 0;
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
		callNext([]);
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
		// if (err != null) {
		// 	Reflect.callMethod(null, _chain[_chain.length - 1], [err, null]);
		// } else {
		// 	Reflect.callMethod(null, _chain.shift(), [err, err == null ? result : null]);
		// }
		callNext([err, err == null ? result : null]);
		// Reflect.callMethod(null, _chain.shift(), [err, err == null ? result : null]);
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
		return createCallback(true);
	}
	
	public function group () :Dynamic->Dynamic->Void
	{
		return createCallback(false);
	}
	
	function handleError (err :Dynamic) :Void
	{
		org.transition9.util.Assert.isTrue(_chain.length > 0);
		_pendingResults = null;
		_pendingErrors = null;
		_pending = 0;
		callNext([err, null]);
		// Reflect.callMethod(null, _chain.shift(), [err, null]);
	}
	
	function createCallback (isParallel :Bool) :Dynamic->Dynamic->Void
	{
		if (_groupedCall == null) {
			_groupedCall = new GroupedCall(_callCount, isParallel, callGroupCallback);
		} else {
			org.transition9.util.Assert.isTrue(_groupedCall.isParallel == isParallel);
		}
		
		
		
		
		
		
		
		
		
		
		var currentCall = _callCount;
		if (_pending == 0) {
			_pendingResults = [];
		}
		var index = _groupedFunctionIndex++;
		_pending++;
		return function (err :Dynamic, result :Dynamic) :Void {
			
			trace("parallel result returned");
			trace('err=' + err);
			trace('result=' + result);
			trace('_pending=' + _pending);
			//If the call has already returned because of an error in a parallel or grouped result, ignore this callback
			if (currentCall != _callCount) {
				return;
			}
			
			if (err != null) {
				if (_pendingErrors == null) {
					_pendingErrors = [err];
				} else {
					_pendingErrors.push(err);
				}
			}
			trace('_pendingResults=' + _pendingResults);
			_pending--;
			_pendingResults[index] = result;
			trace("on callback, _pending=" + _pending);
			trace('index=' + index);
			trace('_pendingResults=' + _pendingResults);
			
			if (_pending == 0) {
				haxe.Timer.delay(callback(calledGroupCallback, currentCall, isParallel), 0);
			}
		}
	}
	
	function callNext (args :Array<Dynamic>) :Void
	{
		_callCount++;
		try {
			_groupedFunctionIndex = _pending = 0;
			Reflect.callMethod(null, _chain.shift(), args);
		} catch (e :Dynamic) {
			callNext([e, null]);
		}
	}
	
	function callGroupCallback () :Void
	{
		
	}
	
	function calledGroupCallback (currentCall :Int, isParallel :Bool) :Void
	{
		if (_pending == 0 || currentCall != _callCount) {
			var results = _pendingResults;
			var errors = _pendingErrors;
			_pendingResults = null;
			_pendingErrors = null;
			
			trace('calling callback for ' + currentCall);
			trace('results=' + results);
			if (isParallel) {
				results.unshift(errors != null ? errors.join("\n") :null);
				// cb(errors != null ? errors.join("\n") :null, results);
				// Reflect.callMethod(null, _chain.shift(), results);
				callNext(results);
			} else {
				// cb(errors != null ? errors.join("\n") :null, results);
				// Reflect.callMethod(null, _chain.shift(), errors == null ? [null, results] : cast [errors.join("\n"), null]);
				callNext(errors == null ? [null, results] : cast [errors.join("\n"), null]);
			}
		}
	}
}

class GroupedCall
{
	/** The id of the final callback */
	public var callId :Int;
	/** The index of the function in a parallel or grouped function */
	public var groupedFunctionIndex :Int;
	/** The number of grouped functions pending  */
	public var pending :Int;
	
	public var pendingResults :Array<Dynamic>;
	// public var pendingErrors :Array<Dynamic>;
	var _err :Dynamic;
	public var callNext :Array<Dynamic>->Void;
	public var finished :Bool;
	
	public function new (callIndex :Int, isParallel :Bool, callNext :Array<Dynamic>->Void)
	{
		this.callIndex = callIndex;
		this.isParallel = isParallel;
		groupedFunctionIndex = pending = 0;
		pendingResults = [];
		// pendingErrors = [];
		this.callNext = callNext;
	}
	
	public function shutdown () :Void
	{
		// pendingErrors = null;
		pendingResults = null;
		finalCall = null;
		_err = null;
	}
	
	public function createCallback () :Dynamic->Dynamic->Void
	{
		var index = _groupedFunctionIndex++;
		pending++;
		
		return function (err :Dynamic, result :Dynamic) :Void {
			
			// trace("parallel result returned");
			// trace('err=' + err);
			// trace('result=' + result);
			// trace('_pending=' + _pending);
			//If the call has already returned because of an error in a parallel or grouped result, ignore this callback
			// if (currentCall != _callCount) {
			// 	return;
			// }
			
			if (err != null) {
				if (_err != null) {
					return;
				} else {
					_err = err;
					haxe.Timer.delay(finalCall, 0);
					
				}
				// if (_pendingErrors == null) {
				// 	_pendingErrors = [err];
				// } else {
					_pendingErrors.push(err);
				// }
			}
			trace('_pendingResults=' + _pendingResults);
			_pending--;
			_pendingResults[index] = result;
			trace("on callback, _pending=" + _pending);
			trace('index=' + index);
			trace('_pendingResults=' + _pendingResults);
			
			if (_pending == 0) {
				haxe.Timer.delay(callback(calledGroupCallback, currentCall, isParallel), 0);
			}
		}
	}

}
