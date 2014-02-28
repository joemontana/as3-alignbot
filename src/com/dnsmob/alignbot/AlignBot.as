package com.dnsmob.alignbot {

	import flash.geom.Rectangle;
	import flash.display.DisplayObject;

	/**
	 * @author denis
	 */
	public class AlignBot {

		private static var items:Array = new Array ();
		internal static var sanitize:Boolean;
		internal static var originalStageWidth:uint;
		internal static var originalStageHeight:uint;
		internal static var currentStageWidth:uint;
		internal static var currentStageHeight:uint;
		private static const scale:String = BotScale.NO_SCALE;
		private static var instantiated:Boolean = false;

		public static function setup (originalStageWidth:uint, originalStageHeight:uint, currentStageWidth:uint, currentStageHeight:uint, sanitize:Boolean = false):void {
			if (!instantiated) {
				instantiated = true;
				AlignBot.originalStageWidth = originalStageWidth;
				AlignBot.originalStageHeight = originalStageHeight;
				AlignBot.currentStageWidth = currentStageWidth;
				AlignBot.currentStageHeight = currentStageHeight;
				AlignBot.sanitize = sanitize;
			} else {
				throw new Error ('[alignbot has already been instantiated]');
			}
		}

		public static function control (displayObject:Object, alignment:Array, rect:BotRectangle = null, scaleType:String = scale, viewPort:Rectangle = null):void {
			if (alignment) {
				if (!rect) rect = new BotRectangle ();

				var ldo:IBotDispayObject = getBotDisplayObject (displayObject);
				if (!viewPort) viewPort = new Rectangle (0, 0, displayObject.width, displayObject.height);

				if (ldo) {
					ldo.rect = rect;
					ldo.alignment = alignment;
					ldo.scaleType = scaleType;
					ldo.viewPort = viewPort;
				} else {
					items.push (new BotDisplayObject (DisplayObject (displayObject), rect, alignment, scaleType, viewPort));
				}
				sort ();
			}
		}

		public static function destroy (displayObject:DisplayObject):void {
			var bdo:IBotDispayObject = getBotDisplayObject (displayObject);
			var pos:int = items.indexOf (bdo);
			if (pos >= 0) {
				bdo.destroy ();
				items.splice (pos, 1);
			}
		}

		public static function destroyAll ():void {
			for each (var bdo:BotDisplayObject in items) {
				bdo.destroy ();
			}
			items = new Array ();
		}

		private static function getFlashDisplayObject (displayObject:Object):BotDisplayObject {
			for each (var obj:BotDisplayObject in items) {
				if (obj.displayObject == displayObject) {
					return obj;
				}
			}
			return null;
		}

		private static function getBotDisplayObject (displayObject:Object):IBotDispayObject {
			switch (displayType (displayObject)) {
				case 'flash':
					return getFlashDisplayObject (displayObject);
				case 'starling':
				default:
					return null;
			}
		}

		private static function displayType (displayObject:Object):String {
			return 'flash';
		}

		public static function refresh ():void {
			sort ();
		}

		private static function sort ():void {
			for each (var obj:BotDisplayObject in items) {
				obj.sort ();
			}
		}
	}
}










