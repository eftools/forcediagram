package inobr.eft.vector.core 
{
	import flash.display.DisplayObject;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.Rectangle;
	
	/**
	 * Area where all fulcrums and vectors must be placed.
	 * @author Peter Gerasimenko, gpstmp@gmail.com
	 */
	public class DrawingArea extends Sprite 
	{	
		private var _border:Shape;
		private var _borderThikness:uint = 1;
		private var _borderColor:uint = 0xCCCCCC;
		private var _myFulcrums:Array = [];
		private var _ground:Object;
		private var _rectangle:Rectangle = new Rectangle();
		
		/**
		 * Creates drawing area with check button.
		 * To set fulcrums use addFulcrum() method.
		 * To set border format use borderThikness and borderColor properties.
		 */
		public function DrawingArea() 
		{	
			// listener to add check button to the stage right after the drawing area
			addEventListener(Event.ADDED_TO_STAGE, addedToStageHandler);
		}
		
		/**
		 * Builds all visual parts of drawing area.
		 */
		public function build():void
		{
			this.x = _rectangle.x;
			this.y = _rectangle.y;
			
			if (_rectangle.width == 0 && _ground != null)
			{
				_rectangle.width = _ground.width;
				_rectangle.height = _ground.height;
			}
			else
				trace("Assert!!!! You must set width/height of drawing area or(and) its ground image!");
			
			addChild(_border = drawBorder());
			
			if (_ground)
				addChild(_ground as DisplayObject);
			for each (var item:Fulcrum in _myFulcrums) 
				addChild(item);
		}
		
		private function addedToStageHandler(event:Event):void
		{
			removeEventListener(Event.ADDED_TO_STAGE, addedToStageHandler);
			
			var checkButton:CheckButton = new CheckButton();
			checkButton.build();
			checkButton.x = x + width - checkButton.width;
			checkButton.y = y + height + 10;
			// add checkButton to vwctro workspace
			parent.addChild(checkButton);
		}
		
		private function drawBorder():Shape
		{
			var border:Shape = new Shape();
			border.graphics.lineStyle(_borderThikness, _borderColor);
			border.graphics.drawRect(0, 0, _rectangle.width, _rectangle.height);
			return border;
		}
		
		/**
		 * Adds fulcrum to the drawingArea. Remember that you must set
		 * (x, y) of fulcrum!
		 * 
		 * @param	fulcrum
		 */
		public function addFulcrum(fulcrum:Fulcrum):void
		{
			_myFulcrums.push(fulcrum);
			fulcrum.build();
		}
		
		/**
		 * Specifies X and Y coordinates of the drawing area.
		 * @param	x
		 * @param	y
		 */
		public function setPosition(x:int, y:int):void
		{
			_rectangle.x = x;
			_rectangle.y = y;
		}
		
		/**
		 * Specifies width and height of the drawing area (don't use this method if
		 * you set ground image of drawing area).
		 * @param	width
		 * @param	height
		 */
		public function setSize(width:int, height:int):void
		{
			_rectangle.width = width;
			_rectangle.height = height;
		}
		
		/**
		 * Border of drawing area.
		 */
		public function get border():Shape
		{
			return _border;
		}
		
		/**
		 * The list of fulcrums in drawing area.
		 */
		public function get myFulcrums():Array
		{
			return _myFulcrums;
		}
		
		/**
		 * Adds ground object (image/sprite/movieclip) to drawing area
		 */
		public function set ground(setValue:Object):void
		{
			_ground = setValue;
		}
		
		/**
		 * The thikness of border of drawing area.
		 */
		public function set borderThikness(value:uint):void 
		{
			_borderThikness = value;
		}
		
		/**
		 * The color of border of drawing area.
		 */
		public function set borderColor(value:uint):void 
		{
			_borderColor = value;
		}
		
	}

}