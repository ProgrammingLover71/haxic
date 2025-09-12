package src.ast;

class NullExpr extends Expr {
    public function new(line:Int, column:Int) {
        super(line, column);
    }

    override public function toString():String {
        return "null";
    }
}