package com.dnsmob.alignbot {

	import flash.desktop.NativeApplication;
	import flash.display.StageOrientation;
	import flash.geom.Point;

	import com.greensock.TweenMax;

	import flash.events.StageOrientationEvent;
	import flash.display.DisplayObject;
	import flash.events.Event;

	/**
	 * @author denis
	 */
	public class BotDisplayObject implements IBotDispayObject {

		private var _displayObject:DisplayObject;
		private var _rect:BotRectangle;
		private var _alignment:Array;
		private var _scaleType:String;
		private var currentStageWidth:uint = AlignBot.currentStageWidth;
		private var currentStageHeight:uint = AlignBot.currentStageHeight;
		private var min:Number = 0;
		private var originalScaleX:Number;
		private var originalScaleY:Number;

		public function BotDisplayObject (displayObject:DisplayObject, rect:BotRectangle, alignment:Array, scaleType:String) {
			_scaleType = scaleType;
			_alignment = alignment;
			_rect = rect;
			_displayObject = displayObject;
			originalScaleX = displayObject.scaleX;
			originalScaleY = displayObject.scaleY;

			addListeners ();
			getDeviceOrientation ();
		}

		private function addListeners ():void {
			NativeApplication.nativeApplication.addEventListener (Event.ACTIVATE, onApplicationActivated, false, 0, true);
			_displayObject.addEventListener (Event.ADDED_TO_STAGE, onAddedToStage, false, 0, true);
			_displayObject.addEventListener (Event.REMOVED_FROM_STAGE, onRemovedFromStage, false, 0, true);
			_displayObject.stage.addEventListener (StageOrientationEvent.ORIENTATION_CHANGING, onOrientationChanging, false, 0, true);
			_displayObject.stage.addEventListener (StageOrientationEvent.ORIENTATION_CHANGE, onOrientationChange, false, 0, true);
		}

		private function onRemovedFromStage (event:Event = null):void {
			if (AlignBot.sanitize == true) {
				AlignBot.destroy (_displayObject);
			}
		}

		private function onApplicationActivated (event:Event):void {
			sort ();
		}

		private function getDeviceOrientation ():void {
			var max:uint = Math.max (currentStageWidth, currentStageHeight);
			var min:uint = Math.min (currentStageWidth, currentStageHeight);
			if (_displayObject.stage.deviceOrientation == StageOrientation.ROTATED_LEFT || _displayObject.stage.deviceOrientation == StageOrientation.ROTATED_RIGHT) {
				currentStageWidth = max;
				currentStageHeight = min;
			} else {
				currentStageWidth = min;
				currentStageHeight = max;
			}
		}

		private function onOrientationChanging (event:StageOrientationEvent):void {
			var temp:uint;
			if ((event.afterOrientation == StageOrientation.DEFAULT || event.afterOrientation == StageOrientation.UPSIDE_DOWN) && event.afterOrientation != StageOrientation.UNKNOWN) {
				temp = currentStageHeight;
				currentStageHeight = currentStageWidth;
				currentStageWidth = temp;
			} else {
				temp = currentStageWidth;
				currentStageWidth = currentStageHeight;
				currentStageHeight = temp;
			}
		}

		private function onOrientationChange (event:StageOrientationEvent):void {
			sortScale ();
			if (alignment)
				TweenMax.to (_displayObject, .35, { x:getNewPositions ().x, y:getNewPositions ().y });
		}

		private function onAddedToStage (event:Event):void {
			sort ();
		}

		public function sort ():void {
			if (_displayObject.stage) {
				sortScale ();
				sortAlignment ();
			}
		}

		private function sortAlignment ():void {
			if (alignment) {
				_displayObject.x = getNewPositions ().x;
				_displayObject.y = getNewPositions ().y;
			}
		}

		private function getNewPositions ():Point {
			var p:Point = new Point ();
			var alignX:uint = alignment [0];
			var alignY:uint = alignment [1];

			p.x = currentStageWidth / 2 * alignX - _displayObject.width / 2 * alignX - getOffsetX ();
			p.y = currentStageHeight / 2 * alignY - _displayObject.height / 2 * alignY - getOffsetY ();

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

		private function getOffsetX ():Number {
			min = 0;
			for each (var obj:DisplayObject in _displayObject) {
				min = Math.min (min, obj.x);
			}
			return min * _displayObject.scaleX;
		}

		private function getOffsetY ():Number {
			min = 0;
			for each (var obj:DisplayObject in _displayObject) {
				min = Math.min (min, obj.y);
			}
			return min * _displayObject.scaleY;
		}

		private function sortScale ():void {
			if (scaleType == BotScale.RETAIN_PROPORTION) {
				var w:Number = AlignBot.currentStageWidth / AlignBot.originalStageWidth;
				var h:Number = AlignBot.currentStageHeight / AlignBot.originalStageHeight;
				var m:Number = Math.max (w, h);
				_displayObject.scaleX = originalScaleX * m;
				_displayObject.scaleY = originalScaleY * m;
			} else if (scaleType != BotScale.NO_SCALE) {
				if (scaleType == BotScale.STRETCH) {
					_displayObject.width = currentStageWidth;
					_displayObject.height = currentStageHeight;
				} else if (scaleType == BotScale.FIT_LARGEST) {
					if (_displayObject.width > _displayObject.height)
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
			_displayObject.height = currentStageWidth * _displayObject.height / _displayObject.width;
			_displayObject.width = currentStageWidth;
		}

		private function fitHeight ():void {
			_displayObject.width = currentStageHeight * _displayObject.width / _displayObject.height;
			_displayObject.height = currentStageHeight;
		}

		public function destroy ():void {
			NativeApplication.nativeApplication.removeEventListener (Event.ACTIVATE, onApplicationActivated);
			
			_displayObject.stage.removeEventListener (StageOrientationEvent.ORIENTATION_CHANGING, onOrientationChanging);
			_displayObject.stage.removeEventListener (StageOrientationEvent.ORIENTATION_CHANGE, onOrientationChange);

			_displayObject.removeEventListener (Event.ADDED_TO_STAGE, onAddedToStage);
			_displayObject.removeEventListener (Event.REMOVED_FROM_STAGE, onRemovedFromStage);
			
			if (_displayObject.parent && _displayObject.parent.contains (_displayObject))
				_displayObject.parent.removeChild (_displayObject);

			TweenMax.killTweensOf (_displayObject);

			_displayObject = null;
		}

		// GETTERS/SETTERS
		public function get rect ():BotRectangle {
			return _rect;
		}

		public function set rect (r:BotRectangle):void {
			_rect = r;
		}

		public function get alignment ():Array {
			return _alignment;
		}

		public function set alignment (a:Array):void {
			_alignment = a;
		}

		public function get scaleType ():String {
			return _scaleType;
		}

		public function set scaleType (s:String):void {
			_scaleType = s;
		}

		public function get displayObject ():DisplayObject {
			return _displayObject;
		}
	}
}









