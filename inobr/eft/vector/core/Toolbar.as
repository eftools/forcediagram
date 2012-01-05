package inobr.eft.vector.core 
{
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.geom.Rectangle;
	import inobr.eft.common.keyboard.KeyCodes;
	import inobr.eft.common.ui.BlockFormat;
	
	/**
	 * ...
	 * @author Peter Gerasimenko, gpstmp@gmail.com
	 */
	public class Toolbar extends Sprite 
	{
		private var _myVectors:Array = [];
		private var _format:BlockFormat = new BlockFormat();
		private var _setWidth:uint;
		private var _setHeight:uint;
		private var _rectangle:Rectangle = new Rectangle(NaN);
		private var _margin:uint = 5;
		private var _autoPlace:Boolean = false;
		
		/**
		 * Creates toolbar with specified width and height. Use setPosition() to set
		 * X and Y (if you don't use this the toolbar will be placed to the left of drawing area
		 * with default margin. In this case you must define drawing area first and then define toolbar.
		 * Use setSize() to set width and height of the toolbar.
		 * Use addVector() to add vectors.
		 */
		public function Toolbar() 
		{
			
		}
		
		/**
		 * Use this method after setting all the parameters of toolbar.
		 * Creates visual part of toolbar.
		 */
		public function build():void
		{
			if (isNaN(_rectangle.x))
				_autoPlace = true;
			else
			{
				this.x = _rectangle.x;
				this.y = _rectangle.y;
			}
			addChild(drawBack());
			placeToolbarItems();
		}
		
		/**
		 * We try to place vectors in one layer, if it is impossible
		 * we make two layers or more.
		 */
		private function placeToolbarItems():void
		{
			var layer:Array = [];
			var layerWidth:int = _margin;
			var Y:int = 0;
			
			for (var i:int = 0; i < _myVectors.length; i++) 
			{
				layerWidth += _myVectors[i].width + _margin;
				if (layerWidth < width)
					layer.push(_myVectors[i]);
				else
				{
					layerWidth -= (_myVectors[i].width + 2 * _margin);
					placeLayer();
					i--;
				}
			}
			
			layerWidth -= 2 * _margin;
			placeLayer();
			
			// place all vectors in current layer
			function placeLayer():void
			{
				var X:int = (width - layerWidth) / 2;
				Y += maxHeight();
				for (var j:int = 0; j < layer.length; j++)
				{
					layer[j].x = (layer[j - 1] ? layer[j - 1].x + layer[j - 1].width +_margin : X);
					layer[j].y = Y;
					addChild(layer[j]);
				}
				
				layerWidth = _margin;
				layer = [];
			}
			
			// find vector in a layer with max height
			function maxHeight():Number
			{
				var maxHeight:Number = 0;
				for each (var item:ForceVector in layer) 
					maxHeight = item.height > maxHeight ? item.height : maxHeight;
				return maxHeight;
			}
		}
		
		/**
		 * Use this method to add a vector on the toolbar.
		 * If angle is not set the right position of vector is toolbar (vector should not be used).
		 * If angle is set without fulcrum the right position of vector is drawingArea.
		 * 
		 * @param	lable	use _ to make index ("F_t")
		 * @param	length	in pixels	
		 * @param	angle	the right angle of vector (0 to 359)
		 * @param	fulcrum the right fulcrum of vector
		 */
		public function addVector(label:String, length:uint, angle:Number = NaN, fulcrum:Fulcrum = null):void
		{
			var newVector:ForceVector = new ForceVector(label, length, angle, fulcrum);
			newVector.build();
			_myVectors.push(newVector);
		}
		
		private function drawBack():Shape
		{
			var back:Shape = new Shape();
			back.graphics.beginFill(_format.blockFill);
			back.graphics.lineStyle(_format.borderWidth, _format.borderColor);
			back.graphics.drawRect(0, 0, _rectangle.width, _rectangle.height);
			back.graphics.endFill();
			return back;
		}
		
		/**
		 * Specifies X and Y coordinates of the toolbar.
		 * @param	x
		 * @param	y
		 */
		public function setPosition(x:int, y:int):void
		{
			_rectangle.x = x;
			_rectangle.y = y;
		}
		
		/**
		 * Specifies width and height of the toolbar.
		 * @param	width
		 * @param	height
		 */
		public function setSize(width:int, height:int):void
		{
			_rectangle.width = width;
			_rectangle.height = height;
		}
		
		/**
		 * Sets new BlockFormat for toolbar (change color and border)
		 */
		public function set format(setValue:BlockFormat):void
		{
			_format = setValue;
		}
		
		/**
		 * The list of vectors in toolbar.
		 */
		public function get myVectors():Array
		{
			return _myVectors;
		}
		
		// width of toolbar is the width of its box (if vectors are out of toolbar 
		// the width would be uncorrect)
		override public function get width():Number 
		{
			return _rectangle.width;
		}
		
		// height of toolbar is the height of its box (if vectors are out of toolbar 
		// the height would be uncorrect)
		override public function get height():Number 
		{
			return _rectangle.height;
		}
		
		/**
		 * If it is TRUE toolbar is placed to the left of rdawing area.
		 */
		public function get autoPlace():Boolean 
		{
			return _autoPlace;
		}
	}

}