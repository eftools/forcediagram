package  
{
	import inobr.eft.vector.core.Fulcrum;
	import inobr.eft.vector.core.Initializer;
	import flash.display.Bitmap;
	import inobr.eft.vector.core.ForceDiagramWorkspace;
	import inobr.eft.vector.lang.ru;
	import inobr.eft.vector.lang.en;
	
	/**
	 * ...
	 * @author Peter Gerasimenko, gpstmp@gmail.com
	 */
	[SWF(width = "700", height = "460", frameRate = "40", backgroundColor = "#FFFFFF")]
	public class ForceDiagram extends Initializer
	{
		/* These classes (images) are used for development. 
		 * They are not needed in SWC so all references to them
		 * are commented.
		 *
		[Embed(source="formulation.png")]
		private var Formulation:Class;
		
		[Embed(source="ground.png")]
		private var GroundImage:Class;
		*/
		
		override protected function initialize():void
		{
			// add formulation of task
			/*var formulation:Bitmap = new Formulation();
			addChild(formulation);
			*/
			
			var workspace:ForceDiagramWorkspace = new ForceDiagramWorkspace(en);
			
			workspace.drawingArea.setPosition(330, 50);
			workspace.drawingArea.setSize(335, 250);
			var bodyCenter:Fulcrum = new Fulcrum(170, 136);
			var bodySide:Fulcrum = new Fulcrum(109, 136);
			bodyCenter.show = true;
			workspace.drawingArea.addFulcrum(bodyCenter);
			workspace.drawingArea.addFulcrum(bodySide);
			
			workspace.toolbar.setPosition(25, 255);
			workspace.toolbar.setSize(222, 165);
			workspace.toolbar.addVector("F_тр", 60, 180, bodyCenter);
			workspace.toolbar.addVector("F_тяж", 40, 90, bodyCenter);
			workspace.toolbar.addVector("N", 40, 270, bodyCenter);
			workspace.toolbar.addVector("a", 60, 180);
			workspace.toolbar.addVector("F_тяги", 100);
			
			addChild(workspace);
		}
	}

}