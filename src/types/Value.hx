package src.types;

import haxe.ds.StringMap;

enum Value {
    VNumber(value:Float);
    VBool(value:Bool);
    VNull;
    VString(value:String);
    VArray(items:Array<Value>);
    VMap(map:haxe.ds.StringMap<Value>);
    // User function closure (captures env, params, body)
    VFunc(fn:Function);
    // Native function wrapper (arity, impl)
    VNative(native:NativeFunction);
}