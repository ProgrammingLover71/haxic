package src.ast;

class IndexExpr extends Expr {
    public var target:Expr;
    public var index:Expr;

    public function new(target:Expr, index:Expr, line:Int, column:Int) {
        super(line, column);
        this.target = target;
        this.index = index;
    }

    override public function toString():String {
        return 'Index(target=' + target.toString() + ', index=' + index.toString() + ')';
    }
}