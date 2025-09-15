package src;

import src.ast.*;
import src.types.*;

abstract class ASTWalker {
    // Statements
    abstract public function visitPrintStmt(stmt:PrintStmt):Void;
    abstract public function visitInputStmt(stmt:InputStmt):Void;
    abstract public function visitLetStmt(stmt:LetStmt):Void;
    abstract public function visitIfStmt(stmt:IfStmt):Void;
    abstract public function visitStmt(stmt:Stmt):Void;
    abstract public function visitBlockStmt(stmt:BlockStmt):Void;
    abstract public function visitExprStmt(stmt:ExprStmt):Void;
    abstract public function visitFunctionStmt(stmt:FunctionStmt):Void;
    // Expressions
    abstract public function visitBinaryExpr(expr:BinaryExpr):Value;
    abstract public function visitNumberExpr(expr:NumberExpr):Value;
    abstract public function visitVariableExpr(expr:VariableExpr):Value;
    abstract public function visitUnaryExpr(expr:UnaryExpr):Value;
    abstract public function visitStringExpr(expr:StringExpr):Value;
    abstract public function visitExpr(expr:Expr):Dynamic;
    abstract public function visitArrayExpr(expr:ArrayExpr):Value;
    abstract public function visitIndexExpr(expr:IndexExpr):Value;
    abstract public function visitCallExpr(expr:CallExpr):Value;
    abstract public function visitBooleanExpr(expr:BooleanExpr):Value;
    abstract public function visitNullExpr(expr:NullExpr):Value;
    abstract public function visitFunctionExpr(expr:FunctionExpr):Value;
    abstract public function visitMapExpr(expr:MapExpr):Value;
}