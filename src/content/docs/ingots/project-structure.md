---
title: Project Structure
description: How to structure a Fe project with fe.toml and source files
---

Every Fe project follows a standard structure with a manifest file and source directory.

## Directory Layout

A minimal Fe project looks like this:

```
my-project/
├── fe.toml
└── src/
    └── lib.fe
```

As your project grows:

```
my-project/
├── fe.toml
└── src/
    ├── lib.fe           # Entrypoint
    ├── token.fe         # Additional modules
    ├── utils.fe
    └── messages/
        ├── mod.fe       # Submodule entrypoint
        └── transfer.fe
```

## The fe.toml Manifest

The `fe.toml` file defines your ingot's metadata and dependencies:

```toml
[ingot]
name = "my_project"
version = "1.0.0"

[dependencies]
# Dependencies go here
```

### The [ingot] Section

Every `fe.toml` requires an `[ingot]` section with:

| Field | Required | Description |
|-------|----------|-------------|
| `name` | Yes | The ingot name (used for imports) |
| `version` | Yes | Semantic version string |

```toml
[ingot]
name = "token_library"
version = "0.1.0"
```

The name must be a valid identifier. Use underscores instead of hyphens:

```toml
# Good
name = "my_token"

# Bad - hyphens not allowed
name = "my-token"
```

## The src/ Directory

All Fe source files live in the `src/` directory. The compiler discovers files matching the pattern `src/**/*.fe`.

### The Entrypoint: src/lib.fe

Every ingot must have a `src/lib.fe` file. This is the entrypoint that defines what the ingot exports:

```fe ignore
// src/lib.fe

// Re-export items from other modules
pub use token::Token
pub use messages::Transfer

// Define items directly
pub struct Config {
    pub max_supply: u256
}
```

### Organizing with Modules

Split code across multiple files for better organization:

```fe ignore
// src/lib.fe
pub use token::Token
pub use utils::calculate_fee

// src/token.fe
pub contract Token {
    // ...
}

// src/utils.fe
pub fn calculate_fee(amount: u256) -> u256 {
    amount / 100
}
```

### Submodules

Create subdirectories with `mod.fe` files for deeper organization:

```
src/
├── lib.fe
└── messages/
    ├── mod.fe        # Required for submodule
    ├── transfer.fe
    └── approval.fe
```

```fe ignore
// src/messages/mod.fe
pub use transfer::Transfer
pub use approval::Approval
```

## Creating a New Project

To create a new Fe project:

1. Create the project directory:
   ```bash
   mkdir my_project
   cd my_project
   ```

2. Create `fe.toml`:
   ```toml
   [ingot]
   name = "my_project"
   version = "0.1.0"
   ```

3. Create the source directory and entrypoint:
   ```bash
   mkdir src
   touch src/lib.fe
   ```

4. Add your code to `src/lib.fe`:
   ```fe
   pub contract MyContract {
       // ...
   }
   ```

## Summary

| Component | Purpose |
|-----------|---------|
| `fe.toml` | Manifest with name, version, dependencies |
| `[ingot]` | Required section with `name` and `version` |
| `src/` | Contains all source files |
| `src/lib.fe` | Required entrypoint |
| `src/**/*.fe` | Additional source files |
