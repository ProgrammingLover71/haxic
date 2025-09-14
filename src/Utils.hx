package src;

import haxe.io.Bytes;
import haxe.ds.StringMap;
import src.types.*;

class Utils {
    public static function print(value:String, writeNewLine:Bool = true):Void {
        Sys.stdout().write(Bytes.ofString(value + (writeNewLine ? "\n" : "")));
    }

    public static function stringify(value:Dynamic):String {
        switch (value) {
            case Value.VNull: return "null";
            case Value.VString(s): return s;
            case Value.VNumber(n): return Std.string(n);
            case Value.VBool(b): return Std.string(b);
            case Value.VArray(arr): return "[" + arr.map(Utils.stringify).join(", ") + "]";
            case Value.VMap(map):
                var items = [];
                for (key in map.keys()) {
                    items.push(key + " => " + Utils.stringify(map.get(key)));
                }
                return "{" + items.join(", ") + "}";
            case Value.VFunc(fn): return Std.string(fn);
            case Value.VNative(fn): return Std.string(fn);
        }
    }
}