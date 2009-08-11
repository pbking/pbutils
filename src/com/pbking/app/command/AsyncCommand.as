package com.pbking.app.command
{
	import flash.events.Event;
	import flash.utils.Dictionary;
	
	[Event(name="complete", type="flash.events.Event")]

	/**
	 * This adds the ability to listen to when an event completes. 
	 *  
	 * The special callback() event passes the <b>Command Instance</b> to the target method
	 * instead of the actual EVENT that is dispatched when COMPLETE is triggered. This
	 * listener is AUTOMATICALLY removed once the command has completed.
	 * 
	 * Usage:
	 * <code>
	 * function triggerCommand()
	 * {
	 *  var c:ExtendedAsyncCommand = new ExtendedAsyncCommand(param);
	 *  c.addCallback(onCommandComplete);
	 *  c.execute();
	 * }
	 * 
	 * function onCommandComplete(c:ExtendedAsyncCommand):void
	 * {
	 *  //no need to remove listeners, type the event.target, etc
	 *  trace(c.someCustomResultProp);
	 * }
	 * </code>
	 * 
	 * @author Jason Crist
	 */
	public class AsyncCommand extends AppCommand
	{
		// VARIABLES //////////
		
		/**
		 * The executingCommands property is used to keep "unreferenced" commands
		 * from being garbage collected.  This allows you to execute a command thusly:
		 * 
		 * new ExtendedAsyncCommand(param).addCallback(onCommandComplete);
		 * 
		 * without the need to having a class reference of your command, without fear of 
		 * the garbage collection and without the need to add/remove COMPLETE event listeners
		 */
		private static var executingCommands:Dictionary = new Dictionary();
		
		private var _complete:Boolean;
		private var _executing:Boolean;
		private var _myEventListeners:Array = [];
		
		protected var _success:Boolean = true;
		
		public const CALLBACK:String = "callbackEvent";
		
		// CONSTRUCTION //////////
		
		public function AsyncCommand(executeImmediately:Boolean = false)
		{
			super(executeImmediately);
		}
		
		// METHODS //////////
		
		[Bindable]
		public function get complete():Boolean { return _complete; }
		public function set complete(newVal:Boolean):void { /*for binding*/ }
		
		[Bindable]
		public function get executing():Boolean { return _executing; }
		public function set executing(newVal:Boolean):void { /*for binding*/ }

		[Bindable]
		public function get success():Boolean { return _success; }
		public function set success(newVal:Boolean):void { /*for binding*/ }

		override public function execute():void
		{
			if(!_executing)
			{
				_complete = false;
				_executing = true;
				
				executingCommands[this] = true;
				
				super.execute();
			}
		}

		public function addCallback(func:Function):void
		{
			this.addEventListener(CALLBACK, func);
		}
		
		protected function onComplete():void
		{
			this._complete = true;
			this._executing = false;
			
			dispatchEvent(new Event(Event.COMPLETE));
			
			for each(var lo:ListenerObject in _myEventListeners)
			{
				if (lo.type == CALLBACK)
				{
					lo.listener(this);
					this.removeEventListener(lo.type, lo.listener, lo.useCapture);
				} 
			}
			
			if(undoable)
				AppCommand.addToUndoableList(this);

			delete executingCommands[this];
			
		}
		
		public function removeAllListeners():void
		{
			for each(var lo:ListenerObject in this._myEventListeners)
			{
				super.removeEventListener(lo.type, lo.listener, lo.useCapture);
			}
			_myEventListeners = [];
		}
		
		override public function addEventListener(type:String, listener:Function, useCapture:Boolean=false, priority:int=0, useWeakReference:Boolean=false):void
		{
			super.addEventListener(type, listener, useCapture, priority, useWeakReference);
			_myEventListeners.push(new ListenerObject(type, listener, useCapture));
		}
		
		override public function removeEventListener(type:String, listener:Function, useCapture:Boolean=false):void
		{
			super.removeEventListener(type, listener, useCapture);

			//I'm sure this should be more effecient
			var savedListeners:Array = [];
			for each(var lo:ListenerObject in this._myEventListeners)
			{
				if(lo.type != type || lo.listener != listener || lo.useCapture != useCapture)
				{
					savedListeners.push(lo);
				}
			}
			this._myEventListeners = savedListeners;
		}
	}
}

class ListenerObject
{
	public var type:String;
	public var listener:Function;
	public var useCapture:Boolean;
	
	function ListenerObject(type:String, listener:Function, useCapture:Boolean)
	{
		this.type = type;
		this.listener = listener;
		this.useCapture = useCapture;
	}
}