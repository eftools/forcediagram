package inobr.eft.vector.core 
{
	import flash.display.Sprite;
	import flash.display.Shape;
	import flash.display.Graphics;
	import flash.geom.Point;
	
	/**
	 * Fulcrum (point of force).
	 * @author Peter Gerasimenko, gpstmp@gmail.com
	 */
	public class Fulcrum extends Sprite 
	{
		private var _fulcrum:Sprite;
		private var _radius:uint;
		private var _show:Boolean = false;
		
		private var _fulcrumColor:uint = 0xFFFF11;
		private var _fulcrumBorderColor:uint = 0xFF0000;
		private var _fulcrumBorderSize:uint = 1;
		
		/**
		 * Creates fulcrum (circle).
		 * @param	x
		 * @param	y
		 * @param	radius
		 */
		public function Fulcrum(x:int, y:int, radius:uint = 5) 
		{
			this.x = x;
			this.y = y;
			_radius = radius;
		}
		
		/**
		 * Build all visual parts of fulcrum.
		 */
		public function build():void
		{
			addChild(_fulcrum = drawFulcrum());
			_fulcrum.visible = _show;
		}
		
		/**
		 * Place vector to the center of fulcrum.
		 * @param	vector
		 */
		public function attachVector(vector:ForceVector):void
		{	
			var globals:Point = vector.parent.globalToLocal(parent.localToGlobal(new Point(x, y)));
			vector.x = globals.x;
			vector.y = globals.y;
		}
		
		private function drawFulcrum():Sprite
		{
			var fulcrum:Sprite = new Sprite();
			
			var visiblePoint:Shape = new Shape();
			visiblePoint.graphics.beginFill(_fulcrumColor);
			visiblePoint.graphics.lineStyle(_fulcrumBorderSize, _fulcrumBorderColor);
			visiblePoint.graphics.drawCircle(0, 0, _radius);
			visiblePoint.graphics.endFill();
			
			var sensitiveArea:Shape = new Shape();
			sensitiveArea.graphics.beginFill(_fulcrumColor);
			sensitiveArea.graphics.drawCircle(0, 0, _radius * 2);
			sensitiveArea.graphics.endFill();
			sensitiveArea.alpha = 0.5;
			
			fulcrum.addChild(sensitiveArea);
			fulcrum.addChild(visiblePoint);
			
			return fulcrum;
		}
		
		/**
		 * If show is TRUE fulcrum will be visible.
		 */
		public function set show(setValue:Boolean):void
		{
			if (_fulcrum)
				_fulcrum.visible = setValue;
			_show = setValue;
		}
	}

}