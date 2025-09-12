package src.ast;

class VariableExpr extends Expr {
    public var name:String;

    public function new(name:String, line:Int, column:Int) {
        super(line, column);
        this.name = name;
    }

    override public function toString():String {
        return "Var(" + name + ")";
    }
}