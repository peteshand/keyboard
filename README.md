## Overview

This library offers an alternative way to define keyboard listeners. Currently the library only supports openfl based appplications. Rather than listening to a keyboard event and then filtering for switch key is pressed in the callback function, this is defined when the listener is added.

The following example adds a keyboard listener for when the "Enter" is pressed.

```
import keyboard.Key;
import keyboard.Keyboard;

...

Keyboard.onPress(Key.ENTER, () -> {
   trace('press');
} );
```

There is also an onRelease function.

```
Keyboard.onRelease(Key.ENTER, () -> {
   trace('release');
} );
```

If you want to add ctrl, alt, shirt modifiers these can be daisy chained after the onPress or onRelease functions. The following example will be triggered when the A key is pressed while both Shift and Ctrl are held down and Alt is not.

```
Keyboard.onPress(Key.A, () -> {
   trace('press');
} ).shift(true).ctrl(true).alt(false);
```

If a modifier is not set then the callback will be triggered regardless of it the modifier is being pressed or not. So in the below case the callback will be triggered when the A key is pressed while both Shift and Ctrl are held down and Alt is pressed or not pressed.


```
Keyboard.onPress(Key.A, () -> {
   trace('press');
} ).shift(true).ctrl(true);
```

Arguments can be passed as follows:

```
Keyboard.onPress(Key.A, example, [5, "test"] );

function example(value1:Int, value2:String)
{

}
```

Removing listners can be accomplished as follows:

```
Keyboard.removePress( example );
//or
Keyboard.removeRelease( example );

function example(value1:Int, value2:String)
{

}
```

If not Key is defined then the callback will be triggered regardless of which key is pressed.

```
Keyboard.onPress(() -> {
   trace('press');
} ).
```
