package utilities
{
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
	 * Class for managing string
	 */
	public class MyUtil
	{
		public static const OUR_COMPANY:String   = "SUMMIT TECH Group Co.,Ltd.";

		/**
		 * Strings in ECMAScript (ActionScript) are immutable <br />
		 * this setCharAt will make new String that it had set a character in string <br />
		 * <br />
		 * Reference by <br />
		 * http://stackoverflow.com/questions/2831502/change-a-character-in-a-string-using-actionscript
		 */
		public static function setCharAt(str:String, char:String,index:int):String {
			return str.substr(0,index) + char + str.substr(index + 1);
		}

		/**
		 * Check the string contains value or empty
		 */
		public static function isNullOrEmpty(str1:String):Boolean{
			if(str1 == null)
				return true;
			str1 = StringUtil.trim(str1);
			if(str1 == "")
				return true;
			else
				return false;
		}
		
		/**
		 * Prepare part of SQL query for search area (KP)
		 */
		public static function prepareStringSQL(columnName:String, stringSearch:String):String{
			if(isNullOrEmpty(stringSearch))
				return "";
			else
				return " AND " + columnName + " LIKE '%" +stringSearch + "%'";
		}
		
		/**
		 * Prepare part of SQL "or" query for search area (KP)
		 */
		public static function prepareStringSQL_or(columnName:String, stringSearch:String):String{
			if(isNullOrEmpty(stringSearch))
				return "";
			else
				return " OR " + columnName + " LIKE '%" +stringSearch + "%'";
		}
		
		/**
		 * Prepare date to be compare in search area (KP)
		 * Such as '2011-1-31'
		 */
		public static function prepareDateSQL(date1:Date):String{
			if(date1 == null)
				return "";
			else
				if(date1.month<9){
					return date1.fullYear.toString()
						+ "-0" + (date1.month + 1).toString()
						+ "-" + (date1.date).toString();
				}else{
					return date1.fullYear.toString()
						+ "-" + (date1.month + 1).toString()
						+ "-" + (date1.date).toString();
				}
		}
		
		/**
		 * Find itemIndex of Drop Down List Component from itemType (KP)
		 */
		public static function getItemTypeIndex(DDL1:DropDownList, item1:String):int{
			if(DDL1.dataProvider.length > 0){
				var _index:int = -1;
				for (var i:int = 0; i < DDL1.dataProvider.length; i++) 
				{ 
					var str1:String = DDL1.dataProvider[i].itemType as String;
					if (str1 == item1) 
					{  
						_index = i;
						break; 
					} 
				}
				return _index;
			}
			else{
				return _index;
			}
		}
		
		/**
		 * Find itemIndex of Drop Down List Component from itemUnit (KP)
		 */
		public static function getItemUnitIndex(DDL1:DropDownList, item1:String):int{
			if(DDL1.dataProvider.length > 0){
				var _index:int = -1;
				for (var i:int = 0; i < DDL1.dataProvider.length; i++) 
				{ 
					var str1:String = DDL1.dataProvider[i].itemUnit as String;
					if (str1 == item1) 
					{  
						_index = i;
						break; 
					} 
				}
				return _index;
			}
			else{
				return _index;
			}
		}
		
		public static function getItemSizeIndex(DDL1:DropDownList, item1:String):int{
			if(DDL1.dataProvider.length > 0){
				var _index:int = -1;
				for (var i:int = 0; i < DDL1.dataProvider.length; i++)
				{
					var str1:String = DDL1.dataProvider[i].itemSize as String;
					if (str1 == item1)
					{
						_index = i;
						break;
					}
				}
				return _index;
			}
			else{
				return _index;
			}
		}

		/**
		 * Find itemIndex of Drop Down List Component from customerClass (KP)
		 */
		public static function getcustomerClassIndex(DDL1:DropDownList, item1:String):int{
			if(DDL1.dataProvider.length > 0){
				var _index:int = -1;
				for (var i:int = 0; i < DDL1.dataProvider.length; i++) 
				{ 
					var str1:String = DDL1.dataProvider[i].customerClass as String;
					if (str1 == item1) 
					{  
						_index = i;
						break; 
					} 
				}
				return _index;
			}
			else{
				return _index;
			}
		}
		
		/**
		 * Find itemIndex of Drop Down List Component from customerType (KP)
		 */
		public static function getcustomerTypeIndex(DDL1:DropDownList, item1:String):int{
			if(DDL1.dataProvider.length > 0){
				var _index:int = -1;
				for (var i:int = 0; i < DDL1.dataProvider.length; i++) 
				{ 
					var str1:String = DDL1.dataProvider[i].customerType as String;
					if (str1 == item1) 
					{  
						_index = i;
						break; 
					} 
				}
				return _index;
			}
			else{
				return _index;
			}
		}
		
		public static function dataGrid_focusOutHandler(event:FocusEvent):void
		{
			if (null != event.relatedObject) {
				if(event.relatedObject.name!="btnDel"){
					GlobalVariable.submenubarDeleteEnable=false;
				}
			}
		}
		
		public static function dateChangeHandler(dfieldFrom:DateField, dfieldTo:DateField):void {
			if((dfieldTo.selectedDate != null) && dfieldFrom.selectedDate >= dfieldTo.selectedDate){
				dfieldTo.selectedDate = null;
			}
			var dateRange:Object = new Object();
			dateRange["rangeStart"] = dfieldFrom.selectedDate;
			dfieldTo.selectableRange = dateRange;
		}
		
		/**
		 * Clear all data from data grid (KP)
		 */
		public static function clearDataGrid(dg:DataGrid):void{
			if(dg!=null){
				dg.dataProvider.removeAll();
			}
		}
		
		/**
		 * Return appropriate value for database when null (KP)
		 */
		public static function nullable(obj:Object):String{
			if(obj==null){
				return "";
			}else{
				return obj.toString();
			}
		}
		
		public static function getStringDate(dte:Date):String{
			var str:String;
			if(dte.month < 9){
				str = dte.fullYear.toString() + "-0" 
					+ (dte.month + 1).toString() + "-" + dte.date.toString();
			}else{
				str = dte.fullYear.toString() + "-" 
					+ (dte.month + 1).toString() + "-" + dte.date.toString();
			}
			return str;
		}
		
		public static function getStringMonth(dte:Date):String{
			var str:String;
			if(dte.month < 9){
				str = "0" 
					+ (dte.month + 1).toString();
			}else{
				str = (dte.month + 1).toString();
			}
			return str;
		}
		
		/**
		 * To be used by bahtText function (KP)
		 */
		private static function digitText(var1:Number):String{
			var str1:String;
			var str2:String = var1.toString();
			switch(str2.length)
			{
				case 1:
					str1 = "บาท";
					break;
				case 2:
					str1 = "สิบ";
					break;
				case 3:
					str1 = "ร้อย";
					break;
				case 4:
					str1 = "พัน";
					break;
				case 5:
					str1 = "หมื่น";
					break;
				case 6:
					str1 = "แสน";
					break;
				case 7:
					str1 = "ล้าน";
					break;
			}
			return str1;
		}
		
		/**
		 * To be used by bahtText function (KP)
		 */
		private static function numberText(var1:int):String{
			var strPro:String;
			var1 %= 10;
			switch(var1)
			{
				case 1:
					strPro = "หนึ่ง";
					break;
				case 2:
					strPro = "สอง";
					break;
				case 3:
					strPro = "สาม";
					break;
				case 4:
					strPro = "สี่";
					break;
				case 5:
					strPro = "ห้า";
					break;
				case 6:
					strPro = "หก";
					break;
				case 7:
					strPro = "เจ็ด";
					break;
				case 8:
					strPro = "แปด";
					break;
				case 9:
					strPro = "เก้า";
					break;
				default:
					strPro = "";
			}
			return strPro;
		}
		
		/**
		 * Return string BAHT of numuric input (KP)
		 */
		public static function bahtText(var1:Number):String{
			var strAns:String = "";
			var strDigit:String = "";
			var strNumber:String;
			var numDevide:int = int(var1);
			
			while(true){
				var pow:int = numDevide.toString().length - 1;
				var num1:int = Math.pow(10,pow);
				var num2:int = numDevide/num1
				strNumber = numberText(num2);
				
				strDigit = digitText(numDevide);
				
				if(strDigit == "บาท"){
					if(strNumber == "หนึ่ง")
						strNumber = "เอ็ด";
					strAns += (strNumber + strDigit);
					break;
				}else{
					if(strNumber == "สอง" && strDigit == "สิบ")
						strNumber = "ยี่";
					strAns += (strNumber + strDigit);
				}
				numDevide -= (num1*num2);
			}
			return strAns;
		}
		
		/**
		 * Return string with prefix if not empty otherwise return blank (KP)
		 */
		public static function getStringIfNotEmpty(value1:String, prefix1:String):String{
			if(isNullOrEmpty(value1)){
				return "";
			}else{
				return (prefix1 + value1);
			}
		}

		public static function isDigitInput(inputStr:String):Boolean
		{
			/** Filter input value to accept only number and whitespace only*/
			var re:RegExp = /^[0-9.\s]*$/;
			return re.test(inputStr);
		}
		
		public static function doForcePrint():void
		{
			/**
			 * For the efficiency of using, should call printJob.start() immediately after
			 * calling this function. See the printSlipJob().
			 **/

			if (GlobalVariable.wcForcePrint) {
				if (GlobalVariable.posAssistObj != null)
					GlobalVariable.posAssistObj.forcePrintSlip();
			}
		}

		public static function getAppVersion():String
		{
			/** Source from :
			 *  http://inflagrantedelicto.memoryspiral.com/2009/02/quick-tip-display-application-version-in-your-air-app/
			 **/

			var appXml:XML = NativeApplication.nativeApplication.applicationDescriptor;
			var ns:Namespace = appXml.namespace();
			var appVersion:String = appXml.ns::versionNumber[0];
			return appVersion;
		}

		public static function getAppLabel():String
		{
			/** Source from :
			 *  http://inflagrantedelicto.memoryspiral.com/2009/02/quick-tip-display-application-version-in-your-air-app/
			 **/

			var appXml:XML = NativeApplication.nativeApplication.applicationDescriptor;
			var ns:Namespace = appXml.namespace();
			var appLabel:String = appXml.ns::versionLabel[0];
			return appLabel;
		}

		/**
		 * get FileExtension from string
		 * 
		 * return file extension => ".xml" , ".csv" or other if path have file extension <br />
		 * return "" if path is invalid or no getFileExtension <br />
		 * return null if path is null
		 * */
		public static function getFileExtension(path:String):String
		{
			if(path == null)
				return null
			var length:int = path.length;
			var ch:String = null;
			var emptyString:String = "";

			for(var i:int = length;--i >= 0;)
			{
				ch = path.charAt(i);
				if(ch == '.')
				{
					if(i != length - 1)
						return path.substr(i, length - i);
					else
						return emptyString;
				}
				if(ch == "\\" || ch == "/" || ch == ":")
					break;
			}

			return emptyString;
		}

		/*
		 * convert input 2 Dimentional Array to CVS String <br />
		 * 
		 * <Note>
		 * for( ?? in ?? ) produce unorder retriving data problem <br />
		 * I use for(var i:int ; i < ??? ;i++)
		 * </Note>
		 * */
		/**
		 * <b><h1>input</h1></b> Data should be 2 dimentional or array of string array only <br /> 
		 * not Object Array because Object Array doesn't know correct order <br /> 
		 * <b><h1>output</h1></b> Data is String data with CSV format <br />
		 * <br />
		 * Delimiter is "" <br />
		 * Seperator is ,
		 * **/
		public static function exportArrayStringToCSV(inputData:*):String
		{
			var result:String = "";
			var temp:String = "";
			var pattern:RegExp = null;
			var flagDelimiter:Boolean = false;
			// ======== Start Loop

			for(var i:int = 0;i < inputData.length;i++){

				if(inputData[i].length <= 0){
					continue;
				}
				for(var j:int = 0;j < inputData[i].length;j++)
				{
					flagDelimiter = false;

					temp = inputData[i][j].toString(); // init data

					// If find ,
					if(temp.indexOf(",") >= 0)
					{
						flagDelimiter = true;
					}

					// If find "
					if(temp.indexOf("\"") >= 0)
					{
						flagDelimiter = true;
						// Pattern is for Regexp  \" is Escape Sequence  /g is global (search and Point all match pattern string)
						pattern = /\"/g;
						temp = temp.replace(pattern,"\"\"");
					}

					if(inputData[i][j] == null){ temp = " ";}

					if(flagDelimiter) { temp = "\"" + temp + "\"";}

					// If End Line or Not EndLine
					// End Line
					if(j < inputData[i].length - 1){
						result = result + (temp + ",");
					}
					else
					{
						result = result + (temp + "\r\n");
					}
				}
			}

			if(isNullOrEmpty(result))
				result = null;
			// ======== End Loop
			return result;
		}

		/**
		 *   Count the properties in an object
		 *   @param obj Object to count the properties of
		 *   @return The number of properties in the specified object. If the
		 *           specified object is null, this is 0.
		 *   @author Jackson Dunstan
		 */
		public static function getNumProperties(obj:Object): int
		{
			var count:int = 0;
			for each (var prop:Object in obj)
			{
				count++;
			}
			return count;
		}

		/**
		 *   Check if an object has any properties
		 *   @param obj Object to check for properties
		 *   @return If the specified object has any properties. If the
		 *           specified object is null, this is false.
		 *   @author Jackson Dunstan
		 */
		public static function checkHasProperties(obj:Object): Boolean
		{
			for each (var prop:Object in obj)
			{
				return true;
			}
			return false;
		}
	}
}
