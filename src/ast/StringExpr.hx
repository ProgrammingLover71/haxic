package src.ast;

class StringExpr extends Expr {
    public var value:String;

    public function new(value:String, line:Int, column:Int) {
        super(line, column);
        this.value = value;
    }

    override public function toString():String {
        return '"' + value + '"';
    }
}