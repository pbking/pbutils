package com.pbking.app.command
{
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	import flash.utils.getQualifiedClassName;
	
	import mx.messaging.messages.AcknowledgeMessage;
	import mx.rpc.IResponder;
	import mx.rpc.events.ResultEvent;
	
	/**
	 * The ServiceCommand extends the AsyncCommand and adds IResponder handling.
	 * 
	 * The result and fault should be handled in handleResult() and handleFault() methods.
	 * 
	 * The error message is generated from the fault and placed in the commands read-only property errorMessage.
	 * 
	 * A .success property is added to show the success of the service call.
	 * 
	 * This command also adds the ability to 'pretend' to call a service.  This is usefull
	 * during development for constructing commands that rely on hard-coded mock data 
	 * that operate async before your services are in place.
	 * 
	 * @author Jason Crist
	 */
	public class ServiceCommand extends AsyncCommand implements IResponder
	{
		// VARIABLES //////////
		
		protected var _errorMessage:String;
		public function get errorMessage():String { return _errorMessage; }
		
		protected var _rawResult:Object;
		public function getRawResult():Object { return _rawResult; }
		
		// CONSTRUCTION //////////
		
		public function ServiceCommand(executeImmediately:Boolean = false)
		{
			super(executeImmediately);
		}
		
		// METHODS //////////
		
		public function result(result:Object):void
		{
			_rawResult = result;
			
			var re:ResultEvent = result as ResultEvent;
			
			if(re && (re.result || re.message is AcknowledgeMessage))
			{
				this._success = true;

				if(re.result)
				{
					logger.debug("service result:" + re.result.toString());
					handleResult(re.result);
				}
				else 
				{
					logger.debug("service acknowledgement");	
					handleResult(true);
				}
				
				onComplete();
			}
			else
			{
				logger.warn("I don't know how to handle the result of type: " + getQualifiedClassName(result));
				_success = false;
				fault(result);
			}
		}
		
		public function fault(result:Object):void
		{
			_success = false;
	
			_errorMessage = result.toString();
			logger.warn("service fault:" + _errorMessage);
			
			handleFault(result);

			onComplete();
		}
		
		protected function handleResult(result:Object):void
		{
			//child classes should override this
		}
		
		protected function handleFault(result:Object):void
		{
			//child classes should override this
		}
		
		// DEBUG UTILS //////////
		
		private var pretendResult:Object;
		private var pretendTimer:Timer;
		
		protected function pretendToCall(result:Object):void
		{
			pretendResult = result;
			pretendTimer = new Timer(500, 1);
			pretendTimer.addEventListener(TimerEvent.TIMER_COMPLETE, pretendCallResult);
			pretendTimer.start();
		}
		
		private function pretendCallResult(e:TimerEvent):void
		{
			pretendTimer.stop();
			pretendTimer.removeEventListener(TimerEvent.TIMER_COMPLETE, pretendCallResult);
			
			this._success = true;
			handleResult(pretendResult);
			onComplete();			
		}
	}
}