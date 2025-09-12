package src;

class Main {
    static function main() {
        // Check command line argument count
        if (Sys.args().length > 1) {
            Utils.print("Usage: haxic [<file>]");
            return;
        }
        // If a filename is provided, run the file
        if (Sys.args().length == 1) {
            // Run a file
            var filename = Sys.args()[0];
            var content = sys.io.File.getContent(filename);
            var lexer = new Lexer(content);
            var tokens = lexer.tokenize();
            var parser = new Parser(tokens);
            var ast = parser.parse();
            var interpreter = new InterpBknd();
            interpreter.visit(ast);
            return;
        }
        // Fall back to REPL mode
        // Create the interpreter here because we need the environment to persist across the entire session
        var interpreter = new InterpBknd();
        while (true) {
            // Read the input
            Utils.print("haxic> ", false);
            Sys.stdout().flush();
            var line = Sys.stdin().readLine();
            if (line == null) continue;
            // Lex, parse, and interpret
            var lexer = new Lexer(line);
            var tokens = lexer.tokenize();
            var parser = new Parser(tokens);
            var ast = parser.parse();
            interpreter.visit(ast);
        }
    }
}