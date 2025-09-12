package src.ast;

class ExprStmt extends Stmt {
    public var expr:Expr;

    public function new(expr:Expr, line:Int, column:Int) {
        super(line, column);
        this.expr = expr;
    }

    public override function toString():String {
        return "Expr(" + expr.toString() + ")";
    }
}