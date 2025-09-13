package src;

import src.ast.*;

enum ScopeState {
    Global;
    Function;
    Loop;
}



class Parser {
    public var tokens:Array<Token>;
    public var position:Int = 0;
    public var scopeStates:Array<ScopeState>;


    public function new(tokens:Array<Token>) {
        this.tokens = tokens;
        scopeStates = [ScopeState.Global];
    }


    public function parse():Array<Stmt> {
        var statements:Array<Stmt> = [];
        while (!isAtEnd()) {
            statements.push(parseStatement());
        }
        return statements;
    }


    /// print <comparison> ;
    function parsePrintStatement():PrintStmt {
        advance(); // consume 'print'
        var expr = comparison();
        consume(TokenType.SEMICOLON, "Expected ';' after value.");
        return new PrintStmt(expr, previous().line, previous().column);
    }

    /// input <identifier> ;
    function parseInputStatement():InputStmt {
        advance(); // consume 'input'
        var name = consume(TokenType.IDENTIFIER, "Expected variable after 'input'.");
        consume(TokenType.SEMICOLON, "Expected ';' after value.");
        return new InputStmt(new VariableExpr(name.value, name.line, name.column), name.line, name.column);
    }

    /// let <identifier> (, <identifier>)* (= <comparison>)? ;
    function parseLetStatement():LetStmt {
        advance(); // consume 'let'
        var bindings:Array<VariableExpr> = [];
        do {
            var name = consume(TokenType.IDENTIFIER, "Expected variable name in let statement.");
            bindings.push(new VariableExpr(name.value, name.line, name.column));
        } while (match(TokenType.COMMA));

        if (check(TokenType.EQUALS)) {
            consume(TokenType.EQUALS, "Expected '=' after variable names in let statement.");
            var value = comparison();
            consume(TokenType.SEMICOLON, "Expected ';' after value.");
            return new LetStmt(bindings, value, previous().line, previous().column);
        } else {
            consume(TokenType.SEMICOLON, "Expected ';' after variable names.");
            return new LetStmt(bindings, null, previous().line, previous().column);
        }
    }

    /// while <comparison> do <stmt> end
    function parseWhileStatement():WhileStmt {
        advance(); // consume 'while'
        var condition = comparison();
        consume(TokenType.KEYWORD, "Expected 'do' after condition.");
        if (previous().value != "do") throw "Expected 'do' after condition.";
        scopeStates.push(ScopeState.Loop);
        // Enter a loop scope...
        var body = parseBlockWithTerminators(["end"], previous().line, previous().column);
        var kwEnd = consume(TokenType.KEYWORD, "Expected 'end' after while statement.");
        if (kwEnd.value != "end") throw "Expected 'end' after while statement.";
        // ...then revert to the previous scope
        scopeStates.pop();

        return new WhileStmt(condition, body, condition.line, condition.column);
    }

    /// for <identifier> in <comparison> do <stmt> end
    function parseForeachStatement():ForeachStmt {
        advance(); // consume 'for'
        var name = consume(TokenType.IDENTIFIER, "Expected loop variable after 'for'.");
        consume(TokenType.KEYWORD, "Expected 'in' after loop variable.");
        if (previous().value != "in") throw "Expected 'in' after loop variable.";
        var iterable = comparison();
        consume(TokenType.KEYWORD, "Expected 'do' after iterable.");
        if (previous().value != "do") throw "Expected 'do' after iterable.";
        scopeStates.push(ScopeState.Loop);
        // Enter a loop scope...
        var body = parseBlockWithTerminators(["end"], previous().line, previous().column);
        var kwEnd = consume(TokenType.KEYWORD, "Expected 'end' after for statement.");
        if (kwEnd.value != "end") throw "Expected 'end' after for statement.";
        // ...then revert to the previous scope
        scopeStates.pop();

        return new ForeachStmt(new VariableExpr(name.value, name.line, name.column), iterable, body, name.line, name.column);
    }

    /// if <comparison> then <stmt> (else <stmt>)?
    function parseIfStatement():IfStmt {
        advance(); // consume 'if'
        var condition = comparison();
        consume(TokenType.KEYWORD, "Expected 'then' after condition.");
        if (previous().value != "then") throw "Expected 'then' after condition.";
        var thenBranch = parseBlockWithTerminators(["else", "end"], previous().line, previous().column);
        var elseBranch:BlockStmt = null;
        if (check(TokenType.KEYWORD) && peek().value == "else") {
            advance(); // consume 'else'
            elseBranch = parseBlockWithTerminators(["end"], previous().line, previous().column);
        }
        
        var kwEnd = consume(TokenType.KEYWORD, "Expected 'end' after if statement.");
        if (kwEnd.value != "end") throw "Expected 'end' after if statement.";

        return new IfStmt(condition, thenBranch, elseBranch, condition.line, condition.column);
    }

    /// inc <identifier> ;
    function parseIncStatement():LetStmt {
        advance(); // consume 'inc'
        var name = consume(TokenType.IDENTIFIER, "Expected variable after 'inc'.");
        consume(TokenType.SEMICOLON, "Expected ';' after variable.");
        var varExpr = new VariableExpr(name.value, name.line, name.column);
        var one = new NumberExpr(1, name.line, name.column);
        var binary = new BinaryExpr(varExpr, new Token(TokenType.PLUS, "+", name.line, name.column), one, name.line, name.column);
        return new LetStmt([new VariableExpr(Std.string(name.value), name.line, name.column)], binary, name.line, name.column);
    }

    /// dec <identifier> ;
    function parseDecStatement():LetStmt {
        advance(); // consume 'dec'
        var name = consume(TokenType.IDENTIFIER, "Expected variable after 'dec'.");
        consume(TokenType.SEMICOLON, "Expected ';' after variable.");
        var varExpr = new VariableExpr(name.value, name.line, name.column);
        var one = new NumberExpr(1, name.line, name.column);
        var binary = new BinaryExpr(varExpr, new Token(TokenType.MINUS, "-", name.line, name.column), one, name.line, name.column);
        return new LetStmt([new VariableExpr(Std.string(name.value), name.line, name.column)], binary, name.line, name.column);
    }

    /// return (<comparison>)? ;
    function parseReturnStatement():ReturnStmt {
        if (scopeStates[scopeStates.length - 1] == ScopeState.Function) {
            advance(); // consume 'return'
            var expr:Expr = new NullExpr(previous().line, previous().column);
            if (!check(TokenType.SEMICOLON)) {
                expr = comparison();
            }
            consume(TokenType.SEMICOLON, "Expected ';'.");
            return new ReturnStmt(expr, previous().line, previous().column);
        } else {
            throw "Return statement not allowed outside of function at line " + peek().line + ", column " + peek().column;
        }
    }

    /// func <identifier> ( <identifier> (, <identifier>)* )? <stmt> end
    function parseFunctionStatement():FunctionStmt {
        advance(); // consume 'func'
        var nameToken = consume(TokenType.IDENTIFIER, "Expected function name after 'func'.");
        var name = nameToken.value;
        consume(TokenType.LPAREN, "Expected '(' after function name.");
        var params:Array<Parameter> = parseParameters();
        consume(TokenType.RPAREN, "Expected ')' after parameters.");
        // Start parsing function body in a function scope...
        scopeStates.push(ScopeState.Function);
        var body = parseBlockWithTerminators(["end"], previous().line, previous().column);
        var kwEnd = consume(TokenType.KEYWORD, "Expected 'end' after function body.");
        if (kwEnd.value != "end") throw "Expected 'end' after function body.";
        // ...then revert to the previous scope
        scopeStates.pop();
        return new FunctionStmt(name, params, body, nameToken.line, nameToken.column);
    }

    /// (id (= expr)? (, id (= expr)?)* )
    function parseParameters():Array<Parameter> {
        var params:Array<Parameter> = [];

        if (!check(TokenType.RPAREN)) {
            do {
                var name = consume(TokenType.IDENTIFIER, "Expected parameter name.");
                var defaultValue:Expr = null;

                if (match(TokenType.EQUALS)) {
                    defaultValue = expr(); // parse default expression
                }

                params.push(new Parameter(name.value, defaultValue, name.line, name.column));
            } while (match(TokenType.COMMA));
        }

        return params;
    }

    /// <statement>*
    function parseBlockWithTerminators(terminators:Array<String>, line:Int, column:Int):BlockStmt {
        var statements:Array<Stmt> = [];
        while (!isAtEnd() && !(check(TokenType.KEYWORD) && terminators.indexOf(peek().value) != -1)) {
            statements.push(parseStatement());
        }
        
        return new BlockStmt(statements, line, column);
    }

    
    function parseStatement():Stmt {
        if (check(TokenType.KEYWORD) && peek().value == "print") return parsePrintStatement();
        if (check(TokenType.KEYWORD) && peek().value == "input") return parseInputStatement();
        if (check(TokenType.KEYWORD) && peek().value == "let") return parseLetStatement();
        if (check(TokenType.KEYWORD) && peek().value == "if") return parseIfStatement();
        if (check(TokenType.KEYWORD) && peek().value == "while") return parseWhileStatement();
        if (check(TokenType.KEYWORD) && peek().value == "for") return parseForeachStatement();
        if (check(TokenType.KEYWORD) && peek().value == "inc") return parseIncStatement();
        if (check(TokenType.KEYWORD) && peek().value == "dec") return parseDecStatement();
        if (check(TokenType.KEYWORD) && peek().value == "return") return parseReturnStatement();
        if (check(TokenType.KEYWORD) && peek().value == "func") return parseFunctionStatement();

        // Fallback to expression statement
        var val:Expr = comparison();
        consume(TokenType.SEMICOLON, "Expected ';' after expression.");
        return new ExprStmt(val, val.line, val.column);
    }

    function comparison():Expr {
        var left:Expr = expr();
        while (match(TokenType.GT) || match(TokenType.GTEQ) || match(TokenType.LT) || match(TokenType.LTEQ) || match(TokenType.EQEQ) || match(TokenType.NOTEQ)) {
            var oper:Token = previous();
            var right:Expr = term();
            left = new BinaryExpr(left, oper, right, oper.line, oper.column);
        }
        return left;
    }


    function expr():Expr {
        var left:Expr = term();
        while (match(TokenType.PLUS) || match(TokenType.MINUS)) {
            var oper:Token = previous();
            var right:Expr = term();
            left = new BinaryExpr(left, oper, right, oper.line, oper.column);
        }
        return left;
    }


    function term():Expr {
        var left:Expr = unary();
        while (match(TokenType.STAR) || match(TokenType.SLASH)) {
            var oper:Token = previous();
            var right:Expr = unary();
            left = new BinaryExpr(left, oper, right, oper.line, oper.column);
        }
        return left;
    }


    function unary():Expr {
        if (check(TokenType.BANG) || check(TokenType.MINUS)) {
            var oper:Token = advance();
            var right:Expr = unary();
            return new UnaryExpr(oper, right, oper.line, oper.column);
        }
        return call();
    }


    function call():Expr {
        var expr = factor();
        while (true) {
            if (match(TokenType.LPAREN)) {
                var args:Array<Expr> = [];
                if (!check(TokenType.RPAREN)) {
                    do {
                        args.push(comparison());
                    } while (match(TokenType.COMMA));
                }
                var paren = consume(TokenType.RPAREN, "Expected ')' after arguments.");
                expr = new CallExpr(expr, args, paren.line, paren.column);
            } else if (match(TokenType.LBRACK)) {
                var indexExpr = comparison();
                var rbrack = consume(TokenType.RBRACK, "Expected ']' after array index.");
                expr = new IndexExpr(expr, indexExpr, rbrack.line, rbrack.column);
            } else {
                break;
            }
        }
        return expr;
    }


    function factor():Expr {
        if (match(TokenType.NUMBER)) {
            return new NumberExpr(Std.parseFloat(previous().value), previous().line, previous().column);
        }
        if (match(TokenType.LPAREN)) {
            var expr = expr();
            consume(TokenType.RPAREN, "Expected ')' after expression.");
            return expr;
        }
        if (match(TokenType.IDENTIFIER)) {
            return new VariableExpr(previous().value, previous().line, previous().column);
        }
        if (match(TokenType.STRING)) {
            return new StringExpr(previous().value, previous().line, previous().column);
        }
        if (check(TokenType.KEYWORD) && (peek().value == "true" || peek().value == "false")) {
            var kw = advance();
            return new BooleanExpr(kw.value == "true", kw.line, kw.column);
        }
        if (check(TokenType.KEYWORD) && peek().value == "null") {
            var kw = advance();
            return new NullExpr(kw.line, kw.column);
        }
        if (check(TokenType.LBRACK)) {
            advance(); // consume '['
            var elements:Array<Expr> = [];
            if (!check(TokenType.RBRACK)) {
                do {
                    elements.push(comparison());
                } while (match(TokenType.COMMA));
            }
            consume(TokenType.RBRACK, "Expected ']' after array elements.");
            return new ArrayExpr(elements, previous().line, previous().column);
        }
        throw "Unexpected token in factor: " + peek();
    }


    function match(type:TokenType):Bool {
        if (check(type)) {
            advance();
            return true;
        }
        return false;
    }


    function consume(type:TokenType, message:String):Token {
        if (check(type)) return advance();
        throw message + " -- Found: " + peek();
    }


    function check(type:TokenType):Bool {
        if (isAtEnd()) return false;
        return peek().type == type;
    }


    function advance():Token {
        if (!isAtEnd()) position++;
        return previous();
    }


    function isAtEnd():Bool {
        return position >= tokens.length;
    }


    function peek():Token {
        return isAtEnd() ? null : tokens[position];
    }


    function previous():Token {
        return position > 0 ? tokens[position - 1] : null;
    }
}