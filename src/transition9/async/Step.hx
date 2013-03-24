package transition9.async;

using Lambda;

class Step
{
	var _chain :Array<Dynamic>;
	/** The total number of functions called */
	var _callId :Int;
	var _groupedCall :GroupedCall;
	
	public function new ()
	{
		_chain = [];
		_callId = -1;
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
		Console.assert(_chain != null, "_chain == null");
		Console.assert(_chain.length > 0, "_chain.length <= 0");
		callNext([err, err == null ? result : null]);
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
		Console.assert(_chain.length > 0, "_chain.length <= 0");
		callNext([err, null]);
	}
	
	function createCallback (isParallel :Bool) :Dynamic->Dynamic->Void
	{
		if (_groupedCall == null) {
			_groupedCall = new GroupedCall(_callId, isParallel, callNext);
		} else {
			Console.assert(_groupedCall.isParallel == isParallel, "_groupedCall.isParallel != isParallel");
		}
		return _groupedCall.createCallback();
	}
	
	function callNext (args :Array<Dynamic>) :Void
	{
		Console.assert(_chain != null, '_chain != null');
		Console.assert(_chain.length > 0, '_chain.length > 0');
		Console.assert(_chain[0] != null, '_chain[0] != null');
		Console.assert(Reflect.isFunction(_chain[0]), 'Reflect.isFunction(_chain[0])');
		_callId++;
		if (_groupedCall != null) {
			_groupedCall.shutdown();
			_groupedCall = null;
		}
		try {
			Reflect.callMethod(null, _chain.shift(), args);
		} catch (e :Dynamic) {
			trace("Step caught exception: " + e);
			if (_chain != null && _chain.length > 0) {
				callNext([e, null]);
			} else {
				throw e;
			}
		}
	}
}

class GroupedCall
{
	/** The id of the final callback */
	public var callId (default, null):Int;
	/** The index of the function in a parallel or grouped function */
	var _groupedFunctionIndex :Int;
	/** The number of grouped functions pending  */
	var _pending :Int;
	
	var _pendingResults :Array<Dynamic>;
	var _err :Dynamic;
	public var callNext :Array<Dynamic>->Void;
	public var finished :Bool;
	public var isParallel (default, null) :Bool;
	
	public function new (callId :Int, isParallel :Bool, callNext :Array<Dynamic>->Void)
	{
		this.callId = callId;
		this.isParallel = isParallel;
		_groupedFunctionIndex = _pending = 0;
		_pendingResults = [];
		this.callNext = callNext;
	}
	
	public function shutdown () :Void
	{
		_pendingResults = null;
		callNext = null;
		_err = null;
	}
	
	public function createCallback () :Dynamic->Dynamic->Void
	{
		var index = _groupedFunctionIndex++;
		_pending++;
		
		return function (err :Dynamic, result :Dynamic) :Void {
			_pending--;
			
			if (finished) {
				return;
			}
			
			if (err != null || _err != null) {
				_pendingResults[index] = null;
				if (_err == null) {
					_err = err;
				}
			} else {
				_pendingResults[index] = result;
			}
			if (_pending == 0) {
				haxe.Timer.delay(calledGroupCallback, 0);
			}
		}
	}
	
	function calledGroupCallback () :Void
	{
		if (_pending == 0 && !finished) {
			finished = true;
			if (isParallel) {
				_pendingResults.unshift(_err);
				callNext(_pendingResults);
			} else {
				callNext(_err == null ? [null, _pendingResults] : cast [_err, null]);
			}
		}
	}
}
