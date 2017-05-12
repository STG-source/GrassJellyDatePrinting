package utilities
{
	public interface IProgress
	{
		/**
		 * How to use
		 * 
		 * send an function with this template
		 * function updateReportProgress(current:Object):void{
		 * 		// Example current is counter , count down or percentage value 0 => 100%
		 * }
		 * 
		 * **/
		function updateReport(func:Function):void;
	}

	
}