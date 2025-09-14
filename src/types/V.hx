package src.types;

import haxe.ds.StringMap;

class V {
    public static function toNumber(v:Value):Float {
        switch (v) {
            case VNumber(x): return x;
            case VBool(b): return b ? 1.0 : 0.0;
            case VString(s): return Std.parseFloat(s); // maybe throw on NaN
            case VNull: return 0.0;
            default: throw "Cannot convert to number: " + v;
        }
    }

    public static function isTruthy(v:Value):Bool {
        switch (v) {
            case VNull: return false;
            case VBool(b): return b;
            case VNumber(n): return n != 0;
            case VString(s): return s.length > 0;
            case VArray(a): return a.length > 0;
            case VMap(m): return m.keys().hasNext();
            default: return true;
        }
    }

    public static function toString(v:Value):String {
        switch (v) {
            case VNumber(n): return Std.string(n);
            case VBool(b): return b ? "true" : "false";
            case VString(s): return s;
            case VNull: return "null";
            case VArray(a):
                var parts = [];
                for (x in a) parts.push(toString(x));
                return "[" + parts.join(", ") + "]";
            case VMap(m):
                var parts = [];
                for (k in m.keys()) parts.push(k + ":" + toString(m.get(k)));
                return "{" + parts.join(", ") + "}";
            case VFunc(f): return "<fn " + f.name + ">";
            case VNative(n): return "<native " + n.name + ">";
        }
    }

    public static function toArray(v:Value):Array<Value> {
        switch (v) {
            case VArray(a): return a;
            default: throw "Cannot convert to array: " + v;
        }
    }

    public static function toMap(v:Value):StringMap<Value> {
        switch (v) {
            case VMap(m): return m;
            default: throw "Cannot convert to map: " + v;
        }
    }

    public static function toFunc(v:Value):Function {
        switch (v) {
            case VFunc(f): return f;
            default: throw "Cannot convert to map: " + v;
        }
    }

    public static function toNativeFunc(v:Value):NativeFunction {
        switch (v) {
            case VNative(f): return f;
            default: throw "Cannot convert to map: " + v;
        }
    }
}
