package general
{
	import mx.controls.DateField;
	import mx.controls.dataGridClasses.DataGridListData;
	import mx.controls.listClasses.IListItemRenderer;
	import mx.events.DateChooserEvent;
	import mx.events.DropdownEvent;
	
	
	public class DateFieldTH extends DateField implements IListItemRenderer
	{
		public function DateFieldTH()
		{
			super();
			
			this.formatString = 'DD/MM/YYYY';
			this.yearNavigationEnabled = true;
			this.dayNames = ['อา','จ','อ','พ','พฤ','ศ','ส'];
			this.monthNames = [
				'มกราคม','กุมภาพันธ์','มีนาคม','เมษายน', 
				'พฤษภาคม','มิถุนายน','กรกฏาคม','สิงหาคม', 
				'กันยายน','ตุลาคม','พฤศจิกายน','ธันวาคม'
			];
			
			this.addEventListener( DropdownEvent.OPEN, this.openHandler );
			this.addEventListener( DateChooserEvent.SCROLL, this.scrollHandler );
		}
		
		private function openHandler( event:DropdownEvent ):void{
			trace('DateField hook openHandler');
			this.yearSymbol = '/' + ( this.displayedYear + 543 );
		}
		
		private function scrollHandler( event:DateChooserEvent ):void{
			trace('DateField hook scrollHandler');
			this.yearSymbol = '/' + ( this.displayedYear + 543 );
		}
		
		override public function set data(value:Object):void{
			trace('value[ ( this.listData as DataGridListData ).dataField ]:' + value[ ( this.listData as DataGridListData ).dataField ]);
			this.text = value[ ( this.listData as DataGridListData ).dataField ];
		}
	}
}