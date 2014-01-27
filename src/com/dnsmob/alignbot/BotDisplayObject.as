package com.dnsmob.alignbot {

	import flash.display.StageOrientation;
	import flash.geom.Point;

	import com.greensock.TweenMax;

	import flash.events.StageOrientationEvent;
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
		private var stageWidth:uint = AlignBot.stageWidth;
		private var stageHeight:uint = AlignBot.stageHeight;
		private var min:Number = 0;

		public function BotDisplayObject (displayObject:DisplayObject, rect:BotRectangle, alignment:Array, scaleType:String) {
			this.scaleType = scaleType;
			this.alignment = alignment;
			this.rect = rect;
			this.displayObject = displayObject;
			addListeners ();
			getDeviceOrientation ();
		}

		private function addListeners ():void {
			displayObject.addEventListener (Event.ADDED_TO_STAGE, onAddedToStage, false, 0, true);
			displayObject.stage.addEventListener (StageOrientationEvent.ORIENTATION_CHANGING, onOrientationChanging);
			displayObject.stage.addEventListener (StageOrientationEvent.ORIENTATION_CHANGE, onOrientationChange);
		}

		private function getDeviceOrientation ():void {
			var max:uint = Math.max (stageWidth, stageHeight);
			var min:uint = Math.min (stageWidth, stageHeight);
			if (displayObject.stage.deviceOrientation == StageOrientation.ROTATED_LEFT || displayObject.stage.deviceOrientation == StageOrientation.ROTATED_RIGHT) {
				stageWidth = max;
				stageHeight = min;
			} else {
				stageWidth = min;
				stageHeight = max;
			}
		}

		private function onOrientationChanging (event:StageOrientationEvent):void {
			var temp:uint;
			if ((event.afterOrientation == StageOrientation.DEFAULT || event.afterOrientation == StageOrientation.UPSIDE_DOWN) && event.afterOrientation != StageOrientation.UNKNOWN) {
				temp = stageHeight;
				stageHeight = stageWidth;
				stageWidth = temp;
			} else {
				temp = stageWidth;
				stageWidth = stageHeight;
				stageHeight = temp;
			}
		}

		private function onOrientationChange (event:StageOrientationEvent):void {
			sortScale ();
			if (alignment)
				TweenMax.to (displayObject, .30, { x:getNewPositions ().x, y:getNewPositions ().y });
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
				displayObject.x = getNewPositions ().x;
				displayObject.y = getNewPositions ().y;
			}
		}

		private function getNewPositions ():Point {
			var p:Point = new Point ();
			var alignX:uint = alignment [0];
			var alignY:uint = alignment [1];

			p.x = stageWidth / 2 * alignX - displayObject.width / 2 * alignX - getInternalX ();
			p.y = stageHeight / 2 * alignY - displayObject.height / 2 * alignY - getInternalY ();

			if (alignX < 1)
				p.x += rect.left;
			else if (alignX > 1)
				p.x -= rect.right;

			if (alignY < 1)
				p.y += rect.top;
			else if (alignY > 1)
				p.y -= rect.bottom;

			return p;
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
			displayObject.stage.removeEventListener (StageOrientationEvent.ORIENTATION_CHANGING, onOrientationChanging);
			displayObject.stage.removeEventListener (StageOrientationEvent.ORIENTATION_CHANGE, onOrientationChange);

			displayObject.removeEventListener (Event.ADDED_TO_STAGE, onAddedToStage);
			if (displayObject.parent && displayObject.parent.contains (displayObject))
				displayObject.parent.removeChild (displayObject);

			TweenMax.killTweensOf (displayObject);

			displayObject = null;
		}
	}
}









