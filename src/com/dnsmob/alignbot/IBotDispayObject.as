package com.dnsmob.alignbot {

	import flash.geom.Rectangle;
	import flash.display.DisplayObject;

	/**
	 * @author denis
	 */
	public interface IBotDispayObject {

		function sort ():void;

		function destroy ():void;

		function get rect ():BotRectangle;

		function set rect (r:BotRectangle):void;

		function get alignment ():Array;

		function set alignment (a:Array):void;

		function get scaleType ():String;

		function set scaleType (s:String):void;

		function get displayObject ():DisplayObject;

		function get viewPort ():Rectangle;

		function set viewPort (r:Rectangle):void;
	}
}
