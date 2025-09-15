package src;

import haxe.ds.StringMap;
import src.ast.*;
import src.types.*;



class Environment {
    public var values:haxe.ds.StringMap<Value>;
    public var parent:Environment;

    public function new(parent:Environment = null) {
        this.parent = parent;
        this.values = new haxe.ds.StringMap<Value>();
    }

    public function define(name:String, value:Value):Void {
        values.set(name, value);
    }

    public function assign(name:String, value:Value):Void {
        if (values.exists(name)) {
            values.set(name, value);
            return;
        }
        if (parent != null) {
            parent.assign(name, value);
            return;
        }
        throw "Undefined variable '" + name + "'";
    }

    public function get(name:String):Value {
        if (values.exists(name)) return values.get(name);
        if (parent != null) return parent.get(name);
        throw "Undefined variable '" + name + "'";
    }

    public function exists(name:String):Bool {
        if (values.exists(name)) return true;
        if (parent != null) return parent.exists(name);
        return false;
    }
}




class Return extends haxe.Exception {
    public var value:Value;

    public function new(value:Value) {
        super("Return");
        this.value = value;
    }
}



class Interpreter extends ASTWalker {
    public var environment:Environment;

    public function new() {
        environment = new Environment();
        environment.define("pi", Value.VNumber(Math.PI));
        environment.define("e", Value.VNumber(Math.exp(1)));
        environment.define("inf", Value.VNumber(Math.POSITIVE_INFINITY));
        environment.define("nan", Value.VNumber(Math.NaN));

        loadFunctions();
    }

    public function visit(ast:Array<Stmt>) {
        for (stmt in ast) {
            if (stmt != null) visitStmt(stmt);
        }
    }


    public function visitPrintStmt(stmt:PrintStmt) {
        var value:Value = visitExpr(stmt.expr);
        // Use Sys.stdout().write() instead of trace() for a cleaner output and to avoid showing the file and line number
        Utils.print(Utils.stringify(value));
    }


    public function visitInputStmt(stmt:InputStmt) {
        var input:String = Sys.stdin().readLine();
        var num:Float = Std.parseFloat(input);
        var final_val:Value = if (num == Math.NaN) VString(input) else VNumber(num);
        environment.define(stmt.target.name, final_val);
    }


    public function visitLetStmt(stmt:LetStmt) {
        var value:Value = null;
        if (stmt.value != null) {
            value = visitExpr(stmt.value);
        }
        for (v in stmt.bindings) {
            environment.define(v.name, value);
        }
    }


    public function visitIfStmt(stmt:IfStmt) {
        var condition:Value = visitExpr(stmt.condition);
        if (V.isTruthy(condition)) {
            visitBlockStmt(stmt.thenBranch);
        } else if (stmt.elseBranch != null) {
            visitBlockStmt(stmt.elseBranch);
        }
    }


    public function visitWhileStmt(stmt:WhileStmt) {
        var condition:Value = visitExpr(stmt.condition);
        while (V.isTruthy(condition)) {
            visitBlockStmt(stmt.body);
            condition = visitExpr(stmt.condition);
        }
    }

    public function visitForeachStmt(stmt:ForeachStmt) {
        var iterable:Value = visitExpr(stmt.target);
        var varName = stmt.variable.name;
        if (Std.isOfType(iterable, Array)) {
            for (item in V.toArray(iterable)) {
                environment.define(varName, item);
                visitStmt(stmt.body);
            }
        } else if (Std.isOfType(iterable, String)) {
            for (i in 0...V.toString(iterable).length) {
                environment.define(varName, VString(V.toString(iterable).charAt(i)));
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
        var value:Value = null;
        if (stmt.value != null) {
            value = visitExpr(stmt.value);
        }
        throw new Return(value);
    }


    public function visitFunctionStmt(stmt:FunctionStmt) {
        var functionObj = new Function(stmt.name, stmt.params, stmt.body);
        environment.define(stmt.name, VFunc(functionObj));
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

    public function visitExpr(expr:Expr):Value {
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
        } else if (Std.isOfType(expr, MapExpr)) {
            return visitMapExpr(cast expr);
        } else if (Std.isOfType(expr, FunctionExpr)) {
            return visitFunctionExpr(cast expr);
        } else {
            throw "Unknown expression type: " + expr;
        }
    }


    public function visitUnaryExpr(expr:UnaryExpr):Value {
        var right:Value = visitExpr(expr.right);
        switch (expr.oper.type) {
            case TokenType.MINUS:
                return Value.VNumber(-V.toNumber(right));
            case TokenType.BANG:
                return Value.VBool(!V.isTruthy(right));
            default:
                throw "Unknown unary operator " + expr.oper.value + " at line " + expr.oper.line + ", column " + expr.oper.column;
        }
    }


    public function visitBinaryExpr(expr:BinaryExpr):Value {
        var left:Value = visitExpr(expr.left);
        var right:Value = visitExpr(expr.right);
        switch (expr.oper.type) {
            case TokenType.PLUS:
                // Handle string concatenation, array merging, map merging and keep numeric addition
                if (Std.isOfType(left, Array) && Std.isOfType(right, Array)) {
                    return Value.VArray(V.toArray(left).concat(V.toArray(right)));
                } else if (Std.isOfType(left, StringMap) && Std.isOfType(right, StringMap)) {
                    var result:StringMap<Value> = new StringMap();
                    for (key in V.toMap(left).keys()) {
                        result.set(key, V.toMap(left).get(key));
                    }
                    for (key in V.toMap(right).keys()) {
                        result.set(key, V.toMap(right).get(key));
                    }
                    return Value.VMap(result);
                } else if (Std.isOfType(left, String) || Std.isOfType(right, String)) {
                    return Value.VString(Std.string(left) + Std.string(right));
                } else {
                    return Value.VNumber(V.toNumber(left) + V.toNumber(right));
                }
            case TokenType.MINUS:
                return Value.VNumber(V.toNumber(left) - V.toNumber(right));
            case TokenType.STAR:
                return Value.VNumber(V.toNumber(left) * V.toNumber(right));
            case TokenType.SLASH:
                return Value.VNumber(V.toNumber(left) / V.toNumber(right));
            case TokenType.GT:
                return Value.VBool(V.toNumber(left) > V.toNumber(right));
            case TokenType.GTEQ:
                return Value.VBool(V.toNumber(left) >= V.toNumber(right));
            case TokenType.LT:
                return Value.VBool(V.toNumber(left) < V.toNumber(right));
            case TokenType.LTEQ:
                return Value.VBool(V.toNumber(left) <= V.toNumber(right));
            case TokenType.EQEQ:
                return Value.VBool(V.toNumber(left) == V.toNumber(right));
            case TokenType.NOTEQ:
                return Value.VBool(V.toNumber(left) != V.toNumber(right));
            default:
                throw "Unknown operator " + expr.oper.value + " at line " + expr.oper.line + ", column " + expr.oper.column;
        }
    }


    public function visitNumberExpr(expr:NumberExpr):Value {
        return Value.VNumber(expr.value);
    }


    public function visitVariableExpr(expr:VariableExpr):Value {
        if (environment.exists(expr.name)) return environment.get(expr.name);
        throw "Undefined variable '" + expr.name + "' at line " + expr.line + ", column " + expr.column;
    }
    

    public function visitStringExpr(expr:StringExpr):Value {
        return Value.VString(expr.value);
    }


    public function visitCallExpr(expr:CallExpr):Value {
        var callee:Value = visitExpr(expr.callee);
        var args:Array<Value> = [];
        for (arg in expr.arguments) {
            args.push(visitExpr(arg));
        }
        switch (callee) {
            case VFunc(func):
                try {
                    func.call(args, this);
                } catch (e:Return) {
                    return e.value;
                }
                return null;
            case VNative(func):
                return func.call(args, this);
            default:
                throw "Attempted to call non-function object " + callee + " at line " + expr.line + ", column " + expr.column;
        }
    }

    
    public function visitNullExpr(expr:NullExpr):Value {
        return Value.VNull;
    }


    public function visitBooleanExpr(expr:BooleanExpr):Value {
        return Value.VBool(expr.value);
    }


    public function visitArrayExpr(expr:ArrayExpr):Value {
        var elements:Array<Value> = [];
        for (el in expr.elements) {
            elements.push(visitExpr(el));
        }
        return Value.VArray(elements);
    }


    public function visitIndexExpr(expr:IndexExpr):Value {
        var target:Value = visitExpr(expr.target);
        var index:Value = visitExpr(expr.index);
        switch (target) {
            case Value.VArray(arr):
                switch (index) {
                    case VNumber(idx):
                        if (idx < 0 || idx >= arr.length) throw "Array index " + idx + " out of bounds at line " + expr.line + ", column " + expr.column;
                        return arr[Std.int(idx)];
                    default: throw "Array index " + index + " must be an integer at line " + expr.line + ", column " + expr.column;
                }
            
            case Value.VString(str):
                switch (index) {
                    case VNumber(idx):
                        if (idx < 0 || idx >= str.length) throw "String index " + idx + " out of bounds at line " + expr.line + ", column " + expr.column;
                        return Value.VString(str.charAt(Std.int(idx)));
                    default: throw "String index " + index + " must be an integer at line " + expr.line + ", column " + expr.column;
                }
            
            case Value.VMap(map):
                switch (index) {
                    case Value.VString(key):
                        if (!map.exists(key)) throw "Map key '" + key + "' does not exist at line " + expr.line + ", column " + expr.column;
                        return map.get(key);
                    default: throw "Map key " + index + " must be a string at line " + expr.line + ", column " + expr.column;
                }
            
            default: throw "Attempted to index non-iterable " + target + " at line " + expr.line + ", column " + expr.column;
        }
    }

    public function visitMapExpr(expr:MapExpr):Value {
        var result:StringMap<Value> = new StringMap();
        for (pair in expr.pairs) {
            var key = pair.key;
            var value = visitExpr(pair.value);
            result.set(key, value);
        }
        return Value.VMap(result);
    }

    public function visitFunctionExpr(expr:FunctionExpr):Value {
        return Value.VFunc(new Function(expr.name, expr.params, expr.body));
    }



    // ======== Runtime init stuff :) ======== //



    function loadFunctions() {
        // clock: () => number
        environment.define("clock", Value.VNative(new NativeFunction("clock", [], function(env) {
            return Value.VNumber(Sys.time());
        })));

        // length: (any) => number
        environment.define("length", Value.VNative(new NativeFunction("length", [new Parameter("item", null, 0, 0)], function(env) {
            var item:Value = env.get("item");
            if (Std.isOfType(item, String)) {
                return Value.VNumber(V.toString(item).length);
            } else if (Std.isOfType(item, Array)) {
                return Value.VNumber(V.toArray(item).length);
            } else if (Std.isOfType(item, StringMap)) {
                var count:Int = 0;
                for (key in V.toMap(item).keys()) count++;
                return Value.VNumber(count);
            } else if (Std.isOfType(item, Function)) {
                return Value.VNumber(V.toFunc(item).params.length);
            } else if (Std.isOfType(item, NativeFunction)) {
                return Value.VNumber(V.toNativeFunc(item).params.length);
            } else {
                throw "length() argument must be a string, array, map or function";
            }
        })));

        // typeof: (any) => string
        environment.define("typeof", Value.VNative(new NativeFunction("typeof", [new Parameter("item", null, 0, 0)], function(env) {
            var item:Value = env.get("item");
            if (item == Value.VNull) return Value.VString("null");
            if (Std.isOfType(item, Value.VBool)) return Value.VString("bool");
            if (Std.isOfType(item, Value.VNumber)) return Value.VString("number");
            if (Std.isOfType(item, Value.VString)) return Value.VString("string");
            if (Std.isOfType(item, Value.VArray)) return Value.VString("array");
            if (Std.isOfType(item, Value.VFunc) || Std.isOfType(item, NativeFunction)) return Value.VString("function");
            return Value.VString("object");
        })));

        // range: (number, number, number) => array
        environment.define("range", Value.VNative(new NativeFunction("range", [
            new Parameter("start", null, 0, 0), 
            new Parameter("end", null, 0, 0), 
            new Parameter("step", new NumberExpr(1, 0, 0), 0, 0)
        ], function(env) {
            var start:Value = env.get("start");
            var end:Value = env.get("end");
            var step:Value = env.get("step");
            if (!Std.isOfType(start, Float) || !Std.isOfType(end, Float) || !Std.isOfType(step, Float)) {
                throw "range() arguments must be numbers";
            }
            var result:Array<Value> = [];
            var i = V.toNumber(start);
            if (V.toNumber(step) == 0) throw "range() step argument must not be zero";
            if (V.toNumber(step) > 0) {
                while (i < V.toNumber(end)) {
                    result.push(Value.VNumber(i));
                    i += V.toNumber(step);
                }
            } else {
                while (i > V.toNumber(end)) {
                    result.push(Value.VNumber(i));
                    i += V.toNumber(step);
                }
            }
            return Value.VArray(result);
        })));

        // clear: () => null
        environment.define("clear", Value.VNative(new NativeFunction("clear", [], function(env) {
            if (Sys.systemName().toLowerCase().indexOf("windows") != -1) {
                Sys.command("cls");
            } else {
                Sys.command("clear");
            }
            return Value.VNull;
        })));

        // map_arr: (array, func) => array
        environment.define("map", Value.VNative(new NativeFunction("map", [
            new Parameter("arr", null, 0, 0), 
            new Parameter("func", null, 0, 0)
        ], function(env) {
            var arr:Value = env.get("arr");
            var func:Value = env.get("func");
            if (!Std.isOfType(arr, Array)) {
                throw "map() first argument must be an array";
            }
            if (!(Std.isOfType(func, Function) || Std.isOfType(func, NativeFunction))) {
                throw "map() second argument must be a function";
            }
            var result:Array<Value> = [];
            for (item in V.toArray(arr)) {
                if (Std.isOfType(func, Function)) {
                    try {
                        V.toFunc(func).call([item], this);
                    } catch (e:Return) {
                        result.push(e.value);
                    }
                } else if (Std.isOfType(func, NativeFunction)) {
                    result.push(V.toNativeFunc(func).call([item], this));
                }
            }
            return Value.VArray(result);
        })));

        // toString: (any) => string
        environment.define("toString", Value.VNative(new NativeFunction("toString", [new Parameter("item", null, 0, 0)], function(env) {
            var item:Value = env.get("item");
            return Value.VString(Utils.stringify(item));
        })));


        environment.define("math", Value.VMap(new StringMap<Value>()));

        // math.sqrt: (number) => number
        V.toMap(environment.get("math")).set("sqrt", Value.VNative(new NativeFunction("sqrt", [
            new Parameter("num", null, 0, 0)
        ], function(env) {
            return Value.VNumber(Math.sqrt(V.toNumber(env.get("num"))));
        })));

        // math.cos: (number) => number
        V.toMap(environment.get("math")).set("cos", Value.VNative(new NativeFunction("cos", [
            new Parameter("x", null, 0, 0)
        ], function (env) {
            return Value.VNumber(Math.cos(V.toNumber(env.get("x"))));
        })));

        // math.tan: (number) => number
        V.toMap(environment.get("math")).set("tan", Value.VNative(new NativeFunction("tan", [
            new Parameter("x", null, 0, 0)
        ], function (env) {
            return Value.VNumber(Math.tan(V.toNumber(env.get("x"))));
        })));

        // math.pow: (number, number) => number
        V.toMap(environment.get("math")).set("pow", Value.VNative(new NativeFunction("pow", [
            new Parameter("x", null, 0, 0),
            new Parameter("y", new NumberExpr(1, 0, 0), 0, 0)
        ], function (env) {
            return Value.VNumber(Math.pow(
                V.toNumber(env.get("x")), 
                V.toNumber(env.get("y"))
            ));
        })));
    }
}