package com.pbking.app.event
{
	import com.pbking.app.command.AppCommand;
	
	import flash.events.EventDispatcher;
	import flash.utils.Dictionary;
	
	import mx.utils.ObjectUtil;
	
	public class GlobalEventBroadcaster extends EventDispatcher
	{
		// VARIABLES //////////
		
		private static var _instance:GlobalEventBroadcaster;
		protected var commandHash:Dictionary = new Dictionary();
		
		// CONSTRUCTION //////////
		
		public function GlobalEventBroadcaster()
		{
			super();
		}

		public static function getInstance():GlobalEventBroadcaster
		{
			if(!_instance)
				_instance = new GlobalEventBroadcaster();
				
			return _instance;
		}
		
		// UTILITIES //////////

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
		
		public function registerCommand(commandClass:Class, eventType:String):void
		{
			var commands:Array = commandHash[eventType];
			if(!commands) commands = [];
			commands.push(commandClass);
			commandHash[eventType] = commands;
		}
		
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
		
		public function getCommands(eventType:String):Array
		{
			return commandHash[eventType];
		} 

		override public function addEventListener(type:String, listener:Function, useCapture:Boolean=false, priority:int=0, useWeakReference:Boolean=true):void
		{
			super.addEventListener(type, listener, useCapture, priority, useWeakReference);
		}

	}
}