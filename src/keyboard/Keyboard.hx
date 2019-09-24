package keyboard;

import time.EnterFrame;
import keyboard.Key;
import openfl.Lib;
import openfl.events.Event;
import openfl.events.EventType;
import openfl.events.KeyboardEvent;
import haxe.Constraints.Function;

using utils.FunctionUtil;

/**
 * ...
 * @author P.J.Shand
 */
class Keyboard {
	public static var event:KeyboardEvent;
	static var pressItems = new Array<KeyListener>();
	static var releaseItems = new Array<KeyListener>();

	static var withDescription = new Map<KeyListener, Bool>();
	public static var descriptionOutput(get, null):String;
	public static var descriptionTable(get, null):Dynamic;

	public function new() {}

	static private function init() {
		Lib.current.stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
		Lib.current.stage.addEventListener(KeyboardEvent.KEY_UP, onKeyUp);
	}

	static private function onKeyDown(e:KeyboardEvent):Void {
		for (i in 0...pressItems.length)
			pressItems[i].onKeyDown(e);
	}

	static private function onKeyUp(e:KeyboardEvent):Void {
		for (i in 0...releaseItems.length)
			releaseItems[i].onKeyUp(e);
	}

	static public function onPress(?key:Key, callback:Function, params:Array<Dynamic> = null):KeyListener {
		init();
		var keyboardListener = new KeyListener(key, callback, params);
		pressItems.push(keyboardListener);
		return keyboardListener;
	}

	static public function onRelease(?key:Key, callback:Function, params:Array<Dynamic> = null):KeyListener {
		init();
		var keyboardListener = new KeyListener(key, callback, params);
		releaseItems.push(keyboardListener);
		return keyboardListener;
	}

	static public function onDown(?key:Key, callback:Function, params:Array<Dynamic> = null):KeyListener {
		init();
		var keyDownListener = new KeyDownListener(key, callback, params);
		pressItems.push(keyDownListener.keyboardListener);
		releaseItems.push(keyDownListener.keyboardListener);
		return keyDownListener.keyboardListener;
	}

	static public function removePress(callback:Function):Void {
		remove(callback, pressItems);
	}

	static public function removeRelease(callback:Function):Void {
		remove(callback, releaseItems);
	}

	static inline function remove(callback:Function, items:Array<KeyListener>):Void {
		var i:Int = items.length - 1;
		while (i >= 0) {
			if (items[i] != null) {
				if (items[i].callback == callback) {
					items[i].dispose();
					items.splice(i, 1);
				} else {
					i--;
				}
			} else {
				i--;
			}
		}
	}

	static function get_descriptionOutput():String {
		var outputArray:Array<String> = [];
		for (keylistener in Keyboard.withDescription.keys()) {
			var key:Int = keylistener.key;
			var letter:String = KeyMap.keyboardMap[key];
			outputArray.push("| " + keylistener._description + " | " + letter + " | " + keylistener._ctrl + " | " + keylistener._shift + " | "
				+ keylistener._alt + " |\n");
		}
		outputArray.sort((o1, o2) -> {
			if (o1 > o2)
				return 1;
			else if (o1 < o2)
				return -1;
			else
				return 0;
		});
		return outputArray.join("");
	}

	static function get_descriptionTable():Dynamic {
		var outputObj:Dynamic = {};
		for (keylistener in Keyboard.withDescription.keys()) {
			var key:Int = keylistener.key;
			var letter:String = KeyMap.keyboardMap[key];
			var keyModifier:String = "";
			if (keylistener._ctrl)
				keyModifier += " + ctrl";
			if (keylistener._shift)
				keyModifier += " + shift";
			if (keylistener._alt)
				keyModifier += " + alt";

			var item = {
				description: keylistener._description,
			}
			untyped outputObj[letter.toLowerCase() + keyModifier] = item;
		}
		return outputObj;
	}
}

class KeyDownListener {
	public var keyboardListener:KeyListener;

	var callback:Function;
	var params:Array<Dynamic>;
	var isDown(default, set):Bool;

	public function new(?key:Key, callback:Function, params:Array<Dynamic> = null) {
		this.callback = callback;
		this.params = params;
		keyboardListener = new KeyListener(key, () -> {
			if (Keyboard.event == null)
				return;
			if (Keyboard.event.type == 'keyDown') {
				isDown = true;
			} else if (Keyboard.event.type == 'keyUp') {
				isDown = false;
			}
		}, []);
	}

	function set_isDown(value:Bool):Bool {
		if (isDown == value)
			return value;
		else {
			isDown = value;
		}
		if (isDown) {
			EnterFrame.add(tick);
		} else {
			EnterFrame.remove(tick);
		}
		return isDown;
	}

	function tick() {
		callback.dispatch(params);
	}
}

@:access(keyboard.Keyboard)
class KeyListener {
	@:isVar public var key(default, null):Key;
	@:isVar public var _shift(default, null):Null<Bool>;
	@:isVar public var _ctrl(default, null):Null<Bool>;
	@:isVar public var _alt(default, null):Null<Bool>;
	@:isVar public var _description(default, null):String;
	@:isVar public var callback(default, null):Function;

	var params:Array<Dynamic>;

	public function new(?key:Key, callback:Function, params:Array<Dynamic>) {
		this.key = key;
		this.callback = callback;
		this.params = params;
	}

	public function dispose() {
		Lib.current.stage.removeEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
		Lib.current.stage.removeEventListener(KeyboardEvent.KEY_UP, onKeyUp);
	}

	public function shift(value:Null<Bool>):KeyListener {
		_shift = value;
		return this;
	}

	public function ctrl(value:Null<Bool>):KeyListener {
		_ctrl = value;
		return this;
	}

	public function alt(value:Null<Bool>):KeyListener {
		_alt = value;
		return this;
	}

	public function description(value:String):KeyListener {
		_description = value;
		Keyboard.withDescription.set(this, true);
		return this;
	}

	public function onKeyDown(e:KeyboardEvent):Void {
		if (pass(key, e.keyCode)) {
			if (pass(_shift, e.shiftKey) && ctrlPass(e) && pass(_alt, e.altKey)) {
				Keyboard.event = e;
				callback.dispatch(params);
			}
		}
	}

	public function onKeyUp(e:KeyboardEvent):Void {
		if (pass(key, e.keyCode)) {
			if (pass(_shift, e.shiftKey) && ctrlPass(e) && pass(_alt, e.altKey)) {
				Keyboard.event = e;
				callback.dispatch(params);
			}
		}
	}

	inline function ctrlPass(e:KeyboardEvent) {
		if (_ctrl == false)
			return _ctrl == null || (pass(_ctrl, e.ctrlKey) && pass(_ctrl, e.commandKey) && pass(_ctrl, e.controlKey));
		return _ctrl == null || pass(_ctrl, e.ctrlKey) || pass(_ctrl, e.commandKey) || pass(_ctrl, e.controlKey);
	}

	inline function pass(value1:Dynamic, value2:Dynamic) {
		if (value1 == value2 || value1 == null)
			return true;
		return false;
	}
}

// only used for descriptionOutput
class KeyMap {
	public static var keyboardMap:Array<String> = [
		"", // [0]
		"", // [1]
		"", // [2]
		"CANCEL", // [3]
		"", // [4]
		"", // [5]
		"HELP", // [6]
		"", // [7]
		"BACK_SPACE", // [8]
		"TAB", // [9]
		"", // [10]
		"", // [11]
		"CLEAR", // [12]
		"ENTER", // [13]
		"ENTER_SPECIAL", // [14]
		"", // [15]
		"SHIFT", // [16]
		"CONTROL", // [17]
		"ALT", // [18]
		"PAUSE", // [19]
		"CAPS_LOCK", // [20]
		"KANA", // [21]
		"EISU", // [22]
		"JUNJA", // [23]
		"FINAL", // [24]
		"HANJA", // [25]
		"", // [26]
		"ESCAPE", // [27]
		"CONVERT", // [28]
		"NONCONVERT", // [29]
		"ACCEPT", // [30]
		"MODECHANGE", // [31]
		"SPACE", // [32]
		"PAGE_UP", // [33]
		"PAGE_DOWN", // [34]
		"END", // [35]
		"HOME", // [36]
		"LEFT", // [37]
		"UP", // [38]
		"RIGHT", // [39]
		"DOWN", // [40]
		"SELECT", // [41]
		"PRINT", // [42]
		"EXECUTE", // [43]
		"PRINTSCREEN", // [44]
		"INSERT", // [45]
		"DELETE", // [46]
		"", // [47]
		"0", // [48]
		"1", // [49]
		"2", // [50]
		"3", // [51]
		"4", // [52]
		"5", // [53]
		"6", // [54]
		"7", // [55]
		"8", // [56]
		"9", // [57]
		"COLON", // [58]
		"SEMICOLON", // [59]
		"LESS_THAN", // [60]
		"EQUALS", // [61]
		"GREATER_THAN", // [62]
		"QUESTION_MARK", // [63]
		"AT", // [64]
		"A", // [65]
		"B", // [66]
		"C", // [67]
		"D", // [68]
		"E", // [69]
		"F", // [70]
		"G", // [71]
		"H", // [72]
		"I", // [73]
		"J", // [74]
		"K", // [75]
		"L", // [76]
		"M", // [77]
		"N", // [78]
		"O", // [79]
		"P", // [80]
		"Q", // [81]
		"R", // [82]
		"S", // [83]
		"T", // [84]
		"U", // [85]
		"V", // [86]
		"W", // [87]
		"X", // [88]
		"Y", // [89]
		"Z", // [90]
		"OS_KEY", // [91] Windows Key (Windows) or Command Key (Mac)
		"", // [92]
		"CONTEXT_MENU", // [93]
		"", // [94]
		"SLEEP", // [95]
		"NUMPAD0", // [96]
		"NUMPAD1", // [97]
		"NUMPAD2", // [98]
		"NUMPAD3", // [99]
		"NUMPAD4", // [100]
		"NUMPAD5", // [101]
		"NUMPAD6", // [102]
		"NUMPAD7", // [103]
		"NUMPAD8", // [104]
		"NUMPAD9", // [105]
		"MULTIPLY", // [106]
		"ADD", // [107]
		"SEPARATOR", // [108]
		"SUBTRACT", // [109]
		"DECIMAL", // [110]
		"DIVIDE", // [111]
		"F1", // [112]
		"F2", // [113]
		"F3", // [114]
		"F4", // [115]
		"F5", // [116]
		"F6", // [117]
		"F7", // [118]
		"F8", // [119]
		"F9", // [120]
		"F10", // [121]
		"F11", // [122]
		"F12", // [123]
		"F13", // [124]
		"F14", // [125]
		"F15", // [126]
		"F16", // [127]
		"F17", // [128]
		"F18", // [129]
		"F19", // [130]
		"F20", // [131]
		"F21", // [132]
		"F22", // [133]
		"F23", // [134]
		"F24", // [135]
		"", // [136]
		"", // [137]
		"", // [138]
		"", // [139]
		"", // [140]
		"", // [141]
		"", // [142]
		"", // [143]
		"NUM_LOCK", // [144]
		"SCROLL_LOCK", // [145]
		"WIN_OEM_FJ_JISHO", // [146]
		"WIN_OEM_FJ_MASSHOU", // [147]
		"WIN_OEM_FJ_TOUROKU", // [148]
		"WIN_OEM_FJ_LOYA", // [149]
		"WIN_OEM_FJ_ROYA", // [150]
		"", // [151]
		"", // [152]
		"", // [153]
		"", // [154]
		"", // [155]
		"", // [156]
		"", // [157]
		"", // [158]
		"", // [159]
		"CIRCUMFLEX", // [160]
		"EXCLAMATION", // [161]
		"DOUBLE_QUOTE", // [162]
		"HASH", // [163]
		"DOLLAR", // [164]
		"PERCENT", // [165]
		"AMPERSAND", // [166]
		"UNDERSCORE", // [167]
		"OPEN_PAREN", // [168]
		"CLOSE_PAREN", // [169]
		"ASTERISK", // [170]
		"PLUS", // [171]
		"PIPE", // [172]
		"HYPHEN_MINUS", // [173]
		"OPEN_CURLY_BRACKET", // [174]
		"CLOSE_CURLY_BRACKET", // [175]
		"TILDE", // [176]
		"", // [177]
		"", // [178]
		"", // [179]
		"", // [180]
		"VOLUME_MUTE", // [181]
		"VOLUME_DOWN", // [182]
		"VOLUME_UP", // [183]
		"", // [184]
		"", // [185]
		"SEMICOLON", // [186]
		"EQUALS", // [187]
		"COMMA", // [188]
		"MINUS", // [189]
		"PERIOD", // [190]
		"SLASH", // [191]
		"BACK_QUOTE", // [192]
		"", // [193]
		"", // [194]
		"", // [195]
		"", // [196]
		"", // [197]
		"", // [198]
		"", // [199]
		"", // [200]
		"", // [201]
		"", // [202]
		"", // [203]
		"", // [204]
		"", // [205]
		"", // [206]
		"", // [207]
		"", // [208]
		"", // [209]
		"", // [210]
		"", // [211]
		"", // [212]
		"", // [213]
		"", // [214]
		"", // [215]
		"", // [216]
		"", // [217]
		"", // [218]
		"OPEN_BRACKET", // [219]
		"BACK_SLASH", // [220]
		"CLOSE_BRACKET", // [221]
		"QUOTE", // [222]
		"", // [223]
		"META", // [224]
		"ALTGR", // [225]
		"", // [226]
		"WIN_ICO_HELP", // [227]
		"WIN_ICO_00", // [228]
		"", // [229]
		"WIN_ICO_CLEAR", // [230]
		"", // [231]
		"", // [232]
		"WIN_OEM_RESET", // [233]
		"WIN_OEM_JUMP", // [234]
		"WIN_OEM_PA1", // [235]
		"WIN_OEM_PA2", // [236]
		"WIN_OEM_PA3", // [237]
		"WIN_OEM_WSCTRL", // [238]
		"WIN_OEM_CUSEL", // [239]
		"WIN_OEM_ATTN", // [240]
		"WIN_OEM_FINISH", // [241]
		"WIN_OEM_COPY", // [242]
		"WIN_OEM_AUTO", // [243]
		"WIN_OEM_ENLW", // [244]
		"WIN_OEM_BACKTAB", // [245]
		"ATTN", // [246]
		"CRSEL", // [247]
		"EXSEL", // [248]
		"EREOF", // [249]
		"PLAY", // [250]
		"ZOOM", // [251]
		"", // [252]
		"PA1", // [253]
		"WIN_OEM_CLEAR", // [254]
		"" // [255]
	];
}
