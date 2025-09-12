package src.ast;

class NumberExpr extends Expr {
    public var value:Float;

    public function new(value:Float, line:Int, column:Int) {
        super(line, column);
        this.value = value;
    }

    override public function toString():String {
        return "Num(" + value + ")";
    }
}