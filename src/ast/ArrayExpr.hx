package src.ast;

class ArrayExpr extends Expr {
    public var elements:Array<Expr>;

    public function new(elements:Array<Expr>, line:Int, column:Int) {
        super(line, column);
        this.elements = elements;
    }

    override public function toString():String {
        return 'Array(' + elements.map(e -> e.toString()).join(', ') + ')';
    }
}