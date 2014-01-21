package com.dnsmob.alignbot {

	import flash.display.DisplayObject;
	import flash.events.Event;

	/**
	 * @author denis
	 */
	public class BotDisplayObject {

		public var displayObject:DisplayObject;
		public var rect:BotRectangle;
		public var alignment:Array;
		public var scaleFactor:String;
		private static const stageWidth:uint = AlignBot.stageWidth;
		private static const stageHeight:uint = AlignBot.stageHeight;

		public function BotDisplayObject (displayObject:DisplayObject, rect:BotRectangle, alignment:Array, scaleFactor:String) {
			this.scaleFactor = scaleFactor;
			this.alignment = alignment;
			this.rect = rect;
			this.displayObject = displayObject;
			addListeners ();
		}

		private function addListeners ():void {
			displayObject.addEventListener (Event.ADDED_TO_STAGE, onAddedToStage, false, 0, true);
		}

		private function onAddedToStage (event:Event):void {
			sort ();
		}

		public function sort ():void {
			if (displayObject.stage) {
				if (alignment) {
					var alignX:uint = alignment [0];
					var alignY:uint = alignment [1];

					displayObject.x = stageWidth / 2 * alignX - displayObject.width / 2 * alignX;
					displayObject.y = stageHeight / 2 * alignY - displayObject.height / 2 * alignY;

					if (alignX < 1)
						displayObject.x += rect.left;
					else if (alignX > 1)
						displayObject.x -= rect.right;

					if (alignY < 1)
						displayObject.y += rect.top;
					else if (alignY > 1)
						displayObject.y -= rect.bottom;
				}
			}
		}

		public function destroy ():void {
			displayObject.removeEventListener (Event.ADDED_TO_STAGE, onAddedToStage);
			if (displayObject.parent && displayObject.parent.contains (displayObject))
				displayObject.parent.removeChild (displayObject);
				
			displayObject = null;
		}
	}
}









