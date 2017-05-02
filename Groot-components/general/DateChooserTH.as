package general
{
	import mx.controls.DateChooser;
	import mx.controls.dataGridClasses.DataGridListData;
	import mx.controls.listClasses.IListItemRenderer;
	import mx.events.DateChooserEvent;
	import mx.events.FlexEvent;
	
	public class DateChooserTH extends DateChooser
	{
		public function DateChooserTH()
		{
			super();

			this.yearNavigationEnabled = true;
			this.dayNames = ['อา','จ','อ','พ','พฤ','ศ','ส'];
			this.monthNames = [
				'มกราคม','กุมภาพันธ์','มีนาคม','เมษายน', 
				'พฤษภาคม','มิถุนายน','กรกฏาคม','สิงหาคม', 
				'กันยายน','ตุลาคม','พฤศจิกายน','ธันวาคม'
			];

			this.addEventListener(FlexEvent.CREATION_COMPLETE, this.dateChooserOpen);
			this.addEventListener(DateChooserEvent.SCROLL, this.scrollHandler);
		}

		private function dateChooserOpen(event:FlexEvent):void
		{
			// trace('DateChooser hook CreationComplete');
			this.yearSymbol = '/' + Number(this.displayedYear + 543).toString();
		}

		private function scrollHandler(event:DateChooserEvent):void
		{
			// trace('DateChooser hook scrollHandler');
			this.yearSymbol = '/' + Number(this.displayedYear + 543).toString();
		}
	}
}