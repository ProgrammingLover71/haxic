package src.ast;

abstract class Expr extends Node {
    public function new(line:Int, column:Int) {
        super(line, column);
    }

    override public function toString():String {
        return "Expr";
    }
}