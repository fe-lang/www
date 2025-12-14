---
title: Dependencies
description: Adding and managing dependencies in Fe projects
---

Dependencies allow you to use code from other ingots in your project. Fe supports both local path dependencies and remote git dependencies.

## The [dependencies] Section

Add dependencies to your `fe.toml`:

```toml
[ingot]
name = "my_project"
version = "1.0.0"

[dependencies]
utils = "../shared/utils"
token_lib = { source = "https://github.com/example/token-lib.git", rev = "a1b2c3d4e5f6" }
```

## Local Path Dependencies

Reference ingots on your local filesystem:

### Simple Path Syntax

```toml
[dependencies]
my_lib = "../path/to/my_lib"
```

### Explicit Path Syntax

```toml
[dependencies]
my_lib = { path = "../path/to/my_lib" }
```

Both forms are equivalent. The path is relative to your project's `fe.toml`.

### Example: Monorepo Structure

```
my-workspace/
├── contracts/
│   ├── fe.toml
│   └── src/lib.fe
└── shared/
    ├── utils/
    │   ├── fe.toml
    │   └── src/lib.fe
    └── types/
        ├── fe.toml
        └── src/lib.fe
```

```toml
# contracts/fe.toml
[ingot]
name = "contracts"
version = "1.0.0"

[dependencies]
utils = "../shared/utils"
types = "../shared/types"
```

## Git Remote Dependencies

Pull ingots from git repositories:

```toml
[dependencies]
token_lib = { source = "https://github.com/example/token-lib.git", rev = "abc1234" }
```

### Required Fields

| Field | Description |
|-------|-------------|
| `source` | Git repository URL |
| `rev` | Git commit hash (full or abbreviated) |

**Note:** Only commit hashes are supported for `rev`. Tags and branch names are not allowed because Fe does not yet support lock files—pinning to exact commits ensures reproducible builds.

### Optional Fields

| Field | Description |
|-------|-------------|
| `path` | Subdirectory within the repository containing the ingot |

### Examples

Pin to a specific commit:

```toml
[dependencies]
lib = { source = "https://github.com/org/repo.git", rev = "a1b2c3d4" }
```

Use a subdirectory in the repository:

```toml
[dependencies]
contracts = { source = "https://github.com/org/monorepo.git", rev = "e7f8a9b0c1d2", path = "packages/contracts" }
```

## Using Dependencies

Once declared, import from dependencies using their name:

```fe
// Import from the 'utils' dependency
use utils::calculate_fee
use utils::SafeMath

// Import from the 'token_lib' dependency
use token_lib::ERC20
use token_lib::Transfer
```

The dependency name in `fe.toml` becomes the root of the import path.

## Dependency Names

The name you give a dependency determines its import path:

```toml
[dependencies]
# This ingot is imported as 'helpers'
helpers = "../some/path/to/utils"
```

```fe
// Import using the name 'helpers', not the directory name
use helpers::some_function
```

## Version Conflicts

If two dependencies require different versions of the same ingot, you may encounter conflicts. Strategies to resolve:

- Update dependencies to use compatible versions
- Use path dependencies to control exact versions
- Contact dependency maintainers about version compatibility

## Summary

| Dependency Type | Syntax |
|-----------------|--------|
| Local (simple) | `name = "path/to/ingot"` |
| Local (explicit) | `name = { path = "path/to/ingot" }` |
| Git remote | `name = { source = "url", rev = "ref" }` |
| Git with path | `name = { source = "url", rev = "ref", path = "subdir" }` |
