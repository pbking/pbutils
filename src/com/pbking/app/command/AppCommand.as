package com.pbking.app.command
{
	import com.pbking.util.logging.PBLogger;
	
	import flash.events.EventDispatcher;

	/**
	 * This is the BASE class commands
	 * 
	 * Call the public method "execute()" to trigger the command's logic.  This logic
	 * must be contained in an overridden handleExecution() method.
	 * 
	 * Keep in mind that unless you pass TRUE to this class' constructor the command 
	 * logic WILL NOT AUTOMATICALLY TRIGGER and you must call .execute().  Calling
	 * execute is standard procedure.
	 * 
	 * All commands extend from this command.  It is a syncrynous command.  
	 * 
	 * If you want your command to be undoable then you must set the _undoable property
	 * to true (usually in your constructor) and handle all of your undo logic yourself.
	 * Undoable commands are tracked by this class.  You can get a list of commands
	 * that can be undone or simply undo the last undoable command.  The maximum undoable
	 * history default to 100 commands.  That can be changed.
	 * 
	 * The command framework uses the PBLogger logging framework for all logging.  The
	 * default cagetory for all commands is 'pbking.command'.  You can change that 
	 * default value and ALL commands built with this framework will default to your
	 * new default.
	 * 
	 * These commands can be instantiated using MXML.  Keep in mind that if you wish to
	 * do so that the prameters in the constructor must default to something (often null)
	 * and all of the props you operate on need to be public.
	 * 
	 * Usage:
	 * <code>
	 * var c:MyCommand = new MyCommand();
	 * c.someProp = "banana";
	 * c.execute();
	 * logger.debug(c.bakingResult);
	 * </code>
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