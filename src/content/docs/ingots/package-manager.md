---
title: The Package Manager
description: Using Fe's built-in package manager to manage projects and dependencies
---

Fe includes built-in package management through the `fe` command-line tool. This handles project creation, building, and dependency resolution.

## Core Commands

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

When you run `fe build`, the compiler produces:

- Compiled contract artifacts
- ABI definitions for contract interfaces
- Yul intermediate representation (optional)

Output location and format depend on your build configuration.

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

See [Dependencies](/www/ingots/dependencies/) to learn how to add external ingots to your project.
