package SMITPOSAssist
{
	/** 
	 * Class POSAssist get idea from
	 * http://cookbooks.adobe.com/post_Read_Write_to_serial_port_from_Adobe_Air-17484.html
	 */

	import events.POSAssistEvent;

	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.events.SecurityErrorEvent;
	import flash.events.TimerEvent;
	import flash.net.Socket;
	import flash.utils.Timer;

	import mx.managers.SystemManager;

	[Event(name=POSAssistEvent.CADR_JUST_CLOSE,           type="events.POSAssistEvent")]
	[Event(name=POSAssistEvent.CADR_JUST_OPEN,            type="events.POSAssistEvent")]
	[Event(name=POSAssistEvent.CADR_WAIT_TOCLOSE_TIMEOUT, type="events.POSAssistEvent")]

	/**
	 * This class inherite from "EventDispatcher class" to
	 * take advantage for calling dispatchEvent() method.
	 */
	public class POSAssist extends EventDispatcher
	{
		public static const CMD_GET_BSCLINE:String  = "\tGET BSCLINE";
		public static const CMD_GET_CADRSTAT:String = "\tGET CADRSTAT";
		public static const CMD_UNLOCK_CADR:String  = "\tUNLOCKCADR";
		public static const CMD_FORCE_PRINT:String  = "\tFORCEPRINT";
		public static const CMD_PRINT_LABEL:String  = "\vPRINT_LABEL"; /* UNICODE sending format */
		public static const CMD_PRINT_TO_KITCHEN:String  = "\vKITCHEN_PRINT"; /* UNICODE sending format */
		public static const CMD_RFID_INIT_SL500:String = "\tRFID_INIT_SL500";
		public static const CMD_RFID_CLOSE_SL500:String = "\tRFID_CLOSE_SL500";
		public static const CMD_RFID_REQ_CARD_ID_SL500:String = "\tRFID_REQ_CARD_ID_SL500";

		public static const STATUS_OK:String 	 = "OK";
		public static const STATUS_NG:String 	 = "NG";
		public static const SPLIT_TEXT:String	 = "\\";

		/** [Message] */
		public static const UNKNOWN_MSG:String   = "UNKNOWN_COMMAND";
		public static const FIFO_EMPTY:String    = "FIFO_EMPTY";
		public static const FIFO_BUSY:String	 = "FIFO_BUSY";
		public static const CADR_OPEN:String	 = "CADR_OPEN";
		public static const CADR_CLOSE:String	 = "CADR_CLOSE";

		public static const MAIN_PORT:Number  = 5333;
		public static const MAIN_PORT_PS3315:Number  = 5331;

		public static const DEFAULT_HOST:String = "localhost";
		public static const DEFAULT_HOST_2:String = "127.0.0.1";
		public static const DEFAULT_PORT:Number = MAIN_PORT;

		/** Event listener, the higher the number, the higher the priority. */
		public static const HIGHEST_PRIORITY:int = 10;
		public static const MID_PRIORITY:int     = 5;

		/** Network Interface Port **/
		public static const NET_CASH_DRAWER:Number = MAIN_PORT;
		public static const NET_CASH_DRAWER_PS3315:Number = MAIN_PORT_PS3315;
		public static const NET_CUSTOMER_DISPLAY:Number = 5334;
		public static const NET_RFID_RW:Number = 5339;

		protected static const CMD_INTERVAL:Number = 10;  /** millisecond */
		protected static const LOOPCOUNT:Number    = 4;   /** CMD_INTERVAL x 4 */
		protected static const STARTLOOP:Number	 = 2;

		private static const CADR_STATE_LOOP_INTERVAL:Number = 500;         /** 1/2Sec        */
		private static const CADR_STATE_CHK_TIME:Number	  	 = 2 * 60 * 2;  /** Timeout: 2Min */

		protected var _mainSocket:Socket;
		protected var _prv_connected_address:String;
		protected var _prv_connected_port:int;

		protected var _netCmdTime:Timer;
		protected var _sleepAwhile:Timer;
		private var _cadrStatTime:Timer;

		public var _doCallFunc:Function;
		public var _reqCmd:String;

		public var recvBuffer:String;
		public var lastStatus:Number;
		public var returnValue:String;
		public var isBSCActive:Boolean;
		public var isCadrOpen:Boolean;
		public var lastCadrStatOpen:Boolean = false;  /** System initialization is required */

		public var itsOwner:DisplayObject;

		/**
		 * Constructor
		 */
		public function POSAssist(caller:Function = null)
		{
			/** Init socket connection */
			_mainSocket = new Socket();
			_mainSocket.addEventListener(Event.CONNECT, onConnectMainPort, false, HIGHEST_PRIORITY);
			this.POSAssistListener(Event.CONNECT, caller);

			_mainSocket.addEventListener(Event.CLOSE, onCloseMainPort);
			_mainSocket.addEventListener(ProgressEvent.SOCKET_DATA, onMainPortSocketData, false, HIGHEST_PRIORITY);
			_mainSocket.addEventListener(IOErrorEvent.IO_ERROR, onMainPortIOError, false, HIGHEST_PRIORITY);
			_mainSocket.addEventListener(SecurityErrorEvent.SECURITY_ERROR, securityErrorHandler);

			/** Command request mechanism */
			_netCmdTime = new Timer(CMD_INTERVAL, LOOPCOUNT);
			_netCmdTime.addEventListener(TimerEvent.TIMER, startCallCmdRWR);
			_netCmdTime.addEventListener(TimerEvent.TIMER_COMPLETE, cmdRWRReturn);

			_sleepAwhile = new Timer(CMD_INTERVAL, LOOPCOUNT/2);
			_sleepAwhile.addEventListener(TimerEvent.TIMER_COMPLETE, cmdRWRReturn);

			_cadrStatTime = new Timer(CADR_STATE_LOOP_INTERVAL, CADR_STATE_CHK_TIME);
			_cadrStatTime.addEventListener(TimerEvent.TIMER, cadrStatChkLoop);
			_cadrStatTime.addEventListener(TimerEvent.TIMER_COMPLETE, cadrStatChkTimeout);

			/** Trap the POSAssistEvent */
			addEventListener(POSAssistEvent.RESULT_CMD_RFID_REQ_CARD_ID_SL500, result_req_card_id, false, HIGHEST_PRIORITY);
		}

		public function get mainSocket():Socket
		{
			return _mainSocket;
		}

		public function POSAssistListener(type:String, listener:Function):int
		{
			var ret:int = 1; /** Default to done */

			if ((_mainSocket == null)||(listener == null))
				return -1;

			switch (type) {
				case Event.CONNECT:
					_mainSocket.addEventListener(Event.CONNECT, listener, false, MID_PRIORITY);
					break;
				case POSAssistEvent.RESULT_CMD_RFID_REQ_CARD_ID_SL500:
					addEventListener(type, listener, false, MID_PRIORITY);
					break;
				case Event.CLOSE:
					_mainSocket.addEventListener(Event.CLOSE, listener, false, MID_PRIORITY);
					break;
				case IOErrorEvent.IO_ERROR:
					_mainSocket.addEventListener(IOErrorEvent.IO_ERROR, listener, false, MID_PRIORITY);
					break;
				default:
					ret = -1;
					break;
			}

			/** In case fail */
			return ret;
		}

		/**
		 * Request to connect to POSAssist server
		 */
		public function connect(socketIPAddr:String  = DEFAULT_HOST, 
								socketPort:Number    = DEFAULT_PORT):int
		{
			var iResult:int = 0;

			/* trace('Connect to POSAssist Proxy @IP: ' + socketIPAddr + 
			' Port: '+ socketPort); */
			if ((MAIN_PORT    == socketPort  ) && 
				(DEFAULT_HOST == socketIPAddr || DEFAULT_HOST_2 == socketIPAddr)) {
				trace('Connect to POSAssist Proxy @Main Port');
				_mainSocket.connect(socketIPAddr, socketPort);

				iResult = 0;
			}
			else if (DEFAULT_HOST == socketIPAddr || DEFAULT_HOST_2 == socketIPAddr) {
				trace('Connect to POSAssist Proxy');
				_mainSocket.connect(socketIPAddr, socketPort);

				iResult = 0;
			}
			else {
				trace('Connect to UNKNOWN Server');
				iResult = -1;
			}

			return iResult;
		}

		public function reconnect():void{
			if (!_mainSocket.connected) {
				trace('Re-connect to POSAssist ...');
				if ((_prv_connected_address!=null)&&(_prv_connected_port!=0))
					this.connect(_prv_connected_address, _prv_connected_port);
				else
					this.connect();
			}
		}

		/**
		 * Request to disconnect from POSAssist server
		 */
		public function disconnect():void
		{
			trace('Disconnect POSAssist Proxy');
			if (true == _mainSocket.connected) {
				_mainSocket.close();
			}
			else {
				trace('Disconnect --> WITHOUT CLOSE');
			}
		}
		
		/**
		 * Handle close connection between POSAssist.
		 */
		private function onCloseMainPort(event:Event):void
		{
			trace("POSAssist Connection CloseHandler: " + event);
		}

		/**
		 * Handles POSAssist server connect successfully.
		 */
		private function onConnectMainPort(event:Event):void
		{
			// dispatchEvent(...)
			trace('Connect to POSAssist Proxy SUCCESSFULLY!');

			_prv_connected_address = _mainSocket.remoteAddress;
			_prv_connected_port    = _mainSocket.remotePort;

			/** Init default properties */
			isBSCActive = true; // NEED Double check
		}

		/**
		 * Handles on communication error
		 */
		private function onMainPortIOError(event:IOErrorEvent):void
		{
			// dispatchEvent(...)
			trace('POSAssist Proxy report: IO error');

			/** Init default properties */
			isBSCActive = false; // NEED Double check
		}

		/**
		 * To handle Security Error ...
		 * If this event have not been handled the following error will occur.
		 * Error #2044: Unhandled securityError:.
		 *   text=Error #2048: Security sandbox violation:
		 *   app:/POS_2011.swf cannot load data from "Server(POSAssist)"
		 */
		private function securityErrorHandler(event:SecurityErrorEvent):void
		{
			trace("POSAssist Proxy SecurityErrorHandler: " + "\n	--> " + event);
		}

		/**
		 * Called when data received from the socket connection
		 */
		private function onMainPortSocketData(event:ProgressEvent):void
		{
			try
			{
				recvBuffer = _mainSocket.readMultiByte(_mainSocket.bytesAvailable,
					"ISO-8859-1");

				/** Process data buffer, throw an event... */
				trace('recvBuffer: ' + recvBuffer);

				var arr:Array;
				arr = recvBuffer.split(SPLIT_TEXT);
				trace(arr[0] + " : " + arr[1] + " : " + arr[2]);

				if (arr[0] == CMD_RFID_REQ_CARD_ID_SL500) {
					var evData:Object = new Object;
					evData.status = arr[1];
					evData.data   = arr[2];

					var ev:POSAssistEvent = new POSAssistEvent(POSAssistEvent.RESULT_CMD_RFID_REQ_CARD_ID_SL500,
						evData);
					dispatchEvent(ev);
				}

			}
			catch(err:Error)
			{
				trace("POSAssist Catch Error: " + err);
				return;
			}
		}

		/**
		 * Send text command/data to POSAssist server
		 */
		public function sendTextDatCmd(txtDatCmd:String, charSet:String = "windows-874"):void
		{
			if (!_mainSocket.connected) {
				trace('sendTextDatCmd Re-connect to POSAssist ...');
				if ((_prv_connected_address!=null)&&(_prv_connected_port!=0))
					this.connect(_prv_connected_address, _prv_connected_port);
				else
					this.connect();

				/** Since it was the asynchronous routine,
				 *  operation such a read/write must do in the next turn.
				 **/
				return;
			}

			_mainSocket.writeMultiByte(txtDatCmd, charSet);

			/*************
			 * Testing stuff to putting text on a pole display DSP-870.
			 * Normally sending a set of text without the command header (\t)
			 * POSAssist will do forward those text to device directly.
			 * (devcn.cfg - comm_baud=9600 is required by the hardware power on default setting)
			 *
			 * _mainSocket.writeMultiByte(" ...ทดสอบภาษาไทย... ", "windows-874"); // OK
			 * or
			 * _mainSocket.writeMultiByte(" ...ทดสอบภาษาไทย... ", "iso-8859-11"); // TBC
			 *
			 * Using [http://help.adobe.com/en_US/FlashPlatform/reference/actionscript/3/flash/net/Socket.html#writeMultiByte(), writeMultiByte()]
			 * can send the text charater in multi format,
			 * see [http://help.adobe.com/en_US/FlashPlatform/reference/actionscript/3/charset-codes.html, Supported Character Sets]
			 *
			 * Developing on SMITDev Ticket #71
			 *************/

			_mainSocket.flush();
		}

		/**
		 * [R]equest & [W]ait to [R]eceive
		 * Request POSAssist server to check latest BSCLINE
		 * 
		 * [R]equest & ...
		 */
		public function cmdRWR(posAssistCmd:String, callFunc:Function):void
		{
			_reqCmd     = posAssistCmd;
			_doCallFunc = callFunc;

			trace('[cmdRWR]__call: ' + _reqCmd);
			_netCmdTime.start();
		}

		/**
		 * [W]ait to ...
		 */
		public function startCallCmdRWR(event:TimerEvent):void 
		{
			// displays the tick count so far
			// The target of this event is the Timer instance itself.
			// trace("tick " + event.target.currentCount);
			if (event.target.currentCount == STARTLOOP) {
				sendTextDatCmd(_reqCmd);
				trace('          |-- startCallCmdRWR @ ' + (event.target.currentCount * CMD_INTERVAL) + ' ms');
			}
		}

		/**
		 * [R]eceive
		 */
		public function cmdRWRReturn(event:TimerEvent):void
		{
			trace('             |__cmdRWRReturn');

			if (null != recvBuffer) {
				_netCmdTime.reset();

				if (recvBuffer.slice(0, 2) == STATUS_OK)
					lastStatus = 0;
				else if (recvBuffer.slice(0, 2) == STATUS_NG)
					lastStatus = -1;

				returnValue = recvBuffer.slice(3);
				recvBuffer  = ""; /** Clear receive buffer */

				if (null != _doCallFunc)
					_doCallFunc();
			}
			else {
				_sleepAwhile.reset();
				trace('             	|__Receive Buffer have not get data yet');
				_sleepAwhile.start();
				trace('             	|__Sleep For A While');
			}
		}

		/**
		 * To Send Unlock Cash Drawer Command
		 */
		public function unlockCashDrawer():void
		{
			trace('[cmd UNLOCK CASHDRAWER]__call: ');
			sendTextDatCmd(CMD_UNLOCK_CADR);
		}

		/**
		 * To Force System to Print Slip Out
		 */
		public function forcePrintSlip():void
		{
			trace('[cmd FORCE PRINT SLIP]__call: ');
			sendTextDatCmd(CMD_FORCE_PRINT);
		}

		/**
		 * To Get Cash Drawer Status
		 */
		public function getCashDrawerStatus():void
		{
			trace('[cmd GET CADR STATUS]__call: ');
			sendTextDatCmd(CMD_GET_CADRSTAT);
		}

		/**
		 * To start cash drawer loop detector
		 */
		public function cadrStatChkLoopStart():void
		{
			//if (!_mainSocket.connected) {
			trace("[WORKAROUND] - DROP CADR Status Loop Mornitor in V.1.8.Build201202");
			return;
			//}

			//cmdRWR(POSAssist.CMD_GET_CADRSTAT, retCADRStat);
			//_cadrStatTime.start();
		}

		/**
		 * Return current cash drawer status Open/Close
		 */
		protected function retCADRStat():void
		{
			trace('---> retCADRStat CALLED: ' + returnValue +
				' With return status[' + lastStatus + ']');

			if (returnValue == CADR_OPEN)
				isCadrOpen = true;
			else if (returnValue == CADR_CLOSE)
				isCadrOpen = false;

		}

		/**
		 * Loop detect cash drawer status
		 */
		protected function cadrStatChkLoop(event:TimerEvent):void
		{
			var eventObj:POSAssistEvent;
			var eventType:String;

			if (isCadrOpen) {
				trace('isCadrOpen: YES!');
				eventType = POSAssistEvent.CADR_JUST_OPEN;

				/** Re-check again in next loop */
				cmdRWR(POSAssist.CMD_GET_CADRSTAT, retCADRStat);
			}
			else {
				trace('isCadrOpen: NO!');
				_cadrStatTime.stop();
				_cadrStatTime.reset();

				eventType = POSAssistEvent.CADR_JUST_CLOSE;
			}

			if (isCadrOpen != lastCadrStatOpen) {
				/**
				 * To decrease number of event dispatch
				 */

				eventObj = new POSAssistEvent(eventType);
				SystemManager.getSWFRoot(this).dispatchEvent(eventObj);

				lastCadrStatOpen = isCadrOpen;
			}
		}

		/**
		 * Cash drawer status checking time out
		 */
		protected function cadrStatChkTimeout(event:TimerEvent):void
		{
			var eventObj:POSAssistEvent;

			trace('[  [cadrStatChkTimeout]  ]');
			_cadrStatTime.reset();

			eventObj = new POSAssistEvent(POSAssistEvent.CADR_WAIT_TOCLOSE_TIMEOUT);
			SystemManager.getSWFRoot(this).dispatchEvent(eventObj);
		}

		/**
		 * To print the label
		 */
		public function printLabel(prnText:String = null):void
		{
			trace('[cmd CMD_PRINT_LABEL]__call: ');

			//			var strCmd:String = CMD_PRINT_LABEL + 
			//				"\n007" +
			//				"\n50 - 3" +
			//				"\nชาองุ่น Grp Tea" +
			//				"\nGrape Tea Beauty Beauty" +
			//				"\nGJ/P/Full Ice/50%" +
			//				"\n17/05/2556" +
			//				"\n22:33" +
			//				"\n160B" +
			//				"\nTel 007 122 7889" +
			//				"\n";
			var strCmd:String = CMD_PRINT_LABEL + prnText;

			/** For label printing we have to sending in unicode format **/
			sendTextDatCmd(strCmd, "unicode"); 
			/** sendTextDatCmd(strCmd, "utf-8"); // [TBC] **/
		}

		/**
		 * To print the label
		 */
		public function printToKitchen(prnText:String = null):void
		{
			trace('[cmd CMD_PRINT_LABEL]__call: ');

			var strCmd:String = CMD_PRINT_TO_KITCHEN + prnText;

			/** Sending format is same to CMD_PRINT_LABEL **/
			sendTextDatCmd(strCmd, "unicode"); 
		}

		/**
		 * To initialize the SL500 Mifare RFID reader
		 */
		public function rfid_init_sl500():void
		{
			trace('[cmd CMD_RFID_INIT_SL500]__call: ');
			sendTextDatCmd(CMD_RFID_INIT_SL500);
		}

		/**
		 * To close the SL500 Mifare RFID reader
		 */
		public function rfid_close_sl500():void
		{
			trace('[cmd CMD_RFID_CLOSE_SL500]__call: ');
			sendTextDatCmd(CMD_RFID_CLOSE_SL500);
		}

		/**
		 * To request the SL500 Mifare RFID
		 */
		public function rfid_req_cardID_sl500():void
		{
			trace('[cmd CMD_RFID_REQ_CARD_ID_SL500]__call: ');
			sendTextDatCmd(CMD_RFID_REQ_CARD_ID_SL500);
		}

		protected function result_req_card_id(result:POSAssistEvent):void
		{
			if (result.eventObj.status == POSAssist.STATUS_OK)
				trace("POSAssist: result.return_eventObj.status == OK");
			else
				trace("POSAssist: result.return_eventObj.status == NG");

			/** Forward this message to itsOwner */
			if (itsOwner != null)
				itsOwner.dispatchEvent(result);
		}

	} /** class POSAssist */
} /** package SMITPOSAssist */