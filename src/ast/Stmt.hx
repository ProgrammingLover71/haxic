package src.ast;

abstract class Stmt extends Node {
    public function new(line:Int, column:Int) {
        super(line, column);
    }

    override public function toString():String {
        return "Stmt";
    }
}