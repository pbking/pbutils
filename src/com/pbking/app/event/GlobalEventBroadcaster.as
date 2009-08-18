package com.pbking.app.event
{
	import com.pbking.app.command.AppCommand;
	
	import flash.events.EventDispatcher;
	import flash.utils.Dictionary;
	
	import mx.utils.ObjectUtil;
	
	/**
	 * Is a Singleton global event broadcaster.  Grab the instance
	 * and listen for events.  Events can be broadcast from the
	 * public static dispatchAppEvent() method.  This class is 
	 * only for AppEvents (and the derivitives).
	 * 
	 * AppCommands can be registered with this broadcaster so that
	 * when certain app events are dispatched those commands are
	 * called.  Properties that coorispond to those properties
	 * on the event are set on the command. (For instance if an 
	 * AppEvent has a property .peanut and the command registered
	 * to that event also has a property .peanut then the .peanut
	 * property will be set on the command before it is executed.)
	 * 
	 */
	public class GlobalEventBroadcaster extends EventDispatcher
	{
		// VARIABLES //////////
		
		private static var _instance:GlobalEventBroadcaster;
		protected var commandHash:Dictionary = new Dictionary();
		
		// CONSTRUCTION //////////
		
		/**
		 * You CAN create instances of the GlobalEventBroadcaster
		 * for some special circumstances) but normally you would
		 * just call the getInstance() method.
		 */
		public function GlobalEventBroadcaster()
		{
			super();
		}

		/**
		 * Singleton getter
		 */
		public static function getInstance():GlobalEventBroadcaster
		{
			if(!_instance)
				_instance = new GlobalEventBroadcaster();
				
			return _instance;
		}
		
		// UTILITIES //////////

		/**
		 * Command you call passing an AppEvent.  These events
		 * get dispatched to everyone listening for that app
		 * event and any commands registered to that command
		 * get executed.
		 */
		public static function dispatchAppEvent(e:AppEvent):void
		{
			for each (var commandClass:Class in getInstance().getCommands(e.type))
			{
				var c:AppCommand = new commandClass();
				
				var classInfo:Object = ObjectUtil.getClassInfo(e, ["bubbles", "cancelable", "currentTarget", "eventPhase", "target", "type"], {includeReadOnly:true, includeTransient:true});

				for each (var a:QName in classInfo.properties)
				{
					var prop:String = a.localName;
					if(c.hasOwnProperty(prop))
						c[prop] = e[prop];
				}
						
				c.execute();
			}
			
			getInstance().dispatchEvent(e);
		}
		
		/**
		 * Register a command with an AppEvent.  When the event 
		 * is dispatched the command will be executed.
		 * 
		 * Call unregisterCommand() to seperate the relationship.
		 * 
		 * @param commandClass CLASS of the command that will be
		 * created and excuted with the event is dispatched
		 * 
		 * @param eventType String name of the event that will be
		 * dispatched that causes the command to be created and
		 * executed.
		 */
		public function registerCommand(commandClass:Class, eventType:String):void
		{
			var commands:Array = commandHash[eventType];
			if(!commands) commands = [];
			commands.push(commandClass);
			commandHash[eventType] = commands;
		}
		
		/**
		 * Removes the relationship between an eventType and
		 * a command class
		 */
		public function unregisterCommand(commandClass:Class, eventType:String):void
		{
			var commands:Array = getCommands(eventType);

			if(commands == null) 
				return;
			
			var newCommands:Array = [];
			for each(var c:Class in commands)
			{
				if(c != commandClass)
					newCommands.push(c);
			}
			
			commandHash[eventType] = newCommands;
		}
		
		/**
		 * Returns an array of all of the commands that are 
		 * registerd to the given eventType.
		 * 
		 * @param eventType String of the event type
		 */
		public function getCommands(eventType:String):Array
		{
			return commandHash[eventType];
		} 

		/**
		 * addEventListener is overridden to default to use weak references
		 */ 
		override public function addEventListener(type:String, listener:Function, useCapture:Boolean=false, priority:int=0, useWeakReference:Boolean=true):void
		{
			super.addEventListener(type, listener, useCapture, priority, useWeakReference);
		}

	}
}