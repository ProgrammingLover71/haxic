package src;

class Token {
    public var type:TokenType;
    public var value:Any;

    public var line:Int;
    public var column:Int;

    public function new(type:TokenType, value:Any, line:Int, column:Int) {
        this.type = type;
        this.value = value;
        this.line = line;
        this.column = column;
    }

    public function toString():String {
        return "Token(type:" + Std.string(type) + ", value:'" + Std.string(value) + "'(" + Type.getClassName(Type.getClass(value)) + "), line:" + line + ", column:" + column + ")";
    }
}