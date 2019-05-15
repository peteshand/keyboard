package keyboard;

import keyboard.Key;
import openfl.Lib;
import openfl.events.Event;
import openfl.events.KeyboardEvent;
import haxe.Constraints.Function;

using utils.FunctionUtil;

/**
 * ...
 * @author P.J.Shand
 */
class Keyboard
{
	public static var event:KeyboardEvent;
	static var pressItems = new Array<KeyListener>();
	static var releaseItems = new Array<KeyListener>();
	
	public function new() {}
	
	static private function init() 
	{
		Lib.current.stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
		Lib.current.stage.addEventListener(KeyboardEvent.KEY_UP, onKeyUp);
	}
	
	static private function onKeyDown(e:KeyboardEvent):Void 
	{
		for (i in 0...pressItems.length) pressItems[i].onKeyDown(e);
	}
	
	static private function onKeyUp(e:KeyboardEvent):Void 
	{
		for (i in 0...releaseItems.length) releaseItems[i].onKeyUp(e);
	}
	
	static public function onPress(?key:Key, callback:Function, params:Array<Dynamic>=null):KeyListener
	{
		init();
		var keyboardListener = new KeyListener(key, callback, params);
		pressItems.push(keyboardListener);
		return keyboardListener;
	}
	
	static public function onRelease(?key:Key, callback:Function, params:Array<Dynamic>=null):KeyListener
	{
		init();
		var keyboardListener = new KeyListener(key, callback, params);
		releaseItems.push(keyboardListener);
		return keyboardListener;
	}
	
	static public function removePress(callback:Function):Void
	{
		remove(callback, pressItems);
	}
	
	static public function removeRelease(callback:Function):Void
	{
		remove(callback, releaseItems);
	}
	
	static inline function remove(callback:Function, items:Array<KeyListener>):Void
	{
		var i:Int = items.length - 1;
		while (i >= 0) 
		{
			if (items[i] != null) {
				if (items[i].callback == callback) {
					items[i].dispose();
					items.splice(i, 1);
				} else {
					i--;
				}
			}
			else {
				i--;
			}
		}
	}
}

class KeyListener
{
	@:isVar public var key(default, null):Key;
	@:isVar public var callback(default, null):Function;
	
	var params:Array<Dynamic>;
	var _shift:Null<Bool>;
	var _ctrl:Null<Bool>;
	var _alt:Null<Bool>;
	
	public function new(?key:Key, callback:Function, params:Array<Dynamic>) 
	{
		this.key = key;
		this.callback = callback;
		this.params = params;
	}
	
	public function dispose() 
	{
		Lib.current.stage.removeEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
		Lib.current.stage.removeEventListener(KeyboardEvent.KEY_UP, onKeyUp);
	}
	
	public function shift(value:Null<Bool>):KeyListener
	{
		_shift = value;
		return this;
	}
	
	public function ctrl(value:Null<Bool>):KeyListener
	{
		_ctrl = value;
		return this;
	}
	
	public function alt(value:Null<Bool>):KeyListener
	{
		_alt = value;
		return this;
	}
	
	public function onKeyDown(e:KeyboardEvent):Void 
	{
		if (pass(key, e.keyCode)) {
			if (pass(_shift, e.shiftKey) && ctrlPass(e) && pass(_alt, e.altKey)){
				Keyboard.event = e;
				callback.dispatch(params);
			}
		}
	}
	
	public function onKeyUp(e:KeyboardEvent):Void 
	{
		if (pass(key, e.keyCode)) {
			if (pass(_shift, e.shiftKey) && ctrlPass(e) && pass(_alt, e.altKey)){
				Keyboard.event = e;
				callback.dispatch(params);
			}
			
		}
	}

	inline function ctrlPass(e:KeyboardEvent)
	{
		if (_ctrl == false) return _ctrl == null || (pass(_ctrl, e.ctrlKey) && pass(_ctrl, e.commandKey) && pass(_ctrl, e.controlKey));
		return _ctrl == null || pass(_ctrl, e.ctrlKey) || pass(_ctrl, e.commandKey) || pass(_ctrl, e.controlKey);
	}
	
	inline function pass(value1:Dynamic, value2:Dynamic) 
	{
		if (value1 == value2 || value1 == null) return true;
		return false;
	}
}