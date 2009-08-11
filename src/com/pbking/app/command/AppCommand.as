package com.pbking.app.command
{
	import com.pbking.util.logging.PBLogger;
	
	import flash.events.EventDispatcher;

	/**
	 * This is the BASE command for applications
	 * 
	 * Call the public method "execute()" to trigger the command's logic.  This logic
	 * should be contained in the internal handleExecution() method.  Keep in mind that
	 * unless you pass TRUE to this class' constructor the command logic WILL NOT 
	 * AUTOMATICALLY TRIGGER.
	 * 
	 * These command can be instantiated using MXML.
	 * 
	 * @param	executeImmediately	TRUE if you want the command logic to execute immediately.
	 * 								The default is FALSE
	 * 
	 * @author Jason Crist
	 */
	public class AppCommand extends EventDispatcher
	{
		// VARIABLES /////////////
		
		protected var logger:PBLogger;
		protected var executeImmediately:Boolean;
		
		public static var _undoableCommands:Array = [];
		public static var MAXIMUM_UNDO_HISTORY:int = 100;
		
		public static var LOGGING_CATEGORY:String = "pbking.command";
		
		protected var _undoable:Boolean = false;
		
		// GETTERS and SETTERS //////////
		
		public function get undoable():Boolean { return _undoable; }
		
		public static function get undoableCommands():Array { return _undoableCommands; }
		
		// CONSTRUCTION //////////
		
		public function AppCommand(executeImmediately:Boolean = false)
		{
			super();
			
			logger = PBLogger.getLogger(LOGGING_CATEGORY);
			
			this.executeImmediately = executeImmediately;
			
			if(executeImmediately)
				execute();
		}
		
		// METHODS //////////
		
		/**
		 * the method to call to cause the commands logic to execute.
		 * This method should (probably) NOT be overridden for your
		 * command logic.  Override handleExecution for that.
		 */
		public function execute():void
		{
			handleExecution();

			if(undoable)
				addToUndoableList(this);
		}
		
		/**
		 * Execute a command's undo logic.  Normall you will call the static
		 * undoLast() which handles the removal from the exected list and such.
		 */
		public function undo():void
		{
			if(_undoable)
				handleUndo();
		}
		
		protected static function addToUndoableList(c:AppCommand):void
		{
			if(c.undoable)
				undoableCommands.push(c);
			
			if(undoableCommands.length > MAXIMUM_UNDO_HISTORY)
				undoableCommands.shift();
		}
		
		public static function undoLast():AppCommand
		{
			if(undoableCommands.length == 0)
				return null;
			
			var c:AppCommand = undoableCommands.pop();
			if(c.undoable)
			{
				c.handleUndo();
				return c;
			}
			return null;
		}
		
		/**
		 * override this method in child classes to house the execution logic
		 */
		protected function handleExecution():void
		{
			//child classes MUST override this
			throw new Error("no execution logic");
		}
		
		protected function handleUndo():void
		{
			//child classes MUST override this IF the command is undoable
			throw new Error("no undo logic");
		}
	}
}