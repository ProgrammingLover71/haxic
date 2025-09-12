# Haxic

Haxic is a modernized take on BASIC, written in **Haxe**. It mixes the simplicity of retro BASIC with clean, modern features like block scoping, `let` bindings, and structured control flow. Haxic also aims to be an easy-to-learn dynamic language that also has potential at large scales.

## ✨ Features

* **Basic statements**: `print`, `input`, `let`
* **Arithmetic expressions**: `+`, `-`, `*`, `/`
* **Unary operators**: `-x`, `!x`
* **Comparisons**: `<`, `<=`, `>`, `>=`, `==`, `!=`
* **Conditionals**: `if ... then ... else ... end`
* **Loops**:
```haxic
let x = 0;
while x < 200 do
    print x;
    inc x;
end
```

* **Increment/Decrement**: `inc x;`, `dec x;`

## 📝 Example Programs

### Hello World

```haxic
print "Hello, world!";
```

### Input & Math

```haxic
input x;
print x + 10;
```

### If/Else

```haxic
let score = 75;
if score >= 50 then
  print "You passed!";
else
  print "Try again.";
end
```

### While Loop + Increment

```haxic
let i = 0;
while i < 5 do
  print i;
  inc i;
end
```

## 📖 Syntax Cheatsheet

### Statements

`print <expr>;`: Prints an expression, adding a newline at the end. <br>
`input <var>;`: Takes an input and stores the value in the target variable, converting the type to a number if possible. <br>
`let <var> (, <var>)* (= <expr>)?;`: Assigns a value to one or more variables. <br>
`inc <var>;`: Increments the value of a variable by 1. (Gets parsed as `let <var> = <var> + 1`) <br>
`dec <var>;`: Decrements the value of a variable by 1. (Gets parsed as `let <var> = <var> - 1`) <br>

`if <expr> then <statements> (else <statements>)? end`: Represents an `if` statement. The `else` clause is optional. <br>
`while <expr> do <statements> end`: Represents a `while` statement. <br>

### Expressions
The expression syntax is basic (pun intended), providing basic operations like `+`, `-`, `*`, `/` (float division), `-` (unary), `!`, and comparisons, using the PEMDAS principle:
```
High precedence -------> Low precedence
unary -       *       +       ==
unary !       /       -       !=
(...)                         >=
                              <=
                              >
                              <
```


## 🚀 Roadmap

* Functions (`def`, return values)
* Lists & `for`/`for-in` loops
* Modules

## 🔧 Development

Clone the repo and build (from outside `src`):

```bash
haxe -main src/Main.hx -cpp out/cpp/
```
or if you want a Python build:
```bash
haxe -main src/Main.hx -py out/py/
```
*Note: The Python version is faster, I have absolutely no idea why, but it is apparently.*

Run a sample program:

```bash
haxic examples/loops.haxic
```
or run Haxic in *REPL mode*:
```bash
haxic
```


## 📜 License

MIT License — do whatever you like, just give credit if you share or modify.
