package src.ast;

class BlockStmt extends Stmt {
    public var statements:Array<Stmt>;

    public function new(statements:Array<Stmt>, line:Int, column:Int) {
        super(line, column);
        this.statements = statements;
    }

    override public function toString():String {
        return "Block(" + statements.join(", ") + ")";
    }
}