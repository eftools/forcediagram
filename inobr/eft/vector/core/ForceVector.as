package inobr.eft.vector.core 
{
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.filters.GlowFilter;
	import flash.geom.Point;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.utils.*;
	import inobr.eft.vector.events.ForceDiagramEvents;

	
	/**
	 * Dragable, rotatable vector.
	 * 
	 * @author Peter Gerasimenko, gpstmp@gmail.com
	 */
	public class ForceVector extends Sprite 
	{
		private static var _selectedVector:ForceVector;
		private static var _allVectors:Array = [];
		private var _changer:Sprite;
		private var _label:Sprite;
		private var _length:uint;
		private var _rotationStep:uint = 15;
		
		private var _givenName:String;
		private var _angle:Number;
		private var _fulcrum:Fulcrum;
		
		// _body contains arrow, line and circle (with back to expand the selection area)
		// all filters that show selection/correctness are applied to _body
		private var _body:Sprite;
		private var _circle:Shape;
		private var _line:Shape;
		private var _arrow:Shape;
		private var _back:Shape;
		private var _color:uint = 0x000000;
		private var _hilightColor:uint = 0x00FF00;
		private var _thickness:uint = 2;
		
		private var _selected:Boolean = false;
		private var _myFulcurm:Fulcrum = null;
		private var _lastPosition:Point;
		
		private static const YSHIFTRATIO:Number = 0.9;
		private static const LABELMARGIN:int = 2;
		private static const RIGHT_HELP_COLOR:uint = 0x00FF00;
		private static const WRONG_HELP_COLOR:uint = 0xFF0000;
		private static const PARTLYRIGHT_HELP_COLOR:uint = 0xFFCC00;
		
		public static const RIGHT:String = "right";
		public static const PARTLYRIGHT:String = "partlyright";
		public static const WRONG:String = "wrong";
		
		/**
		 * Creates vector with specified parameters. If the vector mustn't be used 
		 * in drawing don't set angle and fulcrum. If the vector must be in
		 * drawing area set angle (not fulcrum).
		 * @param	lable	use "_1" to create index
		 * @param	length	in pixels
		 * @param	angle	in grads
		 * @param	fulcrum	where the vector must be
		 */
		public function ForceVector(lable:String, length:uint, angle:Number = NaN, fulcrum:Fulcrum = null) 
		{
			_givenName = lable;
			_length = length;
			_angle = angle;
			_fulcrum = fulcrum;
			_allVectors.push(this);
			
			// in order to make deselection by clicking on the stage
			addEventListener(Event.ADDED_TO_STAGE, addedToStageHandler);
		}
		
		/**
		 * Creates all visual part of vector.
		 */
		public function build():void
		{
			_body = drawBody();
			addChild(_body);
			
			_changer = drawChanger();
			_changer.x = _body.width;
			_changer.y = - _changer.height / 2;
			_changer.visible = false;
			addChild(_changer);
			
			_label = drawLabel(_givenName);
			_label.x = _body.width - _label.width / 1.8;
			_label.y = - _label.height / 2 - _thickness;
			addChild(_label);
		}
		
		/**
		 * Remove all event listeners to destroy behaviour.
		 */
		public function destroy():void
		{
			_body.removeEventListener(MouseEvent.MOUSE_DOWN, mouseDownHandler);
			removeEventListener(ForceDiagramEvents.VECTOR_ROTATED, vectorRotatedHandler);
			removeEventListener(ForceDiagramEvents.VECTOR_MOVED, vectorMovedHandler);
		}
		
		private function addedToStageHandler(event:Event):void
		{
			removeEventListener(Event.ADDED_TO_STAGE, addedToStageHandler);
			// add behaviour
			_body.addEventListener(MouseEvent.MOUSE_DOWN, mouseDownHandler);
			addEventListener(ForceDiagramEvents.VECTOR_ROTATED, vectorRotatedHandler);
			addEventListener(ForceDiagramEvents.VECTOR_MOVED, vectorMovedHandler);
		}
		
		private function vectorMovedHandler(event:Event):void
		{
			stopDrag();
		}
		
		private function mouseDownHandler(event:MouseEvent):void
		{
			_selectedVector = setSelection();
			_lastPosition = new Point(x, y);
			startDrag();
			// stop this event in order to prevent stage-click event
			event.stopPropagation();
		}
		
		private function vectorRotatedHandler(event:Event):void
		{
			// convert coordinates to unified coordinate system
			var centerPoint:Point = new Point(this.x, this.y);
			var mousePoint:Point = parent.globalToLocal(localToGlobal(new Point(mouseX, mouseY)));
			
			var angleRad:Number = Math.atan(Math.abs(mousePoint.y - centerPoint.y) / Math.abs(mousePoint.x - centerPoint.x));
			var angleGrad:Number = angleRad * 180 / Math.PI;
			// amends value of angleGrad in order to recive angle from 0 to 360
			// use four quadrants of coordinate system (I, II, III, IV) 
			if ((mousePoint.x - centerPoint.x) <= 0 && (mousePoint.y - centerPoint.y) > 0)
				angleGrad = 180 - angleGrad;
			if ((mousePoint.x - centerPoint.x) < 0 && (mousePoint.y - centerPoint.y) < 0)
				angleGrad = 180 + angleGrad;
			if ((mousePoint.x - centerPoint.x) >= 0 && (mousePoint.y - centerPoint.y) < 0)
				angleGrad = 360 - angleGrad;
			// is offset more than _rotationStep?	
			if (Math.sin((angleGrad - rotation) * Math.PI / 180) > Math.sin(_rotationStep * Math.PI / 360))
				rotation += _rotationStep;
			if (Math.sin((angleGrad - rotation) * Math.PI / 180) < - Math.sin(_rotationStep * Math.PI / 360))
				rotation -= _rotationStep;
		}
		
		/**
		 * Select vector (makes it glows).
		 * @return selected ForceVector
		 */
		public function setSelection():ForceVector
		{
			if (_selectedVector)
				_selectedVector.removeSelection();
			_changer.visible = true;
			_selected = true;
			var hilightFilter:Array = [new GlowFilter(_hilightColor, 1, 2, 2, 4)];
			_body.filters = hilightFilter;
			return this;
		}
		
		/**
		 * Deselect vector.
		 */
		public function removeSelection():void
		{
			_selectedVector = null;
			_changer.visible = false;
			_selected = false;
			_body.filters = [];
		}
		
		/**
		 * Drawing of all components of Vector's body: circle, line, arrow.
		 * @return	the body of Vector
		 */
		private function drawBody():Sprite
		{
			var body:Sprite = new Sprite();
			
			_circle = new Shape();
			_circle.graphics.lineStyle(_thickness / 2, _color);
			_circle.graphics.drawCircle(0, 0, 2 * _thickness);
			body.addChild(_circle);
			
			_line = new Shape();
			_line.graphics.lineStyle(_thickness, _color);
			_line.graphics.lineTo(_length, 0);
			_line.x = _circle.width - 2 * _thickness;
			body.addChild(_line);
			
			// 2.5 (not 3!) is in order to shift back lines of arrow
			_arrow = new Shape();
			_arrow.graphics.lineStyle(_thickness, _color);
			_arrow.graphics.lineTo(2.5 * _thickness, 0);
			_arrow.graphics.lineStyle(_thickness / 2, _color);
			_arrow.graphics.moveTo(3 * _thickness, 0);
			_arrow.graphics.lineTo(0, -2 * _thickness);
			_arrow.graphics.moveTo(3 * _thickness, 0);
			_arrow.graphics.lineTo(0, 2 * _thickness);
			_arrow.x = _line.x + _line.width - _thickness;
			body.addChild(_arrow);
			
			_back = new Shape();
			_back.graphics.beginFill(0xFFFF11, 0.01);
			_back.graphics.drawRect(0, 0, body.width, body.height);
			_back.graphics.endFill();
			// place _back right under the _body
			_back.x = - 2 * _thickness;
			_back.y = - body.height / 2;
			body.addChild(_back);
			
			return body;
		}
		
		/**
		 * Draws object for rotation and possibly length changing.
		 * @return	changer
		 */
		private function drawChanger():Sprite
		{
			var changer:Changer = new Changer();
			changer.build();
			return changer as Sprite;
		}
		
		/**
		 * Draws lable of Vector (text with arrow and index).
		 * @return	the lable of Vector with vector symbol (arrow on top)
		 */
		private function drawLabel(givenName:String):Sprite
		{
			var label:Sprite = new Sprite();
			var pseudoLabel:Sprite = new Sprite();
			// forming name textField
			var varname:TextField = new TextField();
			var format:TextFormat = new TextFormat("Calibri", 20, 0x000000, true);
			
			varname.autoSize = TextFieldAutoSize.LEFT;
			varname.selectable = false;
			varname.defaultTextFormat = format;
			// find all chars after "_"
			var indexPattern:RegExp = /_.+/;
			var indexText:String = indexPattern.exec(givenName);
			
			if (indexText)
			{
				// separate name and index
				indexText = indexText.replace("_", "");
				varname.text = givenName.replace(indexPattern, "");
				// forming index TextField
				var varindex:TextField = new TextField();
				format.size = 12;
				
				varindex.text = indexText;
				varindex.autoSize = TextFieldAutoSize.LEFT;
				varindex.selectable = false;
				varindex.setTextFormat(format);
				
				// place index
				varindex.x = varname.textWidth + 1;
				varindex.y = varname.textHeight - varindex.textHeight * YSHIFTRATIO;
				
				pseudoLabel.addChild(varindex);
				pseudoLabel.addChild(varname);
			}
			else
			{
				varname.text = givenName;
				pseudoLabel.addChild(varname);
			}
			
			// draw arrow symbol above the name of vector
			var thickness:int = 1;
			var arrow:Shape = new Shape();
			arrow.graphics.beginFill(_color);
			arrow.graphics.drawRect(0, 0, 9, thickness);
			arrow.graphics.endFill();
			arrow.graphics.beginFill(_color);
			arrow.graphics.drawRect(5, -2, thickness, 5);
			arrow.graphics.drawRect(6, -1, thickness, 3);
			arrow.graphics.endFill();
			arrow.y = varname.y + 3;
			arrow.x = (varname.width - arrow.width) / 2;
			pseudoLabel.addChild(arrow);
			// draw background circle for good alignment
			var back:Shape = new Shape();
			back.graphics.beginFill(0xFFFFFF, 0.8);
			back.graphics.drawCircle(0, 0, Math.max(pseudoLabel.width, pseudoLabel.height) / 2 + LABELMARGIN);
			back.graphics.endFill();
			label.addChild(back);
			
			pseudoLabel.x = - pseudoLabel.width / 2;
			pseudoLabel.y = - pseudoLabel.height / 2;
			
			label.addChild(pseudoLabel);
			
			return label;
		}
		
		/**
		 * Makes vector blink (in right, wrong or partlyright cases).
		 * @param	correct	RIGHT, WRONG or PARTLYRIGHT
		 */
		public function showHelp(correct:String):void
		{
			// blinking is made by applying Glowing filter to objects
			var helpFilters:Array = new Array();
			var repaintTimeout:uint; 
			var alphaValue:Number = 0;
			var i:Number = 0;
			
			switch (correct) 
			{
				case RIGHT:
					repaintTimeout = setInterval(makeBlink, 30, RIGHT_HELP_COLOR);
					break;
				case WRONG:
					repaintTimeout = setInterval(makeBlink, 30, WRONG_HELP_COLOR);
					break;
				case PARTLYRIGHT:
					repaintTimeout = setInterval(makeBlink, 30, PARTLYRIGHT_HELP_COLOR);
					break;
					
				default:
				break;
			}
			
			/* blinking realized by changing the filter parameter within the specified period of time
			 * 3.5 * Math.PI means two periods of Sinus, so there will be only two blinks
			 */
			function makeBlink(color:Number):void
			{
				helpFilters.pop();
				alphaValue = (Math.sin(i) + 1) / 2;
				helpFilters.push(new GlowFilter(color, alphaValue, 6, 6, 4));
				_body.filters = helpFilters;
				i += Math.PI / 10;
				/* deleting all the filters and clearing interval after two periods of Sinus */
				if (i > 3.5 * Math.PI)
				{
					_body.filters = [];
					clearInterval(repaintTimeout);
				}
			}
		}
		
		// GETTERS AND SETTERS
		/**
		 * Color of vector and its lable (BLACK by default)
		 */
		public function set color(setValue:uint):void
		{
			_color = setValue;
		}
		
		/**
		 * Parameters are angel, rotation, currentFulcrum and rightFulcrum
		 */
		public function get parametersToCheck():Object
		{
			var parameters:Object = new Object();
			parameters.angle = _angle;
			parameters.rotation = rotation > 0 ? rotation : 360 + rotation;
			parameters.currentFulcrum = _myFulcurm;
			parameters.rightFulcrum = _fulcrum;
			return parameters;
		}
		
		/**
		 * Active (selected) vector
		 */
		public static function get selectedVector():ForceVector
		{
			return _selectedVector;
		}
		
		/**
		 * The list of all vectors
		 */
		public static function get allVectors():Array
		{
			return _allVectors;
		}
		
		/**
		 * The beginning of vector (circle)
		 */
		public function get beginning():Shape
		{
			return _circle;
		}
		
		/**
		 * Last (previous) coordinates of vector
		 */
		public function get lastPosition():Point
		{
			return _lastPosition;
		}
		
		/**
		 * The fulcrum at which there is a vector
		 */
		public function set myFulcrum(setValue:Fulcrum):void
		{
			_myFulcurm = setValue;
		}
		
		// in order to rotate label
		override public function set rotation(value:Number):void
		{
			_label.rotation = - value;
			super.rotation = value;
		}
		
		/**
		 * Sets the grad step of rotation.
		 */
		public function set rotationStep(value:uint):void 
		{
			_rotationStep = value;
		}
	}

}