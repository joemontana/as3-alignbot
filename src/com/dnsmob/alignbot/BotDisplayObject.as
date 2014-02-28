package com.dnsmob.alignbot {

	import com.greensock.TweenMax;

	import flash.desktop.NativeApplication;
	import flash.display.DisplayObject;
	import flash.display.StageOrientation;
	import flash.events.Event;
	import flash.events.StageOrientationEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;

	/**
	 * @author denis
	 */
	public class BotDisplayObject implements IBotDispayObject {

		private var _displayObject:DisplayObject;
		private var _rect:BotRectangle;
		private var _alignment:Array;
		private var _scaleType:String;
		private var _viewPort:Rectangle;
		private var currentStageWidth:uint;
		private var currentStageHeight:uint;
		private var min:Number = 0;
		private var originalScaleX:Number;
		private var originalScaleY:Number;
		private var _resizedViewPort:Rectangle;

		public function BotDisplayObject (displayObject:DisplayObject, rect:BotRectangle, alignment:Array, scaleType:String, viewPort:Rectangle) {
			currentStageWidth = AlignBot.currentStageWidth;
			currentStageHeight = AlignBot.currentStageHeight;
			_scaleType = scaleType;
			_alignment = alignment;
			_rect = rect;
			_displayObject = displayObject;
			_viewPort = viewPort;
			_resizedViewPort = new Rectangle (_viewPort.x, _viewPort.y, _viewPort.width, _viewPort.height);
			originalScaleX = displayObject.scaleX;
			originalScaleY = displayObject.scaleY;

			addListeners ();
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

		private function onOrientationChanging (event:StageOrientationEvent):void {
			if (event.afterOrientation != StageOrientation.UNKNOWN) {
				if (event.afterOrientation == StageOrientation.DEFAULT || event.afterOrientation == StageOrientation.UPSIDE_DOWN) {
					currentStageWidth = Math.min (AlignBot.currentStageWidth, AlignBot.currentStageHeight);
					currentStageHeight = Math.max (AlignBot.currentStageWidth, AlignBot.currentStageHeight);
				} else {
					currentStageWidth = Math.max (AlignBot.currentStageWidth, AlignBot.currentStageHeight);
					currentStageHeight = Math.min (AlignBot.currentStageWidth, AlignBot.currentStageHeight);
				}
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

			p.x = currentStageWidth / 2 * alignX - _resizedViewPort.width / 2 * alignX - getOffsetX ();
			p.y = currentStageHeight / 2 * alignY - _resizedViewPort.height / 2 * alignY - getOffsetY ();

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
				_resizedViewPort.width = _viewPort.width * m;
				_resizedViewPort.height = _viewPort.height * m;
				
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
			var ratio:Number = _resizedViewPort.width / _viewPort.width;
			_resizedViewPort.width = AlignBot.currentStageWidth;
			_resizedViewPort.height = _viewPort.height * ratio;
			_displayObject.scaleX = ratio;
			_displayObject.scaleY = ratio;
		}

		private function fitHeight ():void {
			var ratio:Number = _resizedViewPort.height / _viewPort.height;
			_resizedViewPort.height = AlignBot.currentStageHeight;
			_resizedViewPort.width = _viewPort.width * ratio;
			_displayObject.scaleX = ratio;
			_displayObject.scaleY = ratio;
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

		public function get viewPort ():Rectangle {
			return _viewPort;
		}

		public function set viewPort (r:Rectangle):void {
			_viewPort = r;
		}
	}
}









