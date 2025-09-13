package src;

import src.ast.*;

abstract class ASTWalker {
    // Statements
    abstract public function visitPrintStmt(stmt:PrintStmt):Void;
    abstract public function visitInputStmt(stmt:InputStmt):Void;
    abstract public function visitLetStmt(stmt:LetStmt):Void;
    abstract public function visitIfStmt(stmt:IfStmt):Void;
    abstract public function visitStmt(stmt:Stmt):Void;
    abstract public function visitBlockStmt(stmt:BlockStmt):Void;
    abstract public function visitExprStmt(stmt:ExprStmt):Void;
    // Expressions
    abstract public function visitBinaryExpr(expr:BinaryExpr):Dynamic;
    abstract public function visitNumberExpr(expr:NumberExpr):Dynamic;
    abstract public function visitVariableExpr(expr:VariableExpr):Dynamic;
    abstract public function visitUnaryExpr(expr:UnaryExpr):Dynamic;
    abstract public function visitStringExpr(expr:StringExpr):Dynamic;
    abstract public function visitExpr(expr:Expr):Dynamic;
    abstract public function visitArrayExpr(expr:ArrayExpr):Dynamic;
    abstract public function visitIndexExpr(expr:IndexExpr):Dynamic;
    abstract public function visitCallExpr(expr:CallExpr):Dynamic;
    abstract public function visitBooleanExpr(expr:BooleanExpr):Dynamic;
    abstract public function visitNullExpr(expr:NullExpr):Dynamic;
}