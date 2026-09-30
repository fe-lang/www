---
title: The Package Manager
description: Using Fe's built-in package manager to manage projects and dependencies
---

Fe includes built-in package management through the `fe` command-line tool. This handles project creation, building, and dependency resolution.

## Core Commands

### Creating Projects

```bash
fe new my_project
cd my_project
fe test
```

`fe new` creates `fe.toml` and a starter `src/lib.fe`. Use `fe new --workspace my_workspace` to create a workspace root instead.

### Building Projects

Compile your Fe project:

```bash
fe build
```

This compiles all source files in `src/` and resolves dependencies defined in `fe.toml`.

### Checking Code

Verify your code compiles without producing output:

```bash
fe check
```

Useful for quick validation during development.

## Dependency Resolution

When you build a project, the Fe compiler:

1. Reads `fe.toml` to find dependencies
2. Resolves local path dependencies from the filesystem
3. Fetches git dependencies from remote repositories
4. Compiles dependencies before your project
5. Makes dependency exports available for import

## Workflow

A typical development workflow:

1. **Create project structure** with `fe.toml` and `src/lib.fe`
2. **Add dependencies** to `fe.toml` as needed
3. **Write code** in `src/` directory
4. **Build** with `fe build` to compile and check for errors
5. **Iterate** on your code

## Build Output

Fe uses the Sonatina backend. By default, `fe build` writes creation bytecode, runtime bytecode, and ABI JSON to the project's `out/` directory. Select artifacts explicitly with `--emit`:

```bash
fe build --emit abi,metadata
fe build --contract Counter --out-dir build
fe build -O 2
```

Optimization defaults to `1`; `0`, `1`, `2`, and `s` are accepted. Use `fe build --help` for the complete artifact list.

### Rebuilding from Metadata

Fe can reconstruct a build from the self-contained recompilation input emitted as `<Contract>.metadata.json`:

```bash
fe build --emit metadata
fe build --from-metadata out/Counter.metadata.json --out-dir rebuilt
```

This uses the recorded project, target contract, and optimization settings. Use the recorded compiler version for reproducibility; a version mismatch only warns. An explicit optimization override can change the bytecode. `--from-metadata -` reads JSON from standard input.

## Formatting and Dependencies

```bash
fe fmt
fe fmt --check
fe tree
```

`fe fmt --check` reports formatting differences without rewriting files. `fe tree` shows dependency resolution. Git dependencies are fetched automatically when you build or check. There is no central package registry: ingots are shared as local paths or git repositories (see [Publishing](/ingots/publishing/)).

## Error Messages

The Fe compiler provides helpful error messages:

```
error: Cannot find value `undefined_var` in this scope
  --> src/lib.fe:10:5
   |
10 |     undefined_var
   |     ^^^^^^^^^^^^^ not found in this scope
```

Use these messages to locate and fix issues in your code.

## Next Steps

See [Dependencies](/ingots/dependencies/) to learn how to add external ingots to your project.

## Experimental Native Executables

The compiler also has an experimental native backend for programs with `pub fn main() -> i32`, on x86-64 Linux and AArch64 macOS. Fe 26.4 supports standalone files and whole workspaces, including dependencies. It requires a compiler built with the `cranelift` feature:

```bash
# Run in the compiler source checkout
cargo build --release -p fe --features cranelift
./target/release/fe build --backend native hello.fe
```

This is separate from deploying EVM contracts. Native builds require the additional compiler feature; `fe test --backend native` executes native tests. `std::io` provides host character I/O, and `std::native` includes checked process-argument access through `Args`, process CPU timing, and an explicitly owned `ByteBuffer` with fallible growth and explicit `release`.
