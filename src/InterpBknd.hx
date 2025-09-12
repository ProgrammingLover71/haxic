package src;

import src.ast.*;

class InterpBknd extends ASTWalker {
    public var environment:Map<String, Dynamic>;

    public function new() {
        environment = new Map();
        environment.set("pi", Math.PI);
        environment.set("e", Math.exp(1));
        environment.set("inf", Math.POSITIVE_INFINITY);
        environment.set("nan", Math.NaN);
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
        environment.set(stmt.target.name, final_val);
    }

    public function visitLetStmt(stmt:LetStmt) {
        var value:Dynamic = null;
        if (stmt.value != null) {
            value = visitExpr(stmt.value);
        }
        for (v in stmt.bindings) {
            environment.set(v.name, value);
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

    public function visitBlockStmt(stmt:BlockStmt) {
        for (s in stmt.statements) {
            visitStmt(s);
        }
    }

    public function visitExprStmt(stmt:ExprStmt) {
        visitExpr(stmt.expr);
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
        } else {
            throw "Unknown statement type: " + stmt;
        }
    }

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
                return left + right;
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
}