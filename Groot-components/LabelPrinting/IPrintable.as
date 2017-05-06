package LabelPrinting
{
	public interface IPrintable
	{
		/**
		 * Send Text for Printing something with your own device
		 * **/
		function printLabel():void;
		function stop():void;
		function set done(func:Function):void;
		function set fail(func:Function):void;
		function set setTextLabel(data:Object):void;
		function resetTextLabel():void;
		function set quantities(quantities:Number):void;
	}
}