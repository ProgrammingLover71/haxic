package src.ast;

class ForeachStmt extends Stmt {
    public var target:Expr;
    public var variable:VariableExpr;
    public var body:Stmt;

    public function new(variable:VariableExpr, target:Expr, body:Stmt, line:Int, column:Int) {
        super(line, column);
        this.variable = variable;
        this.target = target;
        this.body = body;
    }

    override public function toString():String {
        return 'Foreach(variable=' + variable.toString() + ', target=' + target.toString() + ', body=' + body.toString() + ')';
    }
}