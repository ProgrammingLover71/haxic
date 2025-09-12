package src.ast;

class CallExpr extends Expr {
    public var callee:Expr;
    public var arguments:Array<Expr>;

    public function new(callee:Expr, arguments:Array<Expr>, line:Int, column:Int) {
        super(line, column);
        this.callee = callee;
        this.arguments = arguments;
    }

    override public function toString():String {
        return 'Call(callee=' + callee.toString() + ', args=[' + arguments.map(function(arg) return arg.toString()).join(', ') + '])';
    }
}