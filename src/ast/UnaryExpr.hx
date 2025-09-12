package src.ast;

class UnaryExpr extends Expr {
    public var oper:Token;
    public var right:Expr;

    public function new(oper:Token, right:Expr, line:Int, column:Int) {
        super(line, column);
        this.oper = oper;
        this.right = right;
    }

    override public function toString():String {
        return "Unary(" + oper.value + ", " + right.toString() + ")";
    }
}