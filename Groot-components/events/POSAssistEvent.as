package events
{
	import flash.events.Event;
	
	public class POSAssistEvent extends Event
	{
		public static const CADR_JUST_CLOSE:String           = "CadrJustClose";
		public static const CADR_JUST_OPEN:String			 = "CadrJustOpen";
		public static const CADR_WAIT_TOCLOSE_TIMEOUT:String = "CadrWaitToCloseTimeout";

		public static const RESULT_CMD_RFID_REQ_CARD_ID_SL500:String
			= "Result_CMD_RFID_REQ_CARD_ID_SL500";

		protected var _eventObj:Object;


		public function POSAssistEvent(type:String, eventObj:Object = null)
		{
			super(type);

			this._eventObj = eventObj;
		}

		override public function clone():Event
		{
			return new POSAssistEvent(type, _eventObj);
		}

		public function get eventObj():Object
		{
			return _eventObj;
		}

	}
}

