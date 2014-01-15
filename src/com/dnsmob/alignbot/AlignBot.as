package com.dnsmob.alignbot {

	import flash.display.DisplayObject;

	/**
	 * @author denis
	 */
	public class AlignBot {

		private static var items:Array = new Array ();
		private static var objs:Array = new Array ();
		private static var sanitize:Boolean;
		internal static var stageWidth:uint;
		internal static var stageHeight:uint;

		public function AlignBot (stageWidth:uint, stageHeight:uint, sanitize:Boolean = false) {
			AlignBot.stageWidth = stageWidth;
			AlignBot.stageHeight = stageHeight;
			AlignBot.sanitize = sanitize;
		}

		public static function control (displayObject:DisplayObject, alignment:Array, rect:BotRectangle = null, scaleFactor:Number = 1):void {
			if (alignment) {
				if (!rect) {
					rect = new BotRectangle ();
					rect.top = displayObject.y;
					rect.bottom = stageHeight - (displayObject.y + displayObject.height);
					rect.left = displayObject.x;
					rect.right = stageWidth - (displayObject.x + displayObject.width);
				}

				var pos:int = objs.indexOf (displayObject);
				if (pos < 0) {
					objs.push (displayObject);
					items.push (new BotDisplayObject (displayObject, rect, alignment, scaleFactor));
				} else {
					var ldo:BotDisplayObject = items [pos];
					ldo.rect = rect;
					ldo.alignment = alignment;
					ldo.scaleFactor = scaleFactor;
				}
				sort ();
			}
		}

		public function refresh ():void {
			sort ();
		}

		private static function sort ():void {
			if (sanitize == true) {
				cleanUp ();
			}

			for each (var obj:BotDisplayObject in items) {
				obj.sort ();
			}
		}

		private static function cleanUp ():void {
			for each (var obj:BotDisplayObject in items) {
				if (!obj.displayObject.stage) {
					var index:uint = items.indexOf (obj);
					items.splice (index, 1);
					objs.splice (index, 1);

					obj.destroy ();
					obj = null;
				}
			}
		}
	}
}










