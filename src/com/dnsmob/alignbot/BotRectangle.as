package com.dnsmob.alignbot {
	/**
	 * @author denis
	 */
	public class BotRectangle {

		public var top:Number;
		public var right:Number;
		public var bottom:Number;
		public var left:Number;

		public function BotRectangle (top:Number = 0, right:Number = 0, bottom:Number = 0, left:Number = 0) {
			this.left = left;
			this.bottom = bottom;
			this.right = right;
			this.top = top;
		}
	}
}
