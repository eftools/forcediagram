package inobr.eft.vector.core 
{
	import flash.display.Sprite;
	import flash.events.Event;
	
	/**
	 * Use this class for quick build of single task with vectors.
	 * You must extend this class and just override initialize() method.
	 * 
	 * @author Peter Gerasimenko, gpstmp@gmail.com
	 */
	public class Initializer extends Sprite 
	{
		
		public function Initializer() 
		{
			if (stage) init();
			else addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		private function init(e:Event = null):void 
		{
			deleteListener();
			initialize();
		}
		
		private function deleteListener():void
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		protected function initialize():void
		{
			// to override!
		}
	}

}