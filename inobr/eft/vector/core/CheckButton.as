package inobr.eft.vector.core 
{
	import flash.display.Shape;
	import flash.display.SimpleButton;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Matrix;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import inobr.eft.common.lang.*;
	import inobr.eft.vector.events.ForceDiagramEvents;
	
	/**
	 * @author Peter Gerasimenko, gpstmp@gmail.com
	 */
	public class CheckButton extends SimpleButton 
	{
		/**
		 * Creates button that will dispatch ForceDiagramEvents.CHECK event.
		 */
		public function CheckButton() 
		{
			addEventListener(MouseEvent.CLICK, clickHandler);
		}
		
		/**
		 * Build all visual parts of check button.
		 */
		public function build():void
		{
			var mainState:Sprite = new Sprite();
			var back:Shape = new Shape();
			var matr:Matrix = new Matrix();
			matr.createGradientBox(100, 30, 90, 0, 0);
			back.graphics.beginGradientFill("linear", [0x63BF63, 0x159215], [1, 1], [0x55, 0xFF], matr);
			back.graphics.lineStyle(1, 0xCCCCCC);
			back.graphics.drawRect(0, 0, 100, 30);
			back.graphics.endFill();
			mainState.addChild(back);
			
			var buttonText:TextField = new TextField();
			var format:TextFormat = new TextFormat("Calibri", 16, 0xFFFFFF, true);
			buttonText.autoSize = TextFieldAutoSize.LEFT;
			buttonText.text = T('CheckButton');
			buttonText.setTextFormat(format);
			buttonText.x = (back.width - buttonText.width) / 2;
			buttonText.y = (back.height - buttonText.height) / 2;
			mainState.addChild(buttonText);
			
			upState = mainState;
			overState = mainState;
			downState = mainState;
			hitTestState = mainState;
		}
		
		private function clickHandler(event:MouseEvent):void
		{
			dispatchEvent(new Event(ForceDiagramEvents.CHECK, true));
		}
		
	}

}