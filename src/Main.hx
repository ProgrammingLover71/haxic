package src;

import sys.io.File;
import src.compiler.PyCompiler;

class Main {
    static function main() {
        if (Sys.args().length >= 1) {
            // Get the filename and read its content
            var filename = Sys.args()[0];
            var content = sys.io.File.getContent(filename);
            // Lex and parse
            var lexer = new Lexer(content);
            var tokens = lexer.tokenize();
            var parser = new Parser(tokens);
            var ast = parser.parse();
            if (Sys.args().contains("-py")) {
                var out_idx = Sys.args().indexOf("-py") + 1;
                var filename = Sys.args()[out_idx];
                var out_f = File.write(filename);
                // Compile the code
                var codegen = new PyCompiler();
                codegen.visit(ast);
                out_f.writeString(codegen.getCode());
                out_f.close();
            } else {
                var interp = new Interpreter();
                interp.visit(ast);
            }
            return;
        }
        // Fall back to REPL mode
        // Create the interpreter here because we need the environment to persist across the entire session
        var interpreter = new Interpreter();
        Utils.print("Haxic REPL v1.1, Haxic version 1.0 beta 3. Type Ctrl+C to exit.");
        while (true) {
            // Read the input
            Utils.print("haxic >> ", false);
            Sys.stdout().flush();
            var line = Sys.stdin().readLine();
            if (line == null) continue;
            // Lex, parse, and interpret
            try {
                var lexer = new Lexer(line);
                var tokens = lexer.tokenize();
                var parser = new Parser(tokens);
                var ast = parser.parse();
                var compiler = new PyCompiler();
                interpreter.visit(ast);
            } catch (err:haxe.Exception) {
                Utils.print("Error: " + err.details());
            }
        }
    }
}