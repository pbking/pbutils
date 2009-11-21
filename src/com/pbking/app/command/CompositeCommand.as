package com.pbking.app.command
{
	/**
	 * A Composite command allows for the collection of commands (including ServiceCommands
	 * and even other CompositeCommands) either in serial or parallel.
	 * 
	 * This can either be used stand-alone (by instantiating CompositeCommand and passing commands to
	 * addChildCommand) or extended to embody a collection of commands.
	 * 
	 * The public property .concurrant dictates the type of execution.  TRUE for parallel FALSE for serial.
	 * 
	 * @author Jason Crist
	 */
	public class CompositeCommand extends AsyncCommand
	{
		// VARIABLES //////////
		
		public var failImmediatelyOnError:Boolean = false;
		public var concurrant:Boolean;
		protected var commands:Array = [];
		
		protected var _errorMessage:String;
		public function get errorMessage():String { return _errorMessage; }

		protected var _errorCount:int;
		public function get errorCount():int { return _errorCount; }
		
		// CONSTRUCTION //////////
		
		public function CompositeCommand(executeImmediately:Boolean = false)
		{
			super(executeImmediately);
		}
		
		// METHODS //////////
		
		/**
		 * Add a command to be executed.
		 * 
		 * @param command The command to be executed
		 */
		public function addChildCommand(command:AppCommand):void
		{
			if(command is AsyncCommand)
				AsyncCommand(command).addCallback(onCommandComplete);
			
			commands.push(command);
		}
		
		override protected function handleExecution():void
		{
			if(concurrant)
			{
				while(commands.length > 0)
					commands.shift().execute();
			}
			else
			{
				executeNextCommand();
			}
		}
		
		/**
		 * This is called when one of the children commands has completed.
		 * It will either execute the next command in the list or, if 
		 * all of the child commands are finished, will complete itself.
		 */
		protected function onCommandComplete(command:AsyncCommand):void
		{
			if(!command.success)
			{
				_success = false;
				_errorCount++;
				
				if(command.hasOwnProperty("errorMessage"))
				{
					if(_errorMessage == null)
						_errorMessage = "";
						
					_errorMessage += command['errorMessage'];
				}
				
				if(failImmediatelyOnError)
				{
					onComplete();
					return;
				}
			}

			executeNextCommand();
		}
		
		/**
		 * Execute the next command in the list
		 */
		protected function executeNextCommand():void
		{
			if(commands.length == 0)
			{
				onComplete();
				return;
			}

			if (!concurrant)
			{
				var nextCommand:AppCommand = commands.shift();
				nextCommand.execute();
			
				if(!(nextCommand is AsyncCommand))
					executeNextCommand();
			}
				
		}
	}
}