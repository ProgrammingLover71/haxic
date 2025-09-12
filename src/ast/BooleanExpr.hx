package src.ast;

class BooleanExpr extends Expr {
    public var value:Bool;

    public function new(value:Bool, line:Int, column:Int) {
        super(line, column);
        this.value = value;
    }

    override public function toString():String {
        return "Boolean(" + value + ")";
    }
}