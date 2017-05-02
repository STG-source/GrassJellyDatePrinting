package SystemBase
{
	import SMITPOSAssist.CustomerDisplayLine;
	import SaleForm.SaleFacility;
	import SystemBase.GlobalVariable;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Loader;
	import flash.events.Event;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.net.URLRequest;
	
	import mx.collections.ArrayCollection;
	import mx.collections.ArrayList;
	import mx.controls.Alert;

	public class SRPOSConfig
	{
		public static const DEFAULT_CONFIG_FILE:String = "srpconfig.xml";

		private var _fileXML:File = new File();
		private var _fs:FileStream = new FileStream();
		protected var configxml:XML;

		protected var bitmapPath:String;
		protected var QRPath:String;
		protected var bitmapLoader:Loader;
		protected var qrCodeLoader:Loader;
		protected var loadedLogoBitmap:Bitmap; // prv is ImageLogomyBitmap
		protected var loadedQRBitmap:Bitmap; // prv is ImageQRmyBitmap

		public function SRPOSConfig()
		{
			bitmapLoader = new Loader();
			bitmapLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, addBitmapLogo);
			qrCodeLoader = new Loader();
			qrCodeLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, addQR_Bitmap);
		}

		/**
		 * setSRPOSVersion(Application Name from "this.applicationID") </br>
		 * this method should be used after load srpconfig.xml
		 * */
		public function set setSRPOSVersion(appName:String):void{
			var defaultVersion:String = null;
			defaultVersion = appName.charAt(appName.length - 1);

			if(defaultVersion.toLocaleUpperCase() == "R")
			{
				defaultVersion = "R-Series";
			}
			else if(defaultVersion.toLocaleUpperCase() == "M")
			{
				defaultVersion = "M-Series";
			}
			else
			{
				defaultVersion = null;
			}

			if(defaultVersion != null)
			{
				if(GlobalVariable.posType == null)
				{
					trace("setSRPOSVersion => set default version : "+defaultVersion);
				}
				else if(GlobalVariable.posType.toLocaleUpperCase() != defaultVersion.toLocaleUpperCase())
				{
					mx.controls.Alert.show("pos_type ในไฟล์ \"srpconfig.xml\" มีการตั้งค่าไม่ตรงกับเวอร์ชั่นของโปรแกรม","Warning! การตั้งค่าโปรแกรมไม่ถูกต้อง",mx.controls.Alert.OK);
					trace("setSRPOSVersion => Warning! pos_type ในไฟล์ \"srpconfig\" ไม่ตรงกับเวอร์ชั่นของโปรแกรม");
				}
				GlobalVariable.posType = defaultVersion;
			}
			else{
				trace("setSRPOSVersion => Warning! appName:String doesn't match with any SRPOS version.");
			}
		}

		public function get ConfigXML():XML
		{
			return configxml;
		}

		public function get LogoBitmap():Bitmap
		{
			return loadedLogoBitmap;
		}

		public function get QRBitmap():Bitmap
		{
			return loadedQRBitmap;
		}

		protected function loadServiceCfg():void
		{
			if(configxml.attributes().length() > 0)
			{
				trace("Load SRP service config = " +
					configxml.child("service_endpoint")[0].elements("TOServer").@url.length() +
					" [Configured End Point]: " + configxml.child("service_endpoint")[0].elements("TOServer").@url);
				
				trace("--> System Configuration Version : " + configxml.@version);

				if (configxml.child("service_endpoint")[0].elements("TOServer").@url.length() > 0)
					GlobalVariable.endpointTOServer = configxml.child("service_endpoint")[0].elements("TOServer").@url;
				else
					GlobalVariable.endpointTOServer = null;

				trace("iamserver :: " + configxml.@iamserver + " TONO :: " + configxml.@TONO);
				if (configxml.@iamserver == "yes") {
					GlobalVariable.infoTO = " TO::" + "SERVER" +
						configxml.@TONO;
				}
				else {
					GlobalVariable.infoTO = " TO::" + "CLIENT" +
						configxml.@TONO;
				}
				GlobalVariable.am_i_server();

				if(configxml.@pos_type != null){
					trace("Pos type is :: " + configxml.@pos_type);

					if(GlobalVariable.posType == null){
						GlobalVariable.posType = configxml.@pos_type;
					}
					else if(GlobalVariable.posType != configxml.@pos_type)
					{
						mx.controls.Alert.show("pos_type ในไฟล์ \"srpconfig.xml\" มีการตั้งค่าไม่ตรงกับเวอร์ชั่นของโปรแกรม","Warning! การตั้งค่าโปรแกรมไม่ถูกต้อง",mx.controls.Alert.OK);
						trace("loadServiceCfg => Warning! pos_type ในไฟล์ \"srpconfig\" ไม่ตรงกับเวอร์ชั่นของโปรแกรม");
					}
				}

				if(configxml.@pos_id != null){
					trace("POS ID is :: "+configxml.@pos_id);

					GlobalVariable.posID = configxml.@pos_id;
				}

				if(configxml.@discount_type != null)
				{
					trace("Setting discount_type is :: " + configxml.@discount_type);
					GlobalVariable.discountType = configxml.@discount_type;

					if(!GlobalVariable.checkIsDiscountType(configxml.@discount_type))
					{
						mx.controls.Alert.show("discount_type ในไฟล์ \"srpconfig.xml\" มีการตั้งค่าไม่ถูกต้อง โปรดตรวจสอบด้วย","Warning! การตั้งค่าโปรแกรมไม่ถูกต้อง",mx.controls.Alert.OK);
					}
				}

				if(configxml.@pos_assist_mainport != null)
				{
					trace("POS Assist Mainport is :: "+configxml.@pos_assist_mainport);
					GlobalVariable.setPosAssistMainPort = configxml.@pos_assist_mainport;
				}

				if(configxml.@pole_display_text != null){
					trace("Pole Display Text is :: "+configxml.@pole_display_text);
					GlobalVariable.poleDisplayTextMode = configxml.@pole_display_text;
				}

				if(configxml.@pole_display_model != null){
					trace("Pole Display Model :: " + configxml.@pole_display_model);
					GlobalVariable.poleDisplayModel = configxml.@pole_display_model;
				}
				else{
					trace("Pole Display Model :: Unknown Model , Force Set to \"MODEL_PD360R\"");
					GlobalVariable.poleDisplayModel = CustomerDisplayLine.MODEL_PD360R;
				}

				if(configxml.@pole_display_port != null){
					trace("Pole Display Model :: " + configxml.@pole_display_port);
					GlobalVariable.setPoleDisplayPort(configxml.@pole_display_port);
				}

				var cfg_receipt:XMLList = configxml.child("receipt");
				var cfg_bill_head:String = configxml.child("receipt").@bill_head_char;
				trace("configxml.child( receipt ) :: bill_head_char :: " + cfg_bill_head);
				if (cfg_bill_head != null) {
					SaleFacility.billHeadChar = cfg_bill_head;
				}

				if(cfg_receipt.@show_vat != null){
					var show_vat:Object = cfg_receipt.@show_vat;
					GlobalVariable.vatMode = show_vat.toString().toLocaleLowerCase() == "true";
				}
				else {
					GlobalVariable.vatMode = false; // false by default
				}
				trace("configxml.child( receipt ) :: show_vat :: "+ GlobalVariable.vatMode);

				if(cfg_receipt.@split_vat != null){
					var split_vat:Object = cfg_receipt.@split_vat;
					GlobalVariable.split_vat_mode = split_vat.toString().toLocaleLowerCase() == "true";
				}
				else {
					GlobalVariable.split_vat_mode = true; // true by default
				}
				trace("configxml.child( receipt ) :: split_vat_mode :: "+ GlobalVariable.split_vat_mode);

				if(cfg_receipt.@show_posid != null){
					var show_posid:Object = cfg_receipt.@show_posid;
					GlobalVariable.showPOSID = show_posid.toString().toLocaleLowerCase() == "true";
				}
				else
				{
					GlobalVariable.showPOSID = true; // true by default
				}
				trace("configxml.child( receipt ) :: showPOSID :: "+ GlobalVariable.showPOSID);

				if(cfg_receipt.@show_logo != null)
				{
					GlobalVariable.wcSlip_Logo_visible = cfg_receipt.@show_logo.toString().toLocaleLowerCase() == "true";
				}
				else{
					GlobalVariable.wcSlip_Logo_visible = false;
				}
				trace("configxml.child( receipt ) :: wcSlip_Logo_visible :: "+ GlobalVariable.wcSlip_Logo_visible);

				if(cfg_receipt.@show_advertise != null)
				{
					GlobalVariable.wcSlip_ADV_visible = cfg_receipt.@show_advertise.toString().toLocaleLowerCase() == "true";
				}
				else{
					GlobalVariable.wcSlip_ADV_visible = false;
				}
				trace("configxml.child( receipt ) :: wcSlip_ADV_visible :: "+ GlobalVariable.wcSlip_ADV_visible);
			}
		}
		protected function loadFilePic():void
		{
			trace(configxml.child("receipt")[0].elements("picture").@name.length());

			if(configxml.attributes().length() > 0)
			{
				trace("configxml.attributes().length() = " + configxml.child("receipt")[0].elements("picture").@name.length());
				for (var j:int = 0; j < configxml.child("receipt")[0].elements("picture").@name.length(); j++) {
					var attribName:String = configxml.child("receipt")[0].elements("picture").@name[j];
					switch (attribName) {
						case "logo":
							trace("Found Attribute: " + attribName + " Value: " + configxml.child("receipt")[0].elements("picture")[j].elements("path")[0]);
							bitmapPath = configxml.child("receipt")[0].elements("picture")[j].elements("path")[0];
							break;
						case "QR":
							trace("Found Attribute: " + attribName + " Value: " + configxml.child("receipt")[0].elements("picture")[j].elements("path")[0]);
							QRPath = configxml.child("receipt")[0].elements("picture")[j].elements("path")[0];
							var tempObject:Object = new Object();
							tempObject.label = configxml.child("receipt")[0].elements("picture")[j].elements("label")[0];
							GlobalVariable.currentAdvert = tempObject;
							break;
						default:
							trace("UNKNOWN Attribute: " + attribName + " Value: " + configxml.systemconfig.receipt.piture.attributes()[j]);
							break;
					}
				}
			}
			bitmapLoader.load(new URLRequest(bitmapPath)); // original version in DuSaleGroupPage.mxml is ImageLogoToBitmap();
			qrCodeLoader.load(new URLRequest(QRPath)); // original version in DuSaleGroupPage.mxml is ImageQRToBitmap();

			var cfg_bill_head:String = configxml.child("receipt")[0].@bill_head_char;
			trace("configxml.child( receipt ) :: bill_head_char :: " + cfg_bill_head);
			if (cfg_bill_head != null) {
				SaleFacility.billHeadChar = cfg_bill_head;
			}
		}

		protected function loadPlugin():int
		{
			var resultArray:ArrayCollection = new ArrayCollection();
			var tempObj:Object = null;
			// If PlugMan is Enable
			if(configxml.PlugMan != null
				&& configxml.PlugMan.@enable =="true"
				&& configxml.PlugMan.Addon != null)
			{
				var tempPlugin:XMLList = configxml.PlugMan.children();
				// Loop Setting Addon
				for(var i:int = 0;i < tempPlugin.length();i++)
				{
					tempObj = new Object();
					for each(var item:Object in tempPlugin[i].attributes()){
						tempObj[item.name().localName] = item;
					}
					if(tempPlugin[i].children().length() > 0)
						tempObj.children = tempPlugin[i].children();
					else
						tempObj.children = null;

					resultArray.addItem(tempObj);
				}
			}
			// End If PlugMan is Enable

			// Set setter Method for setting Object
			GlobalVariable.assignPluginList(resultArray.toArray());
			return 0; // 0 is no Error
		}

		protected function addBitmapLogo(event:Event):void
		{
			var bd:BitmapData = new BitmapData(event.currentTarget.content.width, event.currentTarget.content.height);
			bd.draw(event.currentTarget.content);
			loadedLogoBitmap = new Bitmap(bd);
		}

		protected function addQR_Bitmap(event:Event):void
		{
			var bd:BitmapData = new BitmapData(event.currentTarget.content.width, event.currentTarget.content.height);
			bd.draw(event.currentTarget.content);
			loadedQRBitmap = new Bitmap(bd);
		}

		public function loadSystemConfig(bLocal:Boolean = true):int
		{
			if (bLocal == true)
			{
				/**
				 * This code was clone from DuSaleGroupPage.mxml
				 */

				_fileXML = File.applicationStorageDirectory;
				//_fileXML = _fileXML.resolvePath(SRPOSConfig:DEFAULT_CONFIG_FILE);
				_fileXML = _fileXML.resolvePath("srpconfig.xml"); // the above was error compile so we do this here
				trace(_fileXML.nativePath);

				if (_fileXML.exists == true)
				{
					trace("_fileXML.exists == true");
					_fs.open(_fileXML, FileMode.READ);
					configxml = XML(_fs.readUTFBytes(_fs.bytesAvailable));
					_fs.close();

					loadServiceCfg();	// Place in initialize handler
					loadFilePic();		// Load picture for slip layout
					loadPlugin();		// Load Plugin Name List
					// [TBC] loadLabelStickerConfig(); // Load label sticker printing config
					// [TBC] loadCafeTableList();
				}
				else
				{
					trace("Warning not found the system config srpconfig.xml");
				}

			}

			return 0;
		}

		private function saveSystemConfig(bLocal:Boolean = true):int
		{
			/**
			* [TBC] I'm doing the test to write an attribute, it's not finish yet.
			* Noted by Chayes
			**/

			if (bLocal == true)
			{
				/**
				 * This code was clone from DuSaleGroupPage.mxml
				 */

				configxml.@runrunrun = "new_attribute"; // <-- Attribute "runrunrun" is a Dummy

				_fileXML = File.applicationStorageDirectory;
				_fileXML = _fileXML.resolvePath("srpconfig.xml");
				trace("saveSystemConfig : " + _fileXML.nativePath);

				if (_fileXML.exists == true)
				{
					trace("_fileXML.exists == true");
					_fs.open(_fileXML, FileMode.WRITE);
					_fs.writeUTFBytes(configxml.toXMLString());
					_fs.close();
				}
				else
				{
					trace("Warning not found the system config srpconfig.xml");
				}

			}

			return 0;
		}
	}
}
