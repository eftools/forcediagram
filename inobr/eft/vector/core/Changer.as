package inobr.eft.vector.core 
{
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import inobr.eft.vector.events.ForceDiagramEvents;
	
	/**
	 * @author Peter Gerasimenko, gpstmp@gmail.com
	 */
	public class Changer extends Sprite 
	{
		private var _isRotated:Boolean = false;
		
		/**
		 * Creates indicator of rotation that will dispatch ForceDiagramEvents.VECTOR_ROTATED event.
		 */
		public function Changer() 
		{
			buttonMode = true;
			addEventListener(MouseEvent.MOUSE_DOWN, mouseDownHandler);
			addEventListener(Event.ADDED_TO_STAGE, addedToStageHandler);
		}
		
		/**
		 * Builds all visual parts of Changer.
		 */
		public function build():void
		{
			var rotationIndicator:Sprite = new RotationIndicator();
			addChild(rotationIndicator);
		}
		
		private function addedToStageHandler(event:Event):void
		{
			removeEventListener(Event.ADDED_TO_STAGE, addedToStageHandler);
			stage.addEventListener(MouseEvent.MOUSE_UP, mouseUpUnderStageHandler);
			stage.addEventListener(MouseEvent.MOUSE_MOVE, mouseMoveHandler);
			
			function mouseUpUnderStageHandler(event:MouseEvent):void
			{
				_isRotated = false;
			}
		}
		
		private function mouseMoveHandler(event:MouseEvent):void
		{
			if (_isRotated)
			{
				dispatchEvent(new Event(ForceDiagramEvents.VECTOR_ROTATED, true));
			}
		}
		
		private function mouseDownHandler(event:MouseEvent):void
		{
			event.stopPropagation();
			_isRotated = true;
		}		
	}

}