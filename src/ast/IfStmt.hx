package src.ast;

class IfStmt extends Stmt {
    public var condition:Expr;
    public var thenBranch:BlockStmt;
    public var elseBranch:BlockStmt;

    public function new(condition:Expr, thenBranch:BlockStmt, ?elseBranch:BlockStmt, line:Int, column:Int) {
        super(line, column);
        this.condition = condition;
        this.thenBranch = thenBranch;
        this.elseBranch = elseBranch;
    }

    override public function toString():String {
        return "If(cond=" + condition.toString() + ", then=" + thenBranch.toString() + (elseBranch != null ? ", else=" + elseBranch.toString() : "") + ")";
    }
}