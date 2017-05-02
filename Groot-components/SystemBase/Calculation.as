package SystemBase
{
	import utilities.MyUtil;

	public class Calculation 
	{
		private var _subResult:String;
		private var _lastFormat:int;
		private var _salePrice:Number;
		private var _saleQty:Number;

		public static const UNKNOW_FORMAT:int = 0;
		public static const SALE_FORMAT:int       = 1;

		public function get lastFormat():int
		{
			return _lastFormat;
		}

		public function get salePrice():Number
		{
			return _salePrice;
		}

		public function get saleQty():Number
		{
			return _saleQty;
		}

		public function calculate(input:String):String
		{
			/** Return the calculated result from split algorithm */
			return this.split(input);
		}

		protected function split(input:String):String
		{
			var sum:Number;
			var calculationArray:Array;

			_subResult = input;
			calculationArray = input.split("+");	
			if(calculationArray.length == 1)
			{
				calculationArray = input.split("-"); 
				if(calculationArray.length == 1)
				{
					calculationArray = input.split("*");
					if(calculationArray.length == 1)
					{
						calculationArray = input.split("/");
						if(calculationArray.length == 1)
						{
							// trace("out case split");
						} else {
							sum = parseFloat(split(calculationArray[0]));
							for (var i:int = 1;i < calculationArray.length;i++){
								sum /= parseFloat(split(calculationArray[i]));
								trace("sum = sum /= parseFloat(split(calculationArray[i]))"
									+ "  " + sum + " = " + parseFloat(split(calculationArray[0])) + " / "
									+ parseFloat(split(calculationArray[i]) ));
							}
							_subResult = sum + "";
							trace("_subResult = " + sum + "");
						}
					} else {
						sum = parseFloat(split(calculationArray[0]));
						for (var l:int = 1;l < calculationArray.length;l++){
							sum *= parseFloat(split(calculationArray[l]));
							trace("sum = sum *= parseFloat(split(calculationArray[i]))"
								+ "  " + sum + " = " + parseFloat(split(calculationArray[0])) + " x "
								+ parseFloat(split(calculationArray[l])));
						}
						_subResult = sum + "";
						trace("_subResult = " + sum + "");
					}
				} else {
					sum = parseFloat(split(calculationArray[0])); 
					for (var j:int = 1;j < calculationArray.length;j++){
						sum -= parseFloat(split(calculationArray[j]));
						trace("sum = sum -= parseFloat(split(calculationArray[i]))"
							+ "  " + sum + " = " + parseFloat(split(calculationArray[0])) + " - "
							+ parseFloat(split(calculationArray[j])));
					}
					_subResult = sum + "";
					trace("_subResult = " + sum + "");
				}
			} else {
				sum = parseFloat(split(calculationArray[0]));
				for (var k:int = 1;k < calculationArray.length;k++){
					sum += parseFloat(split(calculationArray[k]));
					trace("sum = sum += parseFloat(split(calculationArray[i]))"
						+ "  " + sum + " = " + parseFloat(split(calculationArray[0])) + " + "
						+ parseFloat(split(calculationArray[k])));
				}
				_subResult = sum + "";
				trace("_subResult = " + sum + "");
			}

			return _subResult;
		}

		public function checkForm(valStr:String):int
		{
			var strArray:Array;

			_salePrice = _saleQty = 0;
			strArray = valStr.split(/[*]/);
			trace("After Split String: " + strArray);

			if (strArray.length == 2) {
				trace(MyUtil.isDigitInput(strArray[0]) + " - " + MyUtil.isDigitInput(strArray[1]));

				if ((MyUtil.isDigitInput(strArray[0]))&&(MyUtil.isDigitInput(strArray[1]))) {
					_salePrice = parseFloat(strArray[0]);
					_saleQty   = parseFloat(strArray[1]);
					return Calculation.SALE_FORMAT;
				}
			}

			return Calculation.UNKNOW_FORMAT;
		}

		public function calculateCheckForm(valStr:String):String
		{
			_lastFormat = checkForm(valStr);

			return calculate(valStr);
		}

	}
}
