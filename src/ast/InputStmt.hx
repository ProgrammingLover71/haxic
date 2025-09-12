package src.ast;

import src.ast.VariableExpr;

class InputStmt extends Stmt {
    public var target:VariableExpr;

    public function new(target:VariableExpr, line:Int, column:Int) {
        super(line, column);
        this.target = target;
    }

    override public function toString():String {
        return "Input(" + target.toString() + ")";
    }
}