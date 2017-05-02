package utilities
{
	/*
	SSF-91 , Introduce about Floating Point Problem in flex with Money and Math
	Since the money is sensitive data and need very high precise floating point data
	, so I decide Create this class for workaround that problem

	Reference for Solving this Problems

	How to deal with Number precision in Actionscript?
	http://stackoverflow.com/questions/632802/how-to-deal-with-number-precision-in-actionscript
	http://stackoverflow.com/questions/632802/how-to-deal-with-number-precision-in-actionscript/1541929#1541929

	How to round up that Adobe doesn't make it as built-in library
	http://fraserchapman.blogspot.com/2007/05/rounding-to-specific-decimal-places.html (Last comment post about Porting Java's Big Decimal to Actionscript)

	Someone try to port Java's Bigdecimal Class Library to AS3, Now this class library disappeared and cannot download from it again.
	https://code.google.com/archive/p/bigdecimal/

	Note : ToFixed() in Math.toFixed also generate floating point bug
	*/

	import SystemBase.GlobalVariable;

	import com.adobe.fiber.runtime.lib.DateTimeFunc;

	import flash.desktop.NativeApplication;
	import flash.events.FocusEvent;

	import mx.collections.ArrayCollection;
	import mx.controls.DataGrid;
	import mx.controls.DateField;
	import mx.utils.ObjectUtil;
	import mx.utils.StringUtil;
	import mx.validators.StringValidator;

	import spark.components.DropDownList;
	/**
	 * Class for managing Number
	 * */
	public class MathUtil
	{
		public function MathUtil()
		{
		}

		/**
		 * input => "a"  and  "b" , precision is number to make fact of being exact and accurate.<br/>
		 * output =>  "a" - "b" = ???
		 * <b>Since adobe doesn't solve floating point number problem</b> <br/> 
		 * so we make this workaround for correct calculation with Decimal Number with floating point <br/>
		 * **/
		public static function subtractDecimalNumber(a:Number,b:Number,precision:int = 2):Number
		{
			var subtractFunction:Function = function(a:Number,b:Number):Number{
				return (a-b);
			}
			return multi_Precision_calculate(a,b,precision,subtractFunction);
		}

		/**
		 * input => "a"  and  "b" , precision is number to make fact of being exact and accurate.<br/>
		 * output =>  "a" + "b" = ???
		 * <b>Since adobe doesn't solve floating point number problem</b> <br/> 
		 * so we make this workaround for correct calculation with Decimal Number with floating point <br/>
		 * **/
		public static function addtionDecimalNumber(a:Number,b:Number,precision:int = 2):Number
		{
			var additionFunction:Function = function(a:Number,b:Number):Number{
				return (a+b);
			}
			return multi_Precision_calculate(a,b,precision,additionFunction);
		}

		public static function toFixed(a:Number,precision:int = 2):Number
		{
			precision = Math.pow(10,precision);
			return Math.round(a * precision)/precision;
		}
		// this function is for Convert floating point number to normal number before calculation because of floating point number problems
		private static function multi_Precision_calculate(a:Number,b:Number,precision:int,f:Function):Number
		{
			precision = Math.pow(10,precision+2);
			var result:Number = Math.round( f(a * precision,b * precision) );
			return result/precision;
		}
	}
}