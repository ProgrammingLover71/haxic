package src;

import haxe.io.Bytes;

class Utils {
    public static function print(value:Dynamic, writeNewLine:Bool = true):Void {
        Sys.stdout().write(Bytes.ofString(Std.string(value) + (writeNewLine ? "\n" : "")));
    }
}