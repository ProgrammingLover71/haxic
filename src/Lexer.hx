package src;

class Lexer {
    public var source:String;
    var position:Int = 0;
    var current:String;
    var line:Int;
    var column:Int;

    public function new(source:String) {
        this.source = source;
        this.position = -1;
        this.current = "";
        this.line = 1;
        this.column = 0;
        advance();
    }

    function advance():Void {
        position++;
        column++;
        if (position < source.length) {
            current = source.charAt(position);
            if (current == '\n') {
                line++;
                column = 0;
            }
        } else {
            current = ""; // End of input
        }
    }

    function peek():String {
        if (position < source.length) {
            return source.charAt(position);
        } else {
            return ""; // End of input
        }
    }

    function isEof():Bool {
        return position >= source.length;
    }

    function skipWhitespace():Void {
        while (!isEof() && (current == ' ' || current == '\t' || current == '\n' || current == '\r')) {
            advance();
        }
    }

    function skipComments():Void {
        if (current == '#') {
            while (!isEof() && current != '\n') {
                advance();
            }
            advance(); // Skip the newline
        }
    }

    public function tokenize():Array<Token> {
        var tokens:Array<Token> = [];
        
        // Handle operators for now
        while (!isEof()) {
            skipWhitespace();
            skipComments();
            if (isEof()) break;

            switch (current) {
                case '+':
                    tokens.push(new Token(TokenType.PLUS, current, line, column));
                    advance();
                case '-':
                    tokens.push(new Token(TokenType.MINUS, current, line, column));
                    advance();
                case '*':
                    tokens.push(new Token(TokenType.STAR, current, line, column));
                    advance();
                case '/':
                    tokens.push(new Token(TokenType.SLASH, current, line, column));
                    advance();
                case '(':
                    tokens.push(new Token(TokenType.LPAREN, current, line, column));
                    advance();
                case ')':
                    tokens.push(new Token(TokenType.RPAREN, current, line, column));
                    advance();
                case '[':
                    tokens.push(new Token(TokenType.LBRACK, current, line, column));
                    advance();
                case ']':
                    tokens.push(new Token(TokenType.RBRACK, current, line, column));
                    advance();
                case '{':
                    tokens.push(new Token(TokenType.LBRACE, current, line, column));
                    advance();
                case '}':
                    tokens.push(new Token(TokenType.RBRACE, current, line, column));
                    advance();
                case ';':
                    tokens.push(new Token(TokenType.SEMICOLON, current, line, column));
                    advance();
                case '=':
                    advance();
                    if (peek() == '=') {
                        tokens.push(new Token(TokenType.EQEQ, "==", line, column));
                        advance();
                    } else if (peek() == '>') {
                        tokens.push(new Token(TokenType.ARROW, "=>", line, column));
                        advance();
                    } else {
                        tokens.push(new Token(TokenType.EQUALS, current, line, column));
                    }
                case '>':
                    if (peek() == '=') {
                        tokens.push(new Token(TokenType.GTEQ, ">=", line, column));
                        advance();
                        advance();
                    } else {
                        tokens.push(new Token(TokenType.GT, current, line, column));
                        advance();
                    }
                case '<':
                    if (peek() == '=') {
                        tokens.push(new Token(TokenType.LTEQ, "<=", line, column));
                        advance();
                        advance();
                    } else {
                        tokens.push(new Token(TokenType.LT, current, line, column));
                        advance();
                    }
                case '!':
                    if (peek() == '=') {
                        tokens.push(new Token(TokenType.NOTEQ, "!=", line, column));
                        advance();
                        advance();
                    } else {
                        tokens.push(new Token(TokenType.BANG, current, line, column));
                        advance();
                    }
                case ',':
                    tokens.push(new Token(TokenType.COMMA, current, line, column));
                    advance();
                case '.':
                    tokens.push(new Token(TokenType.PERIOD, current, line, column));
                    advance();
                case '"':
                    // String literal
                    var start = position + 1;
                    advance();
                    while (!isEof() && current != '"') {
                        advance();
                    }
                    if (isEof()) throw 'Unterminated string literal at line ' + line + ', column ' + column;
                    var strValue = source.substring(start, position);
                    tokens.push(new Token(TokenType.STRING, strValue, line, column - (position - start + 1)));
                    advance(); // Skip closing quote
                default:
                    // handle identifiers, numbers, etc. here
                    if (~/[a-zA-Z_$$]/.match(current)) {
                        var start = position;
                        while (!isEof() && ~/[a-zA-Z0-9_$$]/.match(current)) {
                            advance();
                        }
                        var identifier = source.substring(start, position);
                        var type = if (isKeyword(identifier)) TokenType.KEYWORD else TokenType.IDENTIFIER;
                        tokens.push(new Token(type, identifier, line, column));
                    } else if (~/[0-9]/.match(current)) {
                        var start = position;
                        while (!isEof() && ~/[0-9]/.match(current)) {
                            advance();
                        }
                        if (current == '.') {
                            advance();
                            while (!isEof() && ~/[0-9]/.match(current)) {
                                advance();
                            }
                        }
                        var numberStr = source.substring(start, position);
                        tokens.push(new Token(TokenType.NUMBER, numberStr, line, column - (position - start)));
                    } else {
                        // Unknown character
                        throw 'Unknown character: ' + current + ' at line ' + line + ', column ' + column;
                    }
            }
        }
        return tokens;
    }

    function isKeyword(identifier:String):Bool {
        var keywords = ["print", "input", "let", "if", "then", "else", "while", "do", "end", "true", "false", "inc", "dec", "func", "return", "null", "for", "in", "as", 
                        "number", "string", "bool", "array", "map"];
        return keywords.indexOf(identifier.toLowerCase()) != -1;
    }
}