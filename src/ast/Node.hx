package src.ast;

abstract class Node {
    public var line:Int;
    public var column:Int;

    public function new(line:Int, column:Int) {
        this.line = line;
        this.column = column;
    }

    public function toString():String {
        return "Node";
    }
}