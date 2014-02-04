package com.dnsmob.alignbot {

	import flash.display.DisplayObject;

	import com.dnsmob.alignbot.IBotDispayObject;

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

		public function AlignBot (originalStageWidth:uint, originalStageHeight:uint, currentStageWidth:uint, currentStageHeight:uint, sanitize:Boolean = false) {
			AlignBot.originalStageWidth = originalStageWidth;
			AlignBot.originalStageHeight = originalStageHeight;
			AlignBot.currentStageWidth = currentStageWidth;
			AlignBot.currentStageHeight = currentStageHeight;
			AlignBot.sanitize = sanitize;
		}

		public static function control (displayObject:DisplayObject, alignment:Array, rect:BotRectangle = null, scaleType:String = scale):void {
			if (alignment) {
				if (!rect) rect = new BotRectangle ();

				var ldo:IBotDispayObject = getBotDisplayObject (displayObject);
				if (ldo) {
					ldo.rect = rect;
					ldo.alignment = alignment;
					ldo.scaleType = scaleType;
				} else {
					items.push (new BotDisplayObject (displayObject, rect, alignment, scaleType));
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

		private static function getBotDisplayObject (displayObject:DisplayObject):BotDisplayObject {
			for each (var obj:BotDisplayObject in items) {
				if (obj.displayObject == displayObject) {
					return obj;
				}
			}
			return null;
		}

		public function refresh ():void {
			sort ();
		}

		private static function sort ():void {
			for each (var obj:BotDisplayObject in items) {
				obj.sort ();
			}
		}
	}
}










