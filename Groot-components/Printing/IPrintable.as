package Printing
{
	public interface IPrintable
	{
		/**
		 * Send Text for Printing something with your own device
		 * **/
		function printLabel():void;
		function set done(func:Function):void;
		function set fail(func:Function):void;
		function set setTextLabel(data:Object):void;
		function resetTextLabel():void;
		function set quantities(quantities:Number):void;
	}
}