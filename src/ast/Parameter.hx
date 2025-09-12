package src.ast;

class Parameter {
    public var name:String;
    public var defaultValue:Expr; // null if none
    public var line:Int;
    public var column:Int;

    public function new(name:String, defaultValue:Expr, line:Int, column:Int) {
        this.name = name;
        this.defaultValue = defaultValue;
        this.line = line;
        this.column = column;
    }

    public function toString():String {
        return "Parameter(" + name + (if (defaultValue != null) ", default=" + Std.string(defaultValue) else "") + ")";
    }
}
