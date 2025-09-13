package src;

import haxe.io.Bytes;
import haxe.ds.StringMap;

class Utils {
    public static function print(value:Dynamic, writeNewLine:Bool = true):Void {
        Sys.stdout().write(Bytes.ofString(Std.string(value) + (writeNewLine ? "\n" : "")));
    }

    public static function stringify(value:Dynamic):String {
        if (value == null) {
            return "null";
        } else if (Std.isOfType(value, String)) {
            return (value:String);
        } else if (Std.isOfType(value, Array)) {
            var arr = (value : Array<Dynamic>);
            return "[" + arr.map(stringify).join(", ") + "]";
        } else if (Std.isOfType(value, StringMap)) {
            var map = (value : StringMap<Dynamic>);
            var items = [];
            for (key in map.keys()) {
                items.push(key + " => " + Utils.stringify(map.get(key)));
            }
            return "{" + items.join(", ") + "}";
        } else {
            return Std.string(value);
        }
    }
}