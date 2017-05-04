package Printing
{
	import SMITPOSAssist.POSAssist;
	
	import SystemBase.POSAssistOperation;
	
	import flash.events.*;
	import flash.utils.*;

	public dynamic class StickerLabel implements IPrintable
	{
		private var _timer:Timer;
		private var _posAssistObj:POSAssist;
		private var _posAssistOperation:POSAssistOperation;
		private var _isBusy:Boolean = false;
		public function StickerLabel()
		{
			// Init PosAssist
			_posAssistObj = new POSAssist();
			_posAssistObj.connect(POSAssist.DEFAULT_HOST_2,POSAssist.DEFAULT_PORT);
			
			_posAssistOperation = new POSAssistOperation();
			_posAssistOperation.objPOSAssist = _posAssistObj;
			// Init PosAssistOperation
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

			if(value <= 0 || isNaN(value))
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
		public function printLabel():void
		{
			try{
				_timer = new Timer(500,_quantities);
				_timer.addEventListener(TimerEvent.TIMER,function(event:TimerEvent):void{
					_posAssistOperation.directPrintLabel(_textLabel);
					trace("สินค้าชิ้นที่ : "+_timer.currentCount +"\n"+"Label is "+_textLabel+"\n");
				});
				_timer.addEventListener(TimerEvent.TIMER_COMPLETE,function(event:TimerEvent):void{
					trace("Completed!");
					_timer.stop();
					_timer.reset();
					_done();
					_posAssistObj.disconnect();
				});
				_timer.start();
				_isBusy = true;
				// TBC
			}catch(err:Error){
				_fail();
				_isBusy = false;
				_posAssistObj.disconnect();
			};
		}
	}
}