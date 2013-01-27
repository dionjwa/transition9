package transition9.services.html5storage;

/**
  * Js implementation of a remoting service that uses HTML5 localStorage.
  * If Modernizr is available, it's used to detect localStorage
  * http://www.modernizr.com/
  */
class Html5StorageManager implements Html5StorageService
{
	var _isAvailable :Bool;
	static var ERR_MSG = "No localStorage.  Did you check first?";
	
	public function new ()
	{
		//Attempt localStorage detection
		_isAvailable = false;
		
		#if js
			#if modernizr
			_isAvailable = Modernizr.localstorage;
			#else
			Log.warn("modernizr is missing, so we cannot safely check for localStorage");
			#end
		#else
		ERR_MSG = "Html5StorageManager only works in the client browser javascript."; 
		#end
	}
	
	public function isAvailable (cb :Bool->Void) :Void
	{
		#if js
		cb(_isAvailable);
		#end
	}
	
	public function getItem (key :String, cb :Dynamic->Void) :Void
	{
		check();
		#if js
		var item = LocalStorage.getItem(key);
		if (item == null) {
			cb(null);
		} else {
			try {
				cb(haxe.Unserializer.run(item));
			} catch (e :Dynamic) {
				Log.error("Error unserializing " + key + ", so removing the item. e=" + e);
				removeItem(key, function (_) :Void {
					cb(null);
				});
			}
		}
		#end
	}
	
	public function setItem (key :String, val :Dynamic, cb :Bool->Void) :Void
	{
		check();
		#if js
		var itemString = haxe.Serializer.run(val);
		LocalStorage.setItem(key, itemString);
		cb(true);
		#end
	}
	
	public function removeItem (key :String, cb :Bool->Void) :Void
	{
		check();
		#if js
		LocalStorage.removeItem(key);
		cb(true);
		#end
	}
	
	public function getLength(cb :Int->Void) :Void
	{
		check();
		#if js
		cb(LocalStorage.length);
		#end
	}
	
	public function key(index :Int, cb :String->Void) :Void
	{
		check();
		#if js
		cb(LocalStorage.key(index));
		#end
	}
	
	inline function check () :Void
	{
		transition9.util.Preconditions.checkArgument(_isAvailable, ERR_MSG);
	}
}
