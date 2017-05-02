package SystemBase
{
	import SMITPOSAssist.POSAssist;
	import mx.collections.ArrayCollection;
	import mx.collections.ArrayList;
	import mx.controls.Label;
	import mx.formatters.NumberBase;
	import mx.utils.ObjectUtil;
	import utilities.MyUtil;
	import SMITPOSAssist.*;

	public class GlobalVariable
	{
		public static const CRITICAL_ALERT_TITLE:String	= "Critical Error";
		public static const CRITICAL_ERROR_MSG:String 	= "เกิดความผิดพลาดขณะติดต่อระบบฐานข้อมูล\n" +
			"กรุณาติดต่อ SUMMIT TECH Group Co.Ltd.";
		public static const GENERIC_STR:String = "อื่นๆ";
		public static const NOTFOUND_STR:String  = "- ไม่พบข้อมูล -";

		/** Barcode Scaning Mode [BCSM]**/
		public static const BCSCM_SIMPLY:String    = "SIMPLY";
		public static const BCSCM_POSASSIST:String = "POSASSIST";

		/** POS Mode Selection **/
		public static const POSMODE_PICKPAY:String    = "PICKPAY";    // For Mart
		public static const POSMODE_PICKCREDIT:String = "PICKCREDIT"; // For Mart with credit
		public static const POSMODE_PICKSTORE:String  = "PICKSTORE";  // For Cafe & Restaurant

		/** In case, Zero Price Item setting (ZPI) **/
		public static const ZPI_NOCOUNT_NOPRN:String = "NOCOUNT_NOPRN";
		public static const ZPI_DEFAULT:String = "DEFAULT";  /** Count & Print normally **/

		/** Receipt Layout (RECEIPT_LA)**/
		public static const RECP_BASIC_MART:String = "BASIC_MART"; /** Default Layout **/
		public static const RECP_SIMPLE_BRASSERIES:String = "SIMPLE_BRASSERIES";
		public static const RECP_SIMPLE_CAFE:String = "SIMPLE_CAFE";

		/*
		 * Discount Type for Business logic
		 * NORMAL = The value behind decimal point will not be changed  (Example 5.59 => 5.59)
		 * ROUNDUP = The value behind decimal point will be 1 if it's value more than 0.50 (Example 5.59 => 6.00)
		 * ROUNDUPALWAYS = The value behind decimal point will be 1 if it's value more than 0.00 (Example 5.01 => 6.00)
		 * ROUNDDOWN = The value behind decimal point always be 0
		 * */
		/** NORMAL = The value behind decimal point will not be changed  (Example 5.59 => 5.59) **/
		public static const DISCOUNT_TYPE_NORMAL:String = "NORMAL";
		/** ROUNDUP = The value behind decimal point will be 1 if it's value more than 0.50 (Example 5.59 => 6.00) **/
		public static const DISCOUNT_TYPE_ROUNDUP:String = "ROUNDUP";
		/** ROUNDUPALWAYS = The value behind decimal point will be 1 if it's value more than 0.00 (Example 5.01 => 6.00) **/
		public static const DISCOUNT_TYPE_ROUNDUPALWAYS:String = "ROUNDUPALWAYS";
		/** ROUNDDOWN = The value behind decimal point always be 0**/
		public static const DISCOUNT_TYPE_ROUNDDOWN:String = "ROUNDDOWN";

		//ข้อมูลของผู้ใช้งานปัจจุบัน
		[Bindable]public static var currentUser:Object;
		//ข้อมูลของผู้ให้สิทธิ์ (ตอนนี้ใช้กับ ฟีเจอร์ voidDlg และ Authorization)
		/**
		 * returned object pattern => obj.userID , obj.userName 
		 * **/
		[Bindable]public static function get currentAuthorizedUser():Object{
			return _currentAuthorizedUser;
		};
		/**
		 * set object pattern => obj.userID , obj.userName
		 * Cannot set Null value on setter method
		 * **/
		public static function set currentAuthorizedUser(arg:Object):void{
			if(arg != null){
				_currentAuthorizedUser = mx.utils.ObjectUtil.clone(arg);
			}else{
				trace("GlobalVariable : Cannot set null value by using this setter method , use reset method instead");
			}
		};
		public static function resetCurrentAuthorizedUser():void{
			_currentAuthorizedUser = null;
		}
		private static var _currentAuthorizedUser:Object = null;
		//ข้อมูลของสินค้าปัจจุบัน
		[Bindable]public static var currentItem:Object;
		//ข้อมูลของผู้ส่งสินค้าปัจจุบัน
		[Bindable]public static var currentSupplier:Object;
		//[Bindable]public static var currentSupplier:ArrayCollection;
		//ข้อมูลของลูกค้าปัจจุบัน
		[Bindable]public static var currentCustomer:Object;
		//ข้อมูลของร้านค้า
		[Bindable]public static var currentStoreInfo:Object;
		//ข้อมูลการขาย
		//[Bindable]public static var currentSaleInfo:ArrayCollection;
		//ข้อมูลท้ายบิล
		[Bindable]private static var _currentAdvert:Object;
		public static function get currentAdvert():Object{
			return _currentAdvert; // currentAdvert.label = "word of advertise"
		}
		// arg :: arg.label = "attention of advert text"
		public static function set currentAdvert(arg:Object):void{
			if(arg && arg != null && arg.label != null)
			{
				_currentAdvert = arg;
			}
		}

		//อัตรภาษีปัจจุบัน
		//[Bindable]public static var currentTax:Number = 7; //ใช้ currentStoreInfo.vatrate แทน

		//ข้อมูลประเภทสินค้าทั้งหมด
		[Bindable]public static var allItemType:ArrayCollection;
		//ข้อมูลหน่วยนับสินค้าทั้งหมด
		[Bindable]public static var allItemUnit:ArrayCollection;
		//ข้อมูลขนาดสินค้าทั้งหมด
		[Bindable]public static var allSizeType:ArrayCollection;
		//ข้อมูลหน่วยนับสินค้าทั้งหมด
		[Bindable]public static var allPOStatus:ArrayCollection;
		//ข้อมูลระดับลูกค้าทั้งหมด
		[Bindable]public static var allCustomerClass:ArrayCollection;
		//ข้อมูลประเภทลูกค้าทั้งหมด
		[Bindable]public static var allCustomerType:ArrayCollection;

		[Bindable]public static var allWorkCode:ArrayCollection;
		public static var wcDBVer:String;
		public static var wcDBName:String;
		public static var wcMACNO:String;
		public static var wcPrintSlip:Boolean;
		public static var wcForcePrint:Boolean;
		public static var wcRePrint:Number;
		public static var wcSlip_Logo_visible:Boolean;
		public static var wcSlip_ADV_visible:Boolean;
		public static var wcCashDisc_Min:Number;
		public static var wcCashDisc_Max:Number;
		public static var wcBC_ScanMode:String;
		public static var wcPOS_Mode:String;
		public static var wcZeroPriceItem:String;
		public static var wcReceiptLayout:String;
		public static var wcPrintTax:Boolean;
		public static var wcCustomerDisplay:Boolean;
		public static var wcServiceVer:String;

		public static var endpointTOServer:String;
		public static var infoTO:String;
		public static var posType:String = null; // srpos program type , M-Series , R-Series , .....
		public static var posID:String = null;

		private static var _showPOSID:Boolean = true;
		public static function set showPOSID(arg:Boolean):void{
			_showPOSID = arg;
		}
		public static function get showPOSID():Boolean{
			return _showPOSID;
		}

		private static var _split_vat:Boolean = true;
		public static function set split_vat_mode(arg:Boolean):void{
			_split_vat = arg;
		}
		public static function get split_vat_mode():Boolean{
			return _split_vat;
		}

		private static var _posAssistMainPort:String = null;
		public static function get getPosAssistMainPort():String{
			return _posAssistMainPort;
		}
		public static function set setPosAssistMainPort(arg:String):void{
			
			if(MyUtil.isNullOrEmpty(arg))
			{
				_posAssistMainPort = "COM3";
			}
			else{
				var strList:Array = arg.toUpperCase().split("COM");
				var strListLen:int = strList.length;
				var numBase:NumberBase = new NumberBase();

				if(strListLen > 1 && !isNaN(Number(numBase.parseNumberString(strList[strListLen-1]) ) ) )
				{
					_posAssistMainPort = "COM"+Number(numBase.parseNumberString(strList[strListLen-1]) );
				}
				else
					_posAssistMainPort = "COM3";
			} 
		}

		public static const POLEDIS_SINGLEMODE:String = "single";
		public static const POLEDIS_DUALMODE:String = "dual";
		public static const POLEDIS_MULTIPLEMODE:String = "multiple";
		private static var _pole_display_text:String = "single";
		public static function set poleDisplayTextMode(arg:String):void{
			var check:String = arg.toLocaleLowerCase();
			if(check == POLEDIS_SINGLEMODE || check == POLEDIS_DUALMODE)
				_pole_display_text = arg;
			else
				_pole_display_text = POLEDIS_SINGLEMODE;
		}
		public static function get poleDisplayTextMode():String{
			return _pole_display_text;
		}
		private static var _pole_display_model:String = CustomerDisplayLine.MODEL_PD360R;
		public static function set poleDisplayModel(arg:String):void{
			if(!MyUtil.isNullOrEmpty(arg))
			{
				_pole_display_model = arg;
			}
		}
		public static function get poleDisplayModel():String{
			return _pole_display_model;
		}

		private static var _pole_display_port:Object = POSAssist.NET_CUSTOMER_DISPLAY;
		public static function setPoleDisplayPort(arg:String):void{
			var numformat:NumberBase = new NumberBase();
			var numString:String = numformat.parseNumberString(arg);

			if(String(arg).toUpperCase().search("COM") > -1 && !isNaN(Number(numString))){
				_pole_display_port = 5330 + Number(numString);
			}
			else
			{
				_pole_display_port = null;
			}
		}
		public static function get poleDisplayPort():Object{
			return _pole_display_port;
		}
		
		private static var _pluginList:ArrayCollection = new ArrayCollection();

		/** Global configulation for app **/
		protected static var _SRPOSConfig:SRPOSConfig = new SRPOSConfig();
		private static var _discountType:String = null;
		public static const serviceVersionList:ServiceVersion = new ServiceVersion();
		//ข้อความผลลัพธ์
		[Bindable]public static var lbResultText:String;
		[Bindable]public static var lbResultVisible:Boolean = false;
		//สถานะ enable ของปุ่มกดใน ControlBar และ ปุ่มกด subMenuBar
		[Bindable]public static var menuBarEnable:Boolean = true;
		//สถานะenable ของปุ่มกด delete ใน submenubar
		[Bindable]public static var submenubarDeleteEnable:Boolean = false;
		[Bindable]public static var datetimeFormat:String = "DD/MM/YYYY HH:NN";
		[Bindable]public static var dateFormat:String = "DD/MM/YYYY";
		[Bindable]public static var timeFormat:String = "HH:NN:SS";
		[Bindable]public static var timeFormatShort:String = "HH:NN";
		[Bindable]public static var userClass:ArrayCollection = new ArrayCollection([
			{userClass:"พนักงานขาย", data:1}, 
			{userClass:"ผู้จัดการร้าน", data:2}]);

		/** Refer to application POS assist object **/
		public static var posAssistObj:Object;

		// local master data cache
		public static var local_item_ac:ArrayCollection = new ArrayCollection;
		public static var local_cws_item_ac:Object = new Object;
		public static var local_cws_fee_ac:Object = new Object;
		public static var local_item_category_ac:ArrayCollection = new ArrayCollection;
		public static var local_itemresult_DUitembrowser_provider:ArrayCollection = new ArrayCollection;
		public static var local_itemresult_itembrowser_provider:ArrayCollection = new ArrayCollection;
		

		private static var _cache_item_master_ready:Boolean = false;
		private static var _vatMode:Boolean = false;
		public static function set vatMode(arg:Boolean):void{
			_vatMode = arg;
		}
		public static function get vatMode():Boolean{
			return _vatMode;
		}

		public static function filtering_itemByCategory_from_local(CategoryId:int, Categorykeyword:String):void
		{
			// query from local master data by using category index and keyword
			GlobalVariable.local_item_ac.filterFunction = function find_itemID(dataObj:Object):Boolean {
				var retVal:Boolean;

				try {
					retVal = (
								(CategoryId == -1 || dataObj.itemCatagoryIndex == CategoryId)
								&& (String(dataObj.itemName).toLocaleLowerCase()
									.indexOf(Categorykeyword.toLocaleLowerCase()) >= 0 || Categorykeyword.length == 0));
				}
				catch(e:Error) {
					trace('Searching dataObj.itemCatagoryIndex : ' + dataObj.itemCatagoryIndex +
						' CategoryId : ' + CategoryId);
					trace('CATCHED ERROR -- ' + e.message);
					retVal = false;
				}

				return retVal;
			}
		}

		/**
		 * 	pluginListSet set Array of plugins  (name , enabled , device)
		 * */
		public static function assignPluginList(pluginList:Array):void
		{
			/**
			 * Need to confirm about a garbage collector, in case call this function frequently.
			 **/
			_pluginList = new ArrayCollection(pluginList);
		}

		/**
		 * 	pluginListGet return list of plugins  (name , enabled , device)
		 * */
		public static function get pluginList():ArrayCollection
		{
			return _pluginList;
		}

		/**
		 * searchPlugin for find and get a plugin <br /><br />
		 * return null if no result <br />
		 * return Object => (name , enable , device) if result match with plugin name
		 * , get only first object if this method match same name more than one Object
		 * */
		public static function searchPlugin(searchText:String):Object
		{
			var obj:Object = null;
			for(var i:int = 0;i < _pluginList.length;i++)
			{
				if(_pluginList.getItemAt(i).name == searchText){
					obj = _pluginList.getItemAt(i);
					break;
				}
			}
			return obj;
		}

		/**
		 * pluginHasPlugin return have or not have any plugin
		 * */
		public static function pluginHasPlugin():Boolean
		{
			return _pluginList.length > 0;
		}

		/**
		 * checkPlugin check plugin with name
		 * has "searchText" plugin ?
		 * */
		public static function checkPlugin(searchText:String):Boolean
		{
			var result:Boolean = false;

			if(searchPlugin(searchText) != null 
				&& searchPlugin(searchText).enable != null
				&& searchPlugin(searchText).enable.toLocaleLowerCase() == "true")
			{
				result = true;
			}

			return result;
		}

		/**
		 * return value ==> Discount Type for Business logic
		 * NORMAL = The value behind decimal point will not be changed  (Example 5.59 => 5.59) <
		 * ROUNDUP = The value behind decimal point will be 1 if it's value more than 0.50 (Example 5.59 => 6.00)
		 * ROUNDUPALWAYS = The value behind decimal point will be 1 if it's value more than 0.00 (Example 5.01 => 6.00)
		 * ROUNDDOWN = The value behind decimal point always be 0
		 ** */
		public static function get discountType():String
		{
			return _discountType;
		}
		/**
		* inputStr ==> Discount Type for Business logic <br />
		* NORMAL = The value behind decimal point will not be changed  (Example 5.59 => 5.59) <br />
		* ROUNDUP = The value behind decimal point will be 1 if it's value more than 0.50 (Example 5.59 => 6.00) <br />
		* ROUNDUPALWAYS = The value behind decimal point will be 1 if it's value more than 0.00 (Example 5.01 => 6.00) <br />
		* ROUNDDOWN = The value behind decimal point always be 0
		** */
		public static function set discountType(inputStr:String):void
		{
			if(checkIsDiscountType(inputStr))
			{
				_discountType = inputStr;
			}
			else
			{
				_discountType = DISCOUNT_TYPE_NORMAL;
			}
		}

		public static function checkIsDiscountType(inputStr:String):Boolean
		{
			var checker:String = inputStr.toLocaleUpperCase();
			if(DISCOUNT_TYPE_NORMAL == checker || DISCOUNT_TYPE_ROUNDUP == checker
				|| DISCOUNT_TYPE_ROUNDUPALWAYS == checker || DISCOUNT_TYPE_ROUNDDOWN == checker)
				return true;
			else {
				return false;
			}
		}

		public static function filtering_itemByitemID_from_local(itemID:String):void
		{			
			// query from local master data by using item index
			GlobalVariable.local_item_ac.filterFunction = function find_itemID(dataObj:Object):Boolean {
					return (dataObj.itemID == itemID);
			}
		}

		public static function filtering_itemCategoryByCategoryID_from_local(CategoryIndex:String):void
		{		
			GlobalVariable.local_item_ac.filterFunction = function find_itemID(dataObj:Object):Boolean {
				return (dataObj.itemCatagoryIndex == CategoryIndex);
			}	
		}

		public static function get cache_item_master_ready():Boolean
		{
			return _cache_item_master_ready;
		}

		public static function set_cache_item_master_ready():void
		{
			_cache_item_master_ready = true;
		}

		public static function am_i_server():int
		{
			var info:String = String(infoTO);
			var ret:int  = info.search("SERVER");
			var ret2:int = info.search("CLIENT");

			if (ret > 0) {
				trace("am_i_server -- yes " + ret);
				return 1;
			}
			else if(ret2 > 0) {
				trace("am_i_server -- no " + ret2);
				return 0;
			}

			return -1; // Not Defined
		}

		public static function get srposConfig():SRPOSConfig
		{
			return _SRPOSConfig;
		}
	}
}
