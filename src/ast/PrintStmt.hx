package src.ast;

import src.ast.Expr;
import src.ast.Stmt;

class PrintStmt extends Stmt {
    public var expr:Expr;

    public function new(expr:Expr, line:Int, column:Int) {
        super(line, column);
        this.expr = expr;
    }

    override public function toString():String {
        return "Print(" + expr.toString() + ")";
    }
}