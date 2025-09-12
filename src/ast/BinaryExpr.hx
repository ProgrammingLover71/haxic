package src.ast;

class BinaryExpr extends Expr {
    public var left:Expr;
    public var oper:Token;
    public var right:Expr;

    public function new(left:Expr, oper:Token, right:Expr, line:Int, column:Int) {
        super(line, column);
        this.left = left;
        this.oper = oper;
        this.right = right;
    }

    override public function toString():String {
        return "(" + left.toString() + " " + oper.value + " " + right.toString() + ")";
    }
}