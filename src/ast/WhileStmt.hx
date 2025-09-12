package src.ast;

class WhileStmt extends Stmt {
    public var condition:Expr;
    public var body:BlockStmt;

    public function new(condition:Expr, body:BlockStmt, line:Int, column:Int) {
        super(line, column);
        this.condition = condition;
        this.body = body;
    }

    override public function toString():String {
        return "While(condition=" + condition.toString() + ", body=" + body.toString() + ")";
    }
}