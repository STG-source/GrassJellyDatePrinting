package SystemBase
{
	import mx.collections.ArrayCollection;
	import mx.collections.ArrayList;
	import mx.controls.Label;

	public class ServiceVersion
	{
		private var _hashVersionList:Array = new Array();
		public function ServiceVersion()
		{
			_hashVersionList[0] = {version:"2.00",hash:"4c2c6202"};
			_hashVersionList[1] = {version:"2.10",hash:"1b455a94"};
			_hashVersionList[2] = {version:"2.11",hash:"6f3d01db"};
			_hashVersionList[3] = {version:"2.12pre",hash:"9742bce7"};
			_hashVersionList[3] = {version:"2.12",hash:"a3c02646"};
		}

		public function toStringFromVersion(cmp:String):String
		{
			if(checkByHash(cmp))
			{
				return "Service ver. " + getByVersion(cmp).version;
			}
			else
			{
				return " Service ver. Unregister";
			}
			return null;
		}

		public function toStringFromHash(cmp:String):String
		{
			if(checkByHash(cmp))
			{
				return "Service ver. " + getByHash(cmp).version;
			}
			else
			{
				return " Service ver. Unregister";
			}
			return null;
		}

		public function checkByVersion(cmp:String):Boolean
		{
			if(getByVersion(cmp) != null)
				return true;
			return false;
		}

		public function checkByHash(cmp:String):Boolean
		{
			if(getByHash(cmp) != null)
				return true;
			return false;
		}

		public function getByHash(cmp:String):Object
		{
			for(var i:int = 0;i < _hashVersionList.length;i++){
				if(_hashVersionList[i].hash == cmp)
					return _hashVersionList[i];
			}
			return null;
		}

		public function getByVersion(cmp:String):Object
		{
			for(var i:int = 0;i < _hashVersionList.length;i++){
				if(_hashVersionList[i].version == cmp)
					return _hashVersionList[i];
			}
			return null;
		}
	}
}