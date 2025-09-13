package src;

import src.ast.*;



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

    public function call(args:Array<Dynamic>, interp:Interpreter):Void {
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



class NativeFunction {
    public var name:String;
    public var params:Array<Parameter>;
    public var body:((Environment) -> Dynamic);

    public function new(name:String, params:Array<Parameter>, body:((Environment) -> Dynamic)) {
        this.name = name;
        this.params = params;
        this.body = body;
    }

    public function toString():String {
        return "<Native function " + name + ":" + params.length + ">";
    }

    public function call(args:Array<Dynamic>, interp:Interpreter):Dynamic {
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
        // Throw a Return exception to unwind the stack and return the value
        var value:Dynamic = body(interp.environment);
        interp.environment = previousEnv;
        return value;
    }
}



class Environment {
    public var values:Map<String, Dynamic>;
    public var enclosing:Environment;

    public function new(enclosing:Environment = null) {
        values = new Map();
        this.enclosing = enclosing;
    }

    public function define(name:String, value:Dynamic) {
        values.set(name, value);
    }

    public function get(name:String):Dynamic {
        if (values.exists(name)) {
            return values.get(name);
        }
        if (enclosing != null) {
            return enclosing.get(name);
        }
        throw "Undefined variable '" + name + "'";
    }

    public function assign(name:String, value:Dynamic) {
        if (values.exists(name)) {
            values.set(name, value);
            return;
        }
        if (enclosing != null) {
            enclosing.assign(name, value);
            return;
        }
        throw "Undefined variable '" + name + "'";
    }

    public function exists(name:String):Bool {
        if (values.exists(name)) {
            return true;
        }
        if (enclosing != null) {
            return enclosing.exists(name);
        }
        return false;
    }
}



class Return extends haxe.Exception {
    public var value:Dynamic;

    public function new(value:Dynamic) {
        super("Return");
        this.value = value;
    }
}



class Interpreter extends ASTWalker {
    public var environment:Environment;

    public function new() {
        environment = new Environment();
        environment.define("pi", Math.PI);
        environment.define("e", Math.exp(1));
        environment.define("inf", Math.POSITIVE_INFINITY);
        environment.define("nan", Math.NaN);

        environment.define("clock", new NativeFunction("clock", [], function(env) {
            return Sys.time();
        }));
        environment.define("length", new NativeFunction("length", [new Parameter("item", null, 0, 0)], function(env) {
            var item:Dynamic = env.get("item");
            if (Std.isOfType(item, String)) {
                return (item : String).length;
            } else if (Std.isOfType(item, Array)) {
                return (item : Array<Dynamic>).length;
            } else {
                throw "length() argument must be a string or array";
            }
        }));
        environment.define("typeof", new NativeFunction("typeof", [new Parameter("item", null, 0, 0)], function(env) {
            var item:Dynamic = env.get("item");
            if (item == null) return "null";
            if (Std.isOfType(item, Bool)) return "bool";
            if (Std.isOfType(item, Int) || Std.isOfType(item, Float)) return "number";
            if (Std.isOfType(item, String)) return "string";
            if (Std.isOfType(item, Array)) return "array";
            if (Std.isOfType(item, Function) || Std.isOfType(item, NativeFunction)) return "function";
            return "object";
        }));
        environment.define("range", new NativeFunction("range", [
            new Parameter("start", null, 0, 0), 
            new Parameter("end", null, 0, 0), 
            new Parameter("step", new NumberExpr(1, 0, 0), 0, 0)
        ], function(env) {
            var start:Dynamic = env.get("start");
            var end:Dynamic = env.get("end");
            var step:Dynamic = env.get("step");
            if (!Std.isOfType(start, Int) || !Std.isOfType(end, Int) || !Std.isOfType(step, Int)) {
                throw "range() arguments must be integers";
            }
            var result:Array<Int> = [];
            var i = (start : Int);
            if (step == 0) throw "range() step argument must not be zero";
            if (step > 0) {
                while (i < (end : Int)) {
                    result.push(i);
                    i += (step : Int);
                }
            } else {
                while (i > (end : Int)) {
                    result.push(i);
                    i += (step : Int);
                }
            }
            return result;
        }));
        environment.define("clear", new NativeFunction("clear", [], function(env) {
            if (Sys.systemName().toLowerCase().indexOf("windows") != -1) {
                Sys.command("cls");
            } else {
                Sys.command("clear");
            }
            return null;
        }));
    }

    public function visit(ast:Array<Stmt>) {
        for (stmt in ast) {
            if (stmt != null) visitStmt(stmt);
        }
    }


    public function visitPrintStmt(stmt:PrintStmt) {
        var value:Dynamic = visitExpr(stmt.expr);
        // Use Sys.stdout().write() instead of trace() for a cleaner output and to avoid showing the file and line number
        Utils.print(value);
    }


    public function visitInputStmt(stmt:InputStmt) {
        var input:String = Sys.stdin().readLine();
        var num:Float = Std.parseFloat(input);
        var final_val:Dynamic = if (num == Math.NaN) input else num;
        environment.define(stmt.target.name, final_val);
    }


    public function visitLetStmt(stmt:LetStmt) {
        var value:Dynamic = null;
        if (stmt.value != null) {
            value = visitExpr(stmt.value);
        }
        for (v in stmt.bindings) {
            environment.define(v.name, value);
        }
    }


    public function visitIfStmt(stmt:IfStmt) {
        var condition:Dynamic = visitExpr(stmt.condition);
        if (condition) {
            visitBlockStmt(stmt.thenBranch);
        } else if (stmt.elseBranch != null) {
            visitBlockStmt(stmt.elseBranch);
        }
    }


    public function visitWhileStmt(stmt:WhileStmt) {
        var condition:Dynamic = visitExpr(stmt.condition);
        while (condition) {
            visitBlockStmt(stmt.body);
            condition = visitExpr(stmt.condition);
        }
    }

    public function visitForeachStmt(stmt:ForeachStmt) {
        var iterable:Dynamic = visitExpr(stmt.target);
        var varName = stmt.variable.name;
        if (Std.isOfType(iterable, Array)) {
            for (item in (iterable : Array<Dynamic>)) {
                environment.define(varName, item);
                visitStmt(stmt.body);
            }
        } else if (Std.isOfType(iterable, String)) {
            for (i in 0...((iterable : String).length)) {
                environment.define(varName, (iterable : String).charAt(i));
                visitStmt(stmt.body);
            }
        } else {
            throw "Foreach target" + iterable + " must be an array or string at line " + stmt.line + ", column " + stmt.column;
        }
    }


    public function visitBlockStmt(stmt:BlockStmt) {
        for (s in stmt.statements) {
            visitStmt(s);
        }
    }


    public function visitExprStmt(stmt:ExprStmt) {
        visitExpr(stmt.expr);
    }


    public function visitReturnStmt(stmt:ReturnStmt) {
        var value:Dynamic = null;
        if (stmt.value != null) {
            value = visitExpr(stmt.value);
        }
        throw new Return(value);
    }


    public function visitFunctionStmt(stmt:FunctionStmt) {
        var functionObj = new Function(stmt.name, stmt.params, stmt.body);
        environment.define(stmt.name, functionObj);
    }


    public function visitStmt(stmt:Stmt) {
        if (Std.isOfType(stmt, PrintStmt)) {
            visitPrintStmt(cast stmt);
        } else if (Std.isOfType(stmt, InputStmt)) {
            visitInputStmt(cast stmt);
        } else if (Std.isOfType(stmt, LetStmt)) {
            visitLetStmt(cast stmt);
        } else if (Std.isOfType(stmt, IfStmt)) {
            visitIfStmt(cast stmt);
        } else if (Std.isOfType(stmt, BlockStmt)) {
            visitBlockStmt(cast stmt);
        } else if (Std.isOfType(stmt, ExprStmt)) {
            visitExprStmt(cast stmt);
        } else if (Std.isOfType(stmt, WhileStmt)) {
            visitWhileStmt(cast stmt);
        } else if (Std.isOfType(stmt, ForeachStmt)) {
            visitForeachStmt(cast stmt);
        } else if (Std.isOfType(stmt, ReturnStmt)) {
            visitReturnStmt(cast stmt);
        } else if (Std.isOfType(stmt, FunctionStmt)) {
            visitFunctionStmt(cast stmt);
        } else {
            throw "Unknown statement type: " + stmt;
        }
    }

    //=================================================================//

    public function visitExpr(expr:Expr):Dynamic {
        if (Std.isOfType(expr, BinaryExpr)) {
            return visitBinaryExpr(cast expr);
        } else if (Std.isOfType(expr, NumberExpr)) {
            return visitNumberExpr(cast expr);
        } else if (Std.isOfType(expr, VariableExpr)) {
            return visitVariableExpr(cast expr);
        } else if (Std.isOfType(expr, UnaryExpr)) {
            return visitUnaryExpr(cast expr);
        } else if (Std.isOfType(expr, StringExpr)) {
            return visitStringExpr(cast expr);
        } else if (Std.isOfType(expr, CallExpr)) {
            return visitCallExpr(cast expr);
        } else if (Std.isOfType(expr, BooleanExpr)) {
            return visitBooleanExpr(cast expr);
        } else if (Std.isOfType(expr, NullExpr)) {
            return visitNullExpr(cast expr);
        } else if (Std.isOfType(expr, ArrayExpr)) {
            return visitArrayExpr(cast expr);
        } else if (Std.isOfType(expr, IndexExpr)) {
            return visitIndexExpr(cast expr);
        } else {
            throw "Unknown expression type: " + expr;
        }
    }


    public function visitUnaryExpr(expr:UnaryExpr):Dynamic {
        var right:Dynamic = visitExpr(expr.right);
        switch (expr.oper.type) {
            case TokenType.MINUS:
                return -right;
            case TokenType.BANG:
                return !right;
            default:
                throw "Unknown unary operator " + expr.oper.value + " at line " + expr.oper.line + ", column " + expr.oper.column;
        }
    }


    public function visitBinaryExpr(expr:BinaryExpr):Dynamic {
        var left:Dynamic = visitExpr(expr.left);
        var right:Dynamic = visitExpr(expr.right);
        switch (expr.oper.type) {
            case TokenType.PLUS:
                // Handle string concatenation and array merging and keep numeric addition
                if (Std.isOfType(left, Array) && Std.isOfType(right, Array)) {
                    return (left : Array<Dynamic>).concat((right : Array<Dynamic>));
                } else if (Std.isOfType(left, String) || Std.isOfType(right, String)) {
                    return Std.string(left) + Std.string(right);
                } else {
                    return left + right;
                }
            case TokenType.MINUS:
                return left - right;
            case TokenType.STAR:
                return left * right;
            case TokenType.SLASH:
                return left / right;
            case TokenType.GT:
                return left > right;
            case TokenType.GTEQ:
                return left >= right;
            case TokenType.LT:
                return left < right;
            case TokenType.LTEQ:
                return left <= right;
            case TokenType.EQEQ:
                return left == right;
            case TokenType.NOTEQ:
                return left != right;
            case TokenType.BANG:
                return !left;
            default:
                throw "Unknown operator " + expr.oper.value + " at line " + expr.oper.line + ", column " + expr.oper.column;
        }
    }


    public function visitNumberExpr(expr:NumberExpr):Float {
        return expr.value;
    }


    public function visitVariableExpr(expr:VariableExpr):Dynamic {
        if (environment.exists(expr.name)) return environment.get(expr.name);
        throw "Undefined variable '" + expr.name + "' at line " + expr.line + ", column " + expr.column;
    }
    

    public function visitStringExpr(expr:StringExpr):String {
        return expr.value;
    }


    public function visitCallExpr(expr:CallExpr):Dynamic {
        var callee:Dynamic = visitExpr(expr.callee);
        var args:Array<Dynamic> = [];
        for (arg in expr.arguments) {
            args.push(visitExpr(arg));
        }
        if (Std.isOfType(callee, Function)) {
            try {
                (callee : Function).call(args, this);
            } catch (e:Return) {
                return e.value;
            }
            return null;
        } else if (Std.isOfType(callee, NativeFunction)) {
            return (callee : NativeFunction).call(args, this);
        } else {
            throw "Attempted to call non-function object " + callee + " at line " + expr.line + ", column " + expr.column;
        }
    }

    
    public function visitNullExpr(expr:NullExpr):Dynamic {
        return null;
    }


    public function visitBooleanExpr(expr:BooleanExpr):Bool {
        return expr.value;
    }


    public function visitArrayExpr(expr:ArrayExpr):Array<Dynamic> {
        var elements:Array<Dynamic> = [];
        for (el in expr.elements) {
            elements.push(visitExpr(el));
        }
        return elements;
    }


    public function visitIndexExpr(expr:IndexExpr):Dynamic {
        var target:Dynamic = visitExpr(expr.target);
        var index:Dynamic = visitExpr(expr.index);
        if (Std.isOfType(target, Array)) {
            if (Std.isOfType(index, Int)) {
                var arr = (target : Array<Dynamic>);
                var idx = (index : Int);
                if (idx < 0 || idx >= arr.length) throw "Array index " + idx + " out of bounds at line " + expr.line + ", column " + expr.column;
                return arr[Std.int(idx)];
            } else throw "Array index " + index + " must be an integer at line " + expr.line + ", column " + expr.column;
        } else if (Std.isOfType(target, String)) {
            if (Std.isOfType(index, Int)) {
                var str = (target : String);
                var idx = (index : Int);
                if (idx < 0 || idx >= str.length) throw "String index " + idx + " out of bounds at line " + expr.line + ", column " + expr.column;
                return str.charAt(idx);
            } else throw "String index " + index + " must be an integer at line " + expr.line + ", column " + expr.column;
        } else throw "Attempted to index non-iterable " + target + " at line " + expr.line + ", column " + expr.column;
    }
}