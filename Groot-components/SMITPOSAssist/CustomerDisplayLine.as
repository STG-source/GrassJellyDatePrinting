package SMITPOSAssist
{
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.utils.ByteArray;

	public class CustomerDisplayLine extends POSAssist
	{
		/**
		 * Following commands are from the customer display
		 * Model VFD-870(470) Thai
		 **/
		public static const VFD870_LINE_LENGTH:int = 30; // 2 x 30
		public static const VFD650_LINE_LENGTH:int = 20; // 2 x 20
		public static const PD360R_LINE_LENGTH:int = 20; // 2 x 20
		public static const WINTEC_ANYPOS100_LINE_LENGTH:int = 20; // 2 x 20

		public static const MODEL_VFD870:String = "VFD870";
		public static const MODEL_VFD650:String = "VFD650";
		public static const MODEL_PD360R:String = "PD603R";
		public static const MODEL_WINTECH_ANYPOS100:String = "WINTEC_ANYPOS100";
		public static const MODEL_UNKNOWN:String = "UNKNOWN";

		public static const DISP_CLEAR:int = 0x0C;
		public static const DISP_MOVECUR_LEFTMOST:int = 0x0D;
		public static const DISP_MOVECUR_DOWN:int = 0x0A;
		public static const DISP_MOVECUR_RIGHT:int = 0x09;
		public static const DISP_CURSOR_ON:int = 0x13;  // [TBC]
		public static const DISP_CURSOR_OFF:int = 0x14;  // [TBC]

		public static const DISPBA_DISPTIME:Array = [0x1F, 0x55];
		public static const DISPBA_NEWLINE:Array = [DISP_MOVECUR_DOWN, DISP_MOVECUR_LEFTMOST];
		public static const DISPBA_GOTO_LINENO:Array = [0x1F, 0x24, 0x00, 0x00];

		protected var _objConnectCloseFunc:Function = null;
		protected var _objSocketErrorFunc:Function    = null;
		
		protected var _connectedDeviceModel:String = MODEL_VFD650;
		protected var _characterInRow:int = 20;
		protected var _displayRow:int = 2;

		public function CustomerDisplayLine(caller:Function=null)
		{
			super(caller);
		}

		public function get objConnectCloseFunc():Function
		{
			return _objConnectCloseFunc;
		}

		public function set objConnectCloseFunc(objFunc:Function):void
		{
			_objConnectCloseFunc = objFunc;
		}

		public function get characterInRow():int
		{
			return _characterInRow;
		}

		public function get displayRow():int
		{
			return _displayRow;
		}

		private var _currentCusDisplayPort:Object = NET_CUSTOMER_DISPLAY;
		/** this overrideDisplayPort will force SRPOS use new customer display port
		 * , it can override socketPort argument from function " connect() " **/

		public function overrideDisplayPort(newPort:Number):void{
			_currentCusDisplayPort = newPort;
		}
		/** this resetDisplayPort will reset current display port and make "connect()" work normally **/
		public function resetDisplayPort():void{
			_currentCusDisplayPort = null;
		}

		// advice to revise this logic with SOLID (Principles of Object Oriented Design)
		// for make this logic more easily add new model feature
		public function setConnectedDevice(model:String):void
		{
			_connectedDeviceModel = "MODEL_UNKNOWN";

			switch (model) {
				case MODEL_VFD870 :
					_connectedDeviceModel = model;
					_currentCusDisplayPort = NET_CUSTOMER_DISPLAY; // port COM4 or 5334
					_characterInRow = 30;
					_displayRow = 2;
					break;
				case MODEL_VFD650 :
				case MODEL_PD360R :
					_connectedDeviceModel = model;
					_currentCusDisplayPort = NET_CUSTOMER_DISPLAY; // port COM4 or 5334
					break;
				case MODEL_WINTECH_ANYPOS100 :
					_connectedDeviceModel = model;
					_currentCusDisplayPort = 5336; // port COM6 or 5336
					_characterInRow = 20;
					_displayRow = 2;
					break;
				default:
					_currentCusDisplayPort = NET_CUSTOMER_DISPLAY; // port COM4 or 5334
					_characterInRow = 20;
					_displayRow = 2;
					break;
			}
		}

		public function addCloseSocketEventListener(listener:Function, priority:int=-2):void
		{
			/** Note: set priority to -2 by default to the lowest level **/
			super.mainSocket.addEventListener(Event.CLOSE, listener, false, priority);
			objConnectCloseFunc = listener;
		}

		public function addSocketErrorEventListener(listener:Function, priority:int=-2):void
		{
			/** Note: set priority to -2 by default to the lowest level **/
			super.mainSocket.addEventListener(IOErrorEvent.IO_ERROR, listener, false, priority);
			_objSocketErrorFunc = listener;
		}

		override public function connect(socketIPAddr:String=DEFAULT_HOST,
										 socketPort:Number=NET_CUSTOMER_DISPLAY):int
		{
			if(_currentCusDisplayPort is Number)
			{
				socketPort = _currentCusDisplayPort as Number;
			}
			/** Note: set priority to -1  **/
			super.mainSocket.addEventListener(Event.CLOSE, closeConnection, false, -1);
			return super.connect(socketIPAddr, socketPort);
		}

		public function writeDispCmd(hexCmd:Object):void
		{
			var cmdArray:Array;
			var hexArray:ByteArray;

			if (!mainSocket.connected) {
				trace('Re-connect to POSAssist...');
				this.connect();
			}

			if (hexCmd is Array) {
				hexArray = new ByteArray;
				cmdArray= hexCmd as Array;
				for (var j:int = 0; j < cmdArray.length; j++)
					hexArray.writeByte(cmdArray[j]);
			}
			else if (hexCmd is int) {
				hexArray = new ByteArray;
				hexArray.writeByte(int(hexCmd));
			}
			else if (hexCmd is ByteArray) {
				// trace("Write this array command directly.");
				hexArray = hexCmd as ByteArray;
			}
			else {
				trace("Skipped ** UNKNOWN TYPE **");
				return;
			}

			super.mainSocket.writeBytes(hexArray, 0, hexArray.length);
			super.mainSocket.flush();
		}

		public function clearDisplay():void
		{
			var bbyte:ByteArray = new ByteArray;
			bbyte.writeByte(DISP_CLEAR);
			writeDispCmd(bbyte);
		}

		public function cursorOn():void
		{  // [TBC]
			var bbyte:ByteArray = new ByteArray;
			bbyte.writeByte(DISP_CURSOR_ON);
			writeDispCmd(bbyte);
		}

		public function cursorOff():void
		{  // [TBC]
			var bbyte:ByteArray = new ByteArray;
			bbyte.writeByte(DISP_CURSOR_OFF);
			writeDispCmd(bbyte);
		}

		public function closeConnection(event:Event):void
		{
			trace("|-- CustomerDisplayLine Connection CloseHandler: " + event);
		}

	}
}