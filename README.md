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
   * [Build & Run](#build--run)
6. [Usage](#usage)

   * [Writing BASIC code](#writing-basic-code)
   * [Examples](#examples)
7. [Folder Structure](#folder-structure)
8. [Contributing](#contributing)
9. [License](#license)
10. [Roadmap](#roadmap)
11. [Acknowledgments](#acknowledgments)

---

## Introduction

Haxic is a project that implements a modern reinterpretation of the BASIC programming language using **Haxe**. It aims to bring together simplicity, nostalgia, and modern programming conveniences. Users can write BASIC-style code, which Haxic will process (interpret / compile / transpile) it using Haxe tooling. ([github.com](https://github.com/ProgrammingLover71/haxic))

---

## Features

* A heavily BASIC-inspired syntax for writing programs
* Parsing and interpreting or compiling that code using Haxe
* Cross-platform support via Haxe targets
* Example programs shipped with the repo for demonstration
* Simple command-line interface / tool to execute BASIC scripts
* (Optionally) ability to transpile Haxic code to another target or generate Haxe / JavaScript / etc.

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
* Implemented in Haxe; code is parsed and either interpreted or compiled to a target backend

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
./build.bat   # on Windows
```

### Build & Run

```bash
# Run the interpreter
haxic <path-to-file>

# Or, via Haxe directly
haxe -main src/Main.x --interp -run <your-basic-file.bas>
```

---

## Usage

### Writing Haxic code

Write `.hxc` files using BASIC-style syntax. Example:

```haxic
print "Hello!";
input a as num;
if a > 10 then
    print "A is large";
else
    print"A is small";
end
```

### Examples

See the `examples/` folder for sample programs.

---

## Folder Structure

| Path             | Description                                  |
| ---------------- | -------------------------------------------- |
| `src/`           | Main source code (parser, interpreter, etc.) |
| `examples/`      | Example BASIC programs                       |
| `out/py/`        | Output directory (Python target, etc.)       |
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
* More target backends (JavaScript, Python, etc.)
* Optimizations for compilation
* Packaging & distribution

---

## Acknowledgments

* The Haxe community
* Feedback from any contributors & testers
