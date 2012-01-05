package inobr.eft.vector.events 
{
	/**
	 * Events of Vector workspace.
	 * @author Peter Gerasimenko, gpstmp@gmail.com
	 */
	public class ForceDiagramEvents 
	{
		/**
		 * This event dispathes every time the User rotates the vector.
		 */
		public static const VECTOR_ROTATED:String = "vectorRotated";
		
		/**
		 * This event dispatches when the User throws dragged vector.
		 */
		public static const VECTOR_MOVED:String = "vectorMoved";
		
		/**
		 * This event dispatches when the User clicks Check button.
		 */
		public static const CHECK:String = "check";
		
		/**
		 * This event dispatches when the drawing made without errors and 
		 * after CHECK event.
		 */
		public static const SUCCESS:String = "success";
	}

}