package com.pbking.app.event
{
	import flash.events.Event;

	public dynamic class AppEvent extends Event
	{
		public static const PB_APP_EVENT:String = "PB_APP_EVENT";
		
		public function AppEvent(type:String=PB_APP_EVENT, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
		
	}
}