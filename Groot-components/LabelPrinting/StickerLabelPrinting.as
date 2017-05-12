package LabelPrinting
{
	import SMITPOSAssist.POSAssist;

	import SystemBase.POSAssistOperation;

	import flash.events.*;
	import flash.utils.*;

	import spark.skins.spark.StackedFormHeadingSkin;

	public dynamic class StickerLabelPrinting implements IPrintable
	{
		private var _timer:Timer;
		private var _posAssistObj:POSAssist;
		private var _posAssistOperation:POSAssistOperation;

		public static const REASON_POSASSIST_DISCONNECTED:String = "POSAssist disconnected";
		public static const REASON_HAS_NO_ANY_STICKER:String = "has no any sticker";
		public static const RECONNECT_TIME_MS:int = 1000;
		public static const WAIT_PRINT_TIME_MS:int = 1000; // wait for print time (ms)

		public function StickerLabelPrinting()
		{
			// Init PosAssist
			_posAssistObj = new POSAssist();
			_posAssistObj.connect(POSAssist.DEFAULT_HOST_2,POSAssist.DEFAULT_PORT);
			_posAssistObj.POSAssistListener(Event.CLOSE,reconnect);
			_posAssistObj.POSAssistListener(IOErrorEvent.IO_ERROR,reconnect);

			_posAssistOperation = new POSAssistOperation();
			_posAssistOperation.objPOSAssist = _posAssistObj;
			// Init PosAssistOperation
		}

		private var reconnecterTimer:Timer = null;
		public function reconnect(obj:Object):void{
			if(reconnecterTimer == null)
			{
				reconnecterTimer = new Timer(RECONNECT_TIME_MS,0);
				reconnecterTimer.addEventListener(TimerEvent.TIMER,function():void{
					if(_posAssistObj.mainSocket.connected){
						reconnecterTimer.stop();
					}
					else{
						_posAssistObj.reconnect();
					}
				});
			}
			reconnecterTimer.start();
		}

		private var _isBusy:Boolean = false;
		public function get isBusy():Boolean{
			return _isBusy;
		}

		private var _textLabel:String = null;
		public function set setTextLabel(data:Object):void{
			try{
				_textLabel = data.toString();
			}catch(err:Error){
				trace("================\nsetTextLabel Exception\n"+err.message+"\n================");
			}
		};

		public function resetTextLabel():void{
			_textLabel = null;
		};

		private var _quantities:Number = 1;
		public function set quantities(value:Number):void{

			if(value < 0 || isNaN(value))
				throw new Error("Sticker Number Our of range! , Please set the number that it higher than 0 or not \"NaN\"");

			_quantities = value;
		};

		private var _done:Function = function():void{};
		public function set done(func:Function):void
		{
			_done = func;
		}

		private var _fail:Function = function():void{};
		public function set fail(func:Function):void
		{
			_fail = func;
		}

		private var _cancel:Function = function():void{};
		public function set cancel(func:Function):void
		{
			_cancel = func;
		}

		public function printLabel():void
		{
			if(!_posAssistObj.mainSocket.connected)
			{
				trace("POSAssist hasn't connected yet");
				_fail(REASON_POSASSIST_DISCONNECTED);
				return;
			}
			else if(_quantities <= 0)
			{
				trace("No Sticker to Print");
				_isBusy = false;
				_fail(REASON_HAS_NO_ANY_STICKER);
				return;
			}
			else if(_isBusy)
			{
				trace("Printer is Busy!!");
				return;
			}
			try{
				_timer = new Timer(500,_quantities);
				_timer.addEventListener(TimerEvent.TIMER,function(event:TimerEvent):void{
					var textTemp:String = _textLabel.replace("\n","\n"+_timer.currentCount)
					_posAssistOperation.directPrintLabel(textTemp);
					trace("สินค้าชิ้นที่ : "+_timer.currentCount +"\n"+"Label is "+_textLabel+"\n");
				});
				_timer.addEventListener(TimerEvent.TIMER_COMPLETE,function(event:TimerEvent):void{
					trace("Completed!");
					_timer.reset();
					_done();
					_isBusy = false;
				});
				_timer.start();
				_isBusy = true;
				// TBC
			}catch(err:Error){
				_fail();
				_timer.reset();
				_isBusy = false;
			};
		}

		public function stop():void { throw new Error("stop() : NotImplementedException!"); }
		public function reset():void{

			if(_timer == null)
				return;

			_timer.reset();

			var waitForPrint:Timer = new Timer(WAIT_PRINT_TIME_MS,1);
			waitForPrint.addEventListener(TimerEvent.TIMER_COMPLETE,function(event:TimerEvent):void{
				_cancel();
				_isBusy = false;
			});
			waitForPrint.start();
		}
	}
}