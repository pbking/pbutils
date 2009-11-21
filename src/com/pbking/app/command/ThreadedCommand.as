package com.pbking.app.command
{
	import com.ender.managers.ThreadManager;
	import com.ender.threads.IRunnable;
	import com.ender.threads.IThread;
	import com.ender.threads.Thread;
	
	import flash.events.ProgressEvent;
	import flash.utils.getTimer;

	/**
	 * This threaded command is based on the Ender framework.  Is is only PSUDO-threaded.
	 * Your logic should happen in interations and you classes should handle all of the
	 * information that should be persisted across the iterations.
	 * 
	 * The class does have some promitive optimization logic that will help set the 
	 * number of iterations that happen on each run.
	 * 
	 * Unlike the rest of the commands your execution logic should be placed in an
	 * overridden handleRun() method.  In this method should be the logic for ONE iteration.
	 * When your iteration is complete call the yield() method to return control to the
	 * flash player (to allow screen updates, etc).  When yeld is called you can optionall
	 * pass a percentComplete value (if you know).  A progressEvent will be dispatched
	 * from this event every time yield is called.
	 * 
	 * It's kinda tricky to use this command so a good example is needed.  Using this command
	 * WILL lengthen the total amount of time it takes to process something.  But allowing
	 * the Flash player to continue processing is necessary during long calculations & parsings.
	 */
	public class ThreadedCommand extends AsyncCommand implements IThread, IRunnable
	{
		// VARIABLES //////////
		
		protected var _priority:int = Thread.HIGH_PRIORITY;
		
		public var minimumIterationsPerRun:int = 1;
		public var iterationsPerRun:int = 1000;
		public var autoOptimizeIterations:Boolean = true;
		
		protected var iterationCount:int = 0;
		protected var runStartTime:int;
		protected var runLength:int;
		
		public static var optimizationAccuracy:int = 50;
		public static var optimalRunLength:int = 500;
		

		// GETTERS and SETTERS //////////
		
		public function get priority():int { return _priority; }
		public function set priority(value:int):void { _priority = value; }
		
		public function get runnable():IRunnable { return this; }
		
		// CONSTRUCTION //////////
		
		public function ThreadedCommand(executeImmediately:Boolean=false)
		{
			super(executeImmediately);
		}

		// UTILITIES //////////		
		
		override protected function handleExecution():void
		{
			ThreadManager.getInstance().addThread(this);
		}
		
		public function start():void
		{
			execute();
		}
		
		public function stop():void
		{
			ThreadManager.getInstance().removeThread(this);
		}
		
		public function run():void
		{
			iterationCount = 0;
			
			if(autoOptimizeIterations)
				runStartTime = getTimer();

			handleRun();
		}
		
		protected function handleRun():void
		{
			//this MUST be overridden
			throw new Error(ThreadManager.NO_RUN_IMPLEMENTATION_SIG);
		}
		
		public function yield(percentComplete:Number=0):void
		{
			if(autoOptimizeIterations)
			{
				runLength = getTimer() - runStartTime;

				if(Math.abs(runLength - optimalRunLength) > optimizationAccuracy)
				{
					iterationsPerRun = optimalRunLength*iterationsPerRun/runLength;
					if(iterationsPerRun < minimumIterationsPerRun)
						iterationsPerRun = minimumIterationsPerRun;
				}
			}
			
			percentComplete = Math.min(percentComplete, 100);
			percentComplete = Math.max(percentComplete, 0);

			this.dispatchEvent(new ProgressEvent(ProgressEvent.PROGRESS, false, false, percentComplete, 0));
			Thread.yield();
		}
		
		override protected function onComplete():void
		{
			stop();
			super.onComplete();
		}
		
	}
}