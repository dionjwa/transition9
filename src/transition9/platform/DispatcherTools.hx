package transition9.platform;

import jQuery.JQuery;
import js.Browser;

class DispatcherTools
{
	/**
	 * json is a key/value map where the values are the button names and the
	 * event names.
	 */
	public static function bindDispatcherToClickEvents(json :Dynamic, ?dispatcher :Dispatcher)
	{
		dispatcher = dispatcher == null ? Dispatcher.i : dispatcher;
		for (fieldName in Reflect.fields(json)) {
			var value = Reflect.field(json, fieldName);
			// trace('Binding "#$value" to $value');
			new JQuery("#" + value).on("click", function(event) {
				dispatcher.onMessageRecieved(value);
			});
		}
	}
}