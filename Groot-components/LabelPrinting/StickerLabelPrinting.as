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

		public function StickerLabelPrinting()
		{
			// Init PosAssist
			_posAssistObj = new POSAssist();
			_posAssistObj.connect(POSAssist.DEFAULT_HOST_2,POSAssist.DEFAULT_PORT);

			_posAssistOperation = new POSAssistOperation();
			_posAssistOperation.objPOSAssist = _posAssistObj;
			// Init PosAssistOperation
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
			if(_quantities <= 0)
			{
				trace("No Sticker to Print");
				_isBusy = false;
				_fail();
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
					_timer.stop();
					_timer.reset();
					_done();
					_isBusy = false;
				});
				_timer.start();
				_isBusy = true;
				// TBC
			}catch(err:Error){
				_fail();
				_isBusy = false;
			};
		}
		
		public function stop():void{

			if(_timer == null)
				return;

			_timer.stop();
			_timer.reset();

			var waitForPrint:Timer = new Timer(1000,1);
			waitForPrint.addEventListener(TimerEvent.TIMER_COMPLETE,function(event:TimerEvent):void{
				_cancel();
				_isBusy = false;
			});
			waitForPrint.start();
		}
	}
}