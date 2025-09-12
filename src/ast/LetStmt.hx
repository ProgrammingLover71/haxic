package src.ast;

class LetStmt extends Stmt {
    public var bindings:Array<VariableExpr>;
    public var value:Expr;

    public function new(bindings:Array<VariableExpr>, value:Expr, line:Int, column:Int) {
        super(line, column);
        this.bindings = bindings;
        this.value = value;
    }

    override public function toString():String {
        return 'LetStmt(' + bindings + ', ' + value + ')';
    }
}