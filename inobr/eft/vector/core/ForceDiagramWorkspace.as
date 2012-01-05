package inobr.eft.vector.core
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.SimpleButton;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import inobr.eft.common.lang.*;
	import inobr.eft.vector.events.ForceDiagramEvents;
	import inobr.eft.common.ui.NotificationWindow;
	import inobr.eft.common.lang.Lang;
	
	/**
	 * ...
	 * @author Peter Gerasimenko, gpstmp@gmail.com
	 */
	public class ForceDiagramWorkspace extends Sprite 
	{
		private var _toolbar:Toolbar;
		private var _drawingArea:DrawingArea;
		private var _checkButton:SimpleButton;
		
		private var _myFulcrums:Array = [];
		private var _tryCount:uint = 0;
		private var _numberOfTries:uint = 2;
		private var _margin:int = 10;
		private var _rotationStep:uint = 15;
		
		/**
		 * Creates workspace with specified toolbar and drawing area.
		 * @param	lang	language class
		 */
		public function ForceDiagramWorkspace(lang:Object) 
		{
			// create toolbar and drawing area
			_toolbar = new Toolbar();
			_drawingArea = new DrawingArea();
			
			// add behaviour
			addEventListener(Event.ADDED_TO_STAGE, build);
			addEventListener(ForceDiagramEvents.VECTOR_MOVED, vectorMovedHandler);
			addEventListener(ForceDiagramEvents.VECTOR_ROTATED, vectorRotatedHandler);
			addEventListener(ForceDiagramEvents.CHECK, checkHandler);
			addEventListener(ForceDiagramEvents.SUCCESS, successHandler);
			Lang.Init(lang);
		}
		
		private function build(event:Event):void
		{
			removeEventListener(Event.ADDED_TO_STAGE, build);
			
			_drawingArea.build();
			addChild(_drawingArea);
			
			_toolbar.build();
			// automatic placement of the _toolbar
			if (_toolbar.autoPlace)
			{
				_toolbar.x = _drawingArea.x - _margin - _toolbar.width;
				_toolbar.y = _drawingArea.y;
			}
			// set the rotation step to each vector in workspace
			for each (var item:ForceVector in _toolbar.myVectors) 
				item.rotationStep = _rotationStep;
			addChild(_toolbar);
			
			// if user clicks the stage we deselect vector
			stage.addEventListener(MouseEvent.MOUSE_DOWN, mouseDownOnStageHandler);
			// in order to stopDrag whereever user throws mouse button (this may be needed 
			// when mouse is over Fulcrum)
			stage.addEventListener(MouseEvent.MOUSE_UP, mouseUpHandler);
		}
		
		private function mouseDownOnStageHandler(event:MouseEvent):void
		{
			if (ForceVector.selectedVector)
				ForceVector.selectedVector.removeSelection();
		}
		
		private function mouseUpHandler(event:MouseEvent):void
		{
			if (ForceVector.selectedVector)
				ForceVector.selectedVector.dispatchEvent(new Event(ForceDiagramEvents.VECTOR_MOVED, true));
		}
		
		
		private function successHandler(event:Event):void
		{
			// delete all behaviour of vectors
			for each (var item:ForceVector in _toolbar.myVectors) 
				item.destroy();
				
			stage.removeEventListener(MouseEvent.MOUSE_DOWN, mouseDownOnStageHandler);
			stage.removeEventListener(MouseEvent.MOUSE_UP, mouseUpHandler);
			removeEventListener(ForceDiagramEvents.VECTOR_MOVED, vectorMovedHandler);
			removeEventListener(ForceDiagramEvents.VECTOR_ROTATED, vectorRotatedHandler);
			removeEventListener(ForceDiagramEvents.CHECK, checkHandler);
			removeEventListener(ForceDiagramEvents.SUCCESS, successHandler);
		}
		
		private function vectorMovedHandler(event:Event):void
		{
			// check intersection with any fulcrum
			var vector:ForceVector = event.target as ForceVector;
			var allFulcrums:Array = _drawingArea.myFulcrums;
			for (var i:int = 0; i < allFulcrums.length; i++) 
			{
				if (allFulcrums[i].hitTestObject(vector.beginning))
				{
					(allFulcrums[i] as Fulcrum).attachVector(vector);
					vector.myFulcrum = allFulcrums[i];
					break;
				}
			}
			
			// if vector is not in fulcrum
			if(i == allFulcrums.length)
				vector.myFulcrum = null;
			
			// check if vector is fully in _toolbar or _drawingArea
			if(!isInContainer(_drawingArea, vector) && !isInContainer(_toolbar, vector))
			{
				vector.x = vector.lastPosition.x;
				vector.y = vector.lastPosition.y;
			}
			
			// show help
			if (_tryCount >= _numberOfTries)
				vector.showHelp(checkSingleVector(vector));
		}
		
		private function vectorRotatedHandler(event:Event):void
		{
			if (_tryCount >= _numberOfTries)
			{
				var vector:ForceVector = event.target.parent;
				vector.showHelp(checkSingleVector(vector));
			}
		}
		
		/**
		 * Check if item is fully in container (one box in another).
		 * This visual relation (not parent-child).
		 * 
		 * @param	container	Sprite that must fully contain item
		 * @param	item		Sprite that must be fully in container
		 * @return
		 */
		private function isInContainer(container:Sprite, item:Sprite):Boolean
		{
			var boundary:Rectangle = item.getBounds(container);
			if (boundary.x <= 0 || boundary.x >= container.width - boundary.width)
				return false;
			if (boundary.y <= 0 || boundary.y >= container.height - boundary.height)
				return false;
				
			return true;
		}
		
		private function checkHandler(event:Event):void
		{
			_tryCount++;
			var allVectors:Array = _toolbar.myVectors;
			var errorCount:int = 0;
			for each (var item:ForceVector in allVectors) 
			{
				if (checkSingleVector(item) != ForceVector.RIGHT)
					errorCount++;
			}
			
			// show notification window 
			if (errorCount == 0)
			{
				dispatchEvent(new Event(ForceDiagramEvents.SUCCESS, true));
				NotificationWindow.show(stage, T('SuccessWindowTitle'), T('RightDrawing'), true);
			}
			else
			{
				if(_tryCount < _numberOfTries)
					NotificationWindow.show(stage, T('ErrorWindowTitle'), T('WrongDrawing'), false);
				else
					NotificationWindow.show(stage, T('HelpWindowTitle'), T('HelpIsWorking'), false);
			}
		}
		
		/**
		 * Check if the vector is in right position with right angle.
		 * @param	vector	
		 * @return	"right", "wrong", "partlyright"
		 */
		private function checkSingleVector(vector:ForceVector):String
		{
			var parameters:Object = vector.parametersToCheck;
				
			// vector must be in toolbar
			if (isNaN(parameters.angle) && parameters.rightFulcrum == null)
			{
				if ((vector.x < 0 || vector.x > _toolbar.width) ||
					(vector.y < 0 || vector.y > _toolbar.height))
					return ForceVector.WRONG;
			}
			// vector must be in drawing area with specified angle
			if (!isNaN(parameters.angle) && parameters.rightFulcrum == null)
			{
				if (!_drawingArea.hitTestObject(vector) && parameters.angle != parameters.rotation)
					return ForceVector.WRONG;
				else if (parameters.currentFulcrum == null)
					 {
						if (xor(_drawingArea.hitTestObject(vector), parameters.angle == parameters.rotation))
							return ForceVector.PARTLYRIGHT;
					 }
					 else
						return ForceVector.WRONG;
			}
			// vector must be in fulcrum with specified angel
			if (!isNaN(parameters.angle) && parameters.rightFulcrum != null)
			{
				if (parameters.angle != parameters.rotation &&
					parameters.currentFulcrum != parameters.rightFulcrum)
					return ForceVector.WRONG;
				else if(xor(parameters.angle == parameters.rotation, parameters.currentFulcrum == parameters.rightFulcrum))
					return ForceVector.PARTLYRIGHT;
			}
			
			return ForceVector.RIGHT;
			
			function xor(lhs:Boolean, rhs:Boolean):Boolean 
			{
				return !( lhs && rhs ) && ( lhs || rhs );
			}
		}
		
		/**
		 * Returns a Bitmap of drawing area.
		 * 
		 * @return	Bitmap	snapshot drawing
		 */
		public function getDrawing():Bitmap
		{
			var allWorkspace:BitmapData = new BitmapData(stage.stageWidth, stage.stageHeight, true, 0);
			var drawing:BitmapData = new BitmapData(_drawingArea.width, _drawingArea.height, false, 0xFFFFFF);
			allWorkspace.draw(stage);
			
			var sourceRect:Rectangle = new Rectangle(_drawingArea.x, _drawingArea.y, _drawingArea.width, _drawingArea.height);
			var startPoint:Point = new Point(0, 0);
			drawing.copyPixels(allWorkspace, sourceRect, startPoint);
			
			return new Bitmap(drawing);
		}
		
		/**
		 * The toolbar of workspace
		 */
		public function set toolbar(setValue:Toolbar):void
		{
			_toolbar = setValue;
		}
		
		/**
		 * The toolbar of workspace
		 */
		public function get toolbar():Toolbar 
		{
			return _toolbar;
		}
		
		/**
		 * The drawing area of workspace
		 */
		public function set drawingArea(setValue:DrawingArea):void
		{
			_drawingArea = setValue;
		}
		
		/**
		 * The drawing area of workspace
		 */
		public function get drawingArea():DrawingArea 
		{
			return _drawingArea;
		}
		
		/**
		 * Specifies the number of User's tries that would be made without help.
		 */
		public function set numberOfTries(value:uint):void 
		{
			_numberOfTries = value;
		}
		
		/**
		 * Sets the rotation step (in grads) of all the vectors in workspace.
		 */
		public function set rotationStep(value:uint):void 
		{
			_rotationStep = value;
		}
		
	}

}