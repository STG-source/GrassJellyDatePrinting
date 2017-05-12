package SystemBase
{
	public class POSAssistOperation
	{
		private var _objPOSAssist:Object = null;

		public function POSAssistOperation(parentAppObj:Object = null)
		{
			if (parentAppObj == null)
				return;

			try {
				if (parentAppObj._posAssistObj != null)
					_objPOSAssist = parentAppObj._posAssistObj;
			}
			catch(e:Error) {
				trace("POSAssistOperation Constructor - CATCH: " + e);
				return;
			}

			trace("POSAssistOperation construct can assign _objPOSAssist");
		}

		public function set objPOSAssist(obj:Object):void
		{
			_objPOSAssist = obj;
		}

		public function get objPOSAssist():Object
		{
			return _objPOSAssist;
		}

		protected function traceError(err:Error):void
		{
			trace("POSAssistOperation - CATCH Error: " + err);
		}

		public function directPrintLabel(prnText:String):void
		{
			try {
				_objPOSAssist.reconnect();
				_objPOSAssist.printLabel(prnText);
				_objPOSAssist.mainSocket.flush();
			}
			catch(e:Error) {
				traceError(e);
				return;
			}
		}

		public function directKitchenPrint(prnText:String):void
		{
			try {
				_objPOSAssist.reconnect();
				_objPOSAssist.printToKitchen(prnText);
				_objPOSAssist.mainSocket.flush();
			}
			catch(e:Error) {
				traceError(e);
				return;
			}
		}

		public function doForcePrinting():void
		{
			try{
				_objPOSAssist.forcePrintSlip();
			}
			catch(e:Error) {
				traceError(e);
				return;
			}
		}

		public function unlockCashDrawer():void
		{
			try{
				_objPOSAssist.unlockCashDrawer();
			}
			catch(e:Error) {
				traceError(e);
				return;
			}
		}

	}
}
