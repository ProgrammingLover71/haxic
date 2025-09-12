package src.ast;

class ReturnStmt extends Stmt {
    public var value:Expr;

    public function new(value:Expr, line:Int, column:Int) {
        super(line, column);
        this.value = value;
    }

    override public function toString():String {
        return 'Return(' + value.toString() + ')';
    }
}