package src.ast;

class FunctionStmt extends Stmt {
    public var name:String;
    public var params:Array<Parameter>;
    public var body:Stmt;

    public function new(name:String, params:Array<Parameter>, body:Stmt, line:Int, column:Int) {
        super(line, column);
        this.name = name;
        this.params = params;
        this.body = body;
    }

    override public function toString():String {
        return 'Function(name=' + name + ', args=[' + params.join(', ') + '], body=' + body.toString() + ')';
    }
}