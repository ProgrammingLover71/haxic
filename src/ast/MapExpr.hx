package src.ast;

class MapExpr extends Expr {
    public var pairs:Array<{key:String, value:Expr, line:Int, column:Int}>;

    public function new(pairs:Array<{key:String, value:Expr, line:Int, column:Int}>, line:Int, column:Int) {
        super(line, column);
        this.pairs = pairs;
    }

    public override function toString():String {
        var pairsStr = pairs.map(function(pair) {
            return Std.string(pair.key) + " => " + Std.string(pair.value);
        }).join(", ");
        return "{" + pairsStr + "}";
    }
}