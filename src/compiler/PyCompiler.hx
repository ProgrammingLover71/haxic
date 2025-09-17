package src.compiler;

import src.ast.*;

class PyCompiler {
    var code:String;
    var head:String;
    var indent:Int;
    var lambda_idx:Int;
    
    public function new() {
        code = "";
        head = "";
        indent = 0;
        lambda_idx = 0;
        writeHeader();
    }

    function new_lambda_id() {
        return "$lambda" + (lambda_idx++);
    }

    function writeHeader() {
        head += "import haxic_std\n\n";
    }

    function writeIndent() {
        for (i in 0...indent) {
            write("\t");
        }
    }

    function write(text:String) {
        code += text;
    }

    function write_head(text:String) {
        head += text;
    }

    public function getCode():String {
        return head + code;
    }

    public function visit(ast:Array<Stmt>) {
        for (stmt in ast) {
            if (stmt != null) visitStmt(stmt);
        }
    }


    public function visitStmt(stmt:Stmt) {
        writeIndent();
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


    public function visitExpr(expr:Expr) {
        if (Std.isOfType(expr, BinaryExpr)) {
            visitBinaryExpr(cast expr);
        } else if (Std.isOfType(expr, NumberExpr)) {
            visitNumberExpr(cast expr);
        } else if (Std.isOfType(expr, VariableExpr)) {
            visitVariableExpr(cast expr);
        } else if (Std.isOfType(expr, UnaryExpr)) {
            visitUnaryExpr(cast expr);
        } else if (Std.isOfType(expr, StringExpr)) {
            visitStringExpr(cast expr);
        } else if (Std.isOfType(expr, CallExpr)) {
            visitCallExpr(cast expr);
        } else if (Std.isOfType(expr, BooleanExpr)) {
            visitBooleanExpr(cast expr);
        } else if (Std.isOfType(expr, NullExpr)) {
            visitNullExpr(cast expr);
        } else if (Std.isOfType(expr, ArrayExpr)) {
            visitArrayExpr(cast expr);
        } else if (Std.isOfType(expr, IndexExpr)) {
            visitIndexExpr(cast expr);
        } else if (Std.isOfType(expr, MapExpr)) {
            visitMapExpr(cast expr);
        } else if (Std.isOfType(expr, FunctionExpr)) {
            visitFunctionExpr(cast expr);
        } else {
            throw "Unknown expression type: " + expr;
        }
    }

    public function visitPrintStmt(stmt:PrintStmt) {
        write("print(");
        visitExpr(stmt.expr);
        write(")\n");
    }

    public function visitInputStmt(stmt:InputStmt) {
        visitVariableExpr(stmt.target);
        write(" = input()\ntry: ");
        visitVariableExpr(stmt.target);
        write(" = float(");
        visitVariableExpr(stmt.target);
        write(")\nexcept ValueError: pass\n");
    }

    public function visitLetStmt(stmt:LetStmt) {
        var bind_idx = 0;
        for (bind in stmt.bindings) {
            visitVariableExpr(bind);
            if (bind_idx < (stmt.bindings.length - 1)) write(", ");
        }
        write(" = ");
        visitExpr(stmt.value);
        write("\n");
    }

    public function visitIfStmt(stmt:IfStmt) {
        write("if ");
        visitExpr(stmt.condition);
        write(":\n");
        // Compile the 'then' branch
        indent++;
        visitStmt(stmt.thenBranch);
        indent--;
        // Check for an 'else' branch and parse it
        if (stmt.elseBranch != null) {
            writeIndent();
            write("else:");
            indent++;
            visitStmt(stmt.elseBranch);
            indent--;
        }
    }

    public function visitForeachStmt(stmt:ForeachStmt) {
        write("for ");
        visitVariableExpr(stmt.variable);
        write(" in ");
        visitExpr(stmt.target);
        write(":\n");
        indent++;
        visitStmt(stmt.body);
        indent--;
    }

    public function visitWhileStmt(stmt:WhileStmt) {
        write("while ");
        visitExpr(stmt.condition);
        write(":\n");
        indent++;
        visitStmt(stmt.body);
        indent--;
    }

    public function visitBlockStmt(stmt:BlockStmt) {
        for (st in stmt.statements) {
            visitStmt(st);
        }
    }

    public function visitExprStmt(stmt:ExprStmt) {
        visitExpr(stmt.expr);
        write("\n");
    }

    public function visitFunctionStmt(stmt:FunctionStmt) {
        write("def " + stmt.name + "(");
        // Compile the arguments
        var param_idx = 0;
        for (param in stmt.params) {
            write(param.name);
            if (param.defaultValue != null) {
                write(" = ");
                visitExpr(param.defaultValue);
            }
            if (param_idx < (stmt.params.length)) write(", ");
        }
        write("):\n");
        indent++;
        visitStmt(stmt.body);
        indent--;
    }

    public function visitReturnStmt(stmt:ReturnStmt) {
        write("return ");
        visitExpr(stmt.value);
        write("\n");
    }

    public function visitBinaryExpr(expr:BinaryExpr) {
        write("(");
        visitExpr(expr.left);
        write(" " + expr.oper.value + " ");
        visitExpr(expr.right);
        write(")");
    }

    public function visitNumberExpr(expr:NumberExpr) {
        write(Std.string(expr.value));
    }

    public function visitVariableExpr(expr:VariableExpr) {
        write(expr.name);
    }

    public function visitUnaryExpr(expr:UnaryExpr) {
        write("(");
        write(Std.string(expr.oper.value));
        visitExpr(expr.right);
        write(")");
    }

    public function visitStringExpr(expr:StringExpr) {
        write("\"" + expr.value + "\"");
    }

    public function visitArrayExpr(expr:ArrayExpr) {
        write("[");
        // Compile the elements
        var expr_idx = 0;
        for (value in expr.elements) {
            visitExpr(value);
            if (expr_idx < (expr.elements.length - 1)) write(", ");
        }
        write("]");
    }

    public function visitIndexExpr(expr:IndexExpr) {
        visitExpr(expr.target);
        write("[");
        visitExpr(expr.index);
        write("]");
    }

    public function visitCallExpr(expr:CallExpr) {
        visitExpr(expr.callee);
        write("(");
        // Compile the arguments
        var expr_idx = 0;
        for (value in expr.arguments) {
            visitExpr(value);
            if (expr_idx < (expr.arguments.length - 1)) write(", ");
        }
        write(")");
    }

    public function visitBooleanExpr(expr:BooleanExpr) {
        write(expr.value ? "True" : "False");
    }

    public function visitNullExpr(expr:NullExpr) {
        write("None");
    }

    public function visitFunctionExpr(expr:FunctionExpr) {
        var l_id:String = new_lambda_id();
        // Compile the function separately
        write_head("def " + l_id + "(");
        // Compile the arguments
        var param_idx = 0;
        for (param in expr.params) {
            write_head(param.name);
            if (param.defaultValue != null) {
                write_head(" = ");
                visitExpr(param.defaultValue);
            }
            if (param_idx < (expr.params.length)) write_head(", ");
        }
        write_head("):\n");
        indent++;
        visitStmt(expr.body);
        indent--;
        write_head("\n");
        write(l_id);
    }
    
    public function visitMapExpr(expr:MapExpr) {
        write("{");
        var pair_idx = 0;
        for (pair in expr.pairs) {
            write(pair.key + ": ");
            visitExpr(pair.value);
            if (pair_idx < (expr.pairs.length - 1)) write(", ");
        }
        write("}");
    }
}