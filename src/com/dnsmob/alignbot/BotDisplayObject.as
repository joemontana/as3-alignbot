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
		public var scaleType:String;
		private static const stageWidth:uint = AlignBot.stageWidth;
		private static const stageHeight:uint = AlignBot.stageHeight;
		private var min:Number = 0;

		public function BotDisplayObject (displayObject:DisplayObject, rect:BotRectangle, alignment:Array, scaleType:String) {
			this.scaleType = scaleType;
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
				sortScale ();
				sortAlignment ();
			}
		}

		private function sortAlignment ():void {
			if (alignment) {
				var alignX:uint = alignment [0];
				var alignY:uint = alignment [1];

				displayObject.x = stageWidth / 2 * alignX - displayObject.width / 2 * alignX - getInternalX ();
				displayObject.y = stageHeight / 2 * alignY - displayObject.height / 2 * alignY - getInternalY ();

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

		private function getInternalX ():Number {
			min = 0;
			for each (var obj:DisplayObject in displayObject) {
				min = Math.min (min, obj.x);
			}
			return min * displayObject.scaleX;
		}
		
		private function getInternalY ():Number {
			min = 0;
			for each (var obj:DisplayObject in displayObject) {
				min = Math.min (min, obj.y);
			}
			return min * displayObject.scaleY;
		}

		private function sortScale ():void {
			if (scaleType != BotScale.NO_SCALE) {
				if (scaleType == BotScale.STRETCH) {
					displayObject.width = stageWidth;
					displayObject.height = stageHeight;
				} else if (scaleType == BotScale.FIT_LARGEST) {
					if (displayObject.width > displayObject.height)
						fitHeight ();
					else
						fitWidth ();
				} else if (scaleType == BotScale.FIT_WIDTH) {
					fitWidth ();
				} else if (BotScale.FIT_HEIGHT) {
					fitHeight ();
				}
			}
		}

		private function fitWidth ():void {
			displayObject.height = stageWidth * displayObject.height / displayObject.width;
			displayObject.width = stageWidth;
		}

		private function fitHeight ():void {
			displayObject.width = stageHeight * displayObject.width / displayObject.height;
			displayObject.height = stageHeight;
		}

		public function destroy ():void {
			displayObject.removeEventListener (Event.ADDED_TO_STAGE, onAddedToStage);
			if (displayObject.parent && displayObject.parent.contains (displayObject))
				displayObject.parent.removeChild (displayObject);

			displayObject = null;
		}
	}
}









