# Haxic

> *A modern take on BASIC written in Haxe* ([github.com](https://github.com/ProgrammingLover71/haxic))

---

## Table of Contents

1. [Introduction](#introduction)
2. [Features](#features)
3. [Motivation](#motivation)
4. [Architecture & Design](#architecture--design)
5. [Getting Started](#getting-started)

   * [Prerequisites](#prerequisites)
   * [Installation](#installation)
   * [Running files](#running-files)
6. [Usage](#usage)

   * [Writing code in Haxic](#writing-code-in-haxic)
   * [Examples](#examples)
7. [Folder Structure](#folder-structure)
8. [Contributing](#contributing)
9. [License](#license)
10. [Roadmap](#roadmap)
11. [Acknowledgments](#acknowledgments)

---

## Introduction

Haxic is a project that implements a modern reinterpretation of the BASIC programming language using *Haxe*. It aims to bring together simplicity, nostalgia, and modern programming conveniences. Users can write code in a simple BASIC-inspired syntax, which Haxic will process (interpret / compile / transpile) it using Haxe tooling. ([github.com](https://github.com/ProgrammingLover71/haxic))

---

## Features

* A mainly BASIC-inspired syntax for writing programs
* Modern syntax features, such as arrays, maps, lambda functions (function expressions) ans closures
* Parsing and interpreting or compiling that code using Haxe
* Cross-platform support via compilation targets (the Haxic compiler is WIP)
* Example programs shipped with the repo for demonstration
* A simple, straightforward REPL and a way to execute scripts

---

## Motivation

Why build Haxic?

* To revive and enjoy the simplicity of BASIC-like syntax, but on modern platforms
* To leverage Haxe’s cross-platform capabilities so that Haxic programs can run in many environments
* To learn & experiment with building interpreters / compilers in Haxe
* To provide a lightweight educational tool for learning programming / language design

---

## Architecture & Design

* **Source code** is in `src/`
* **Examples** are in `examples/`
* Output or build artifacts may go into `out/` (e.g. `out/py`)
* A build script (`build.bat`) is present for Windows users
* Implemented in Haxe; the source code is precompiled to Python/C++

---

## Getting Started

### Prerequisites

* Haxe (latest stable version recommended)
* On Windows: ability to run `.bat` scripts

### Installation

```bash
# Clone the repo
git clone https://github.com/ProgrammingLover71/haxic.git
cd haxic

# Build / compile
# On Windows:
./build.bat

# On Unix systems
haxe -main src/Main.hx -py out/py/haxic.py -D release -D analyzer-optimize
haxe -main src/Main.hx -cpp out/cpp -D release -D analyzer-optimize
```

### Running files

Haxic has a REPL and a compiler/interpreter, both of which can be run as follows:

```bash
# Python build:
py out/py/haxic.py <file> # Omit file for REPL

# C++ build:
out/cpp/haxic <file> # Omit file for REPL
```

---

## Usage

### Writing code in Haxic

Write `.hxc` files using BASIC-style syntax. Example:

```haxic
print "Hello!";
input a;
if a > 10 then
    print "A is large";
else
    print"A is small";
end
```

### Examples

See the `examples/` folder for sample programs. These programs also act as language feature tests.

---

## Folder Structure

| Path             | Description                                  |
| ---------------- | -------------------------------------------- |
| `src/`           | Main source code (parser, interpreter, etc.) |
| `examples/`      | Example Haxic programs                       |
| `out/`           | Output directories (Python, C++, etc.)       |
| `build.bat`      | Windows build script                         |
| `.gitattributes` | Git settings (line endings, etc.)            |
| `LICENSE`        | Project license (MIT)                        |

---

## Contributing

1. Fork the project
2. Create a branch for your feature / bugfix
3. Add tests or examples if possible
4. Ensure your code works across targets
5. Submit a pull request with a clear description

---

## License

Haxic is licensed under the **MIT License**.

---

## Roadmap

* Improved error messages
* More target backends for the compiler/interpreter (JavaScript, etc.)
* Optimizations for compilation
* Packaging & distribution
* Modules
* OOP Features
* A larger standard library
* Haxic compiler

---

## Acknowledgments

* The Haxe community
* Feedback from any contributors & testers
