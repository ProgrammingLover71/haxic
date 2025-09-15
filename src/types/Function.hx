package src.types;

import src.ast.Stmt;
import src.ast.Parameter;
import src.Interpreter;

class Function {
    public var name:String;
    public var params:Array<Parameter>;
    public var body:Stmt;

    public function new(name:String, params:Array<Parameter>, body:Stmt) {
        this.name = name;
        this.params = params;
        this.body = body;
    }

    public function toString():String {
        return "<Function " + name + ":" + params.length + ">";
    }

    public function call(args:Array<Value>, interp:Interpreter):Void {
        // Create a new environment for the function call
        var previousEnv = interp.environment;
        interp.environment = new Environment(previousEnv);
        for (i in 0...params.length) {
            var param = params[i];
            var value:Dynamic = null;

            if (i < args.length) {
                value = args[i]; // provided by caller
            } else if (param.defaultValue != null) {
                value = interp.visitExpr(param.defaultValue); // evaluate default at call time
            } else {
                throw "Missing argument for parameter '" + param.name + "'";
            }
            
            interp.environment.define(param.name, value);
        }
        // Execute the function body
        interp.visitStmt(body);
        // Restore the previous environment
        interp.environment = previousEnv;
    }
}