package com.pbking.app.event
{
	import flash.events.Event;

	/**
	 * Base event class for App events.  Doesn't add much
	 * to the base Event class, but the GlobalEventBroadcaster
	 * uses 'em.
	 */
	public dynamic class AppEvent extends Event
	{
		public static const PB_APP_EVENT:String = "PB_APP_EVENT";
		
		public function AppEvent(type:String=PB_APP_EVENT, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
		
	}
}