---
title: Publishing Ingots
description: How to publish and share your Fe ingots with the community
---

Sharing your Fe ingots allows others to build on your work. This guide covers best practices for preparing and publishing ingots.

## Preparing for Publication

Before publishing, ensure your ingot is ready:

### 1. Complete fe.toml Metadata

```toml
[ingot]
name = "my_awesome_lib"
version = "1.0.0"
```

Use semantic versioning:
- **Major** (1.0.0 → 2.0.0): Breaking changes
- **Minor** (1.0.0 → 1.1.0): New features, backwards compatible
- **Patch** (1.0.0 → 1.0.1): Bug fixes, backwards compatible

### 2. Clean Public API

Export only what users need in `src/lib.fe`:

```fe
// Export public items
pub use token::Token
pub use token::Transfer
pub use token::Approval

// Internal helpers stay private (no pub)
use internal::validate_amount
```

### 3. Document Your Code

Add comments explaining public items:

```fe
/// A standard ERC20 token implementation.
///
/// Supports transfer, approve, and transferFrom operations.
pub contract Token {
    // ...
}

/// Transfer tokens from the caller to a recipient.
///
/// Emits a Transfer event on success.
pub fn transfer(to: address, amount: u256) {
    // ...
}
```

## Publishing via Git

The most common way to share ingots is through git repositories:

### 1. Create a Repository

Host your ingot on GitHub, GitLab, or another git host:

```bash
git init
git add .
git commit -m "Initial release v1.0.0"
git remote add origin https://github.com/you/my-ingot.git
git push -u origin main
```

### 2. Share the Dependency Line

After pushing, get the commit hash and share it with users:

```bash
git rev-parse HEAD
# Output: a1b2c3d4e5f6789...
```

Tell users how to add your ingot:

```toml
[dependencies]
my_awesome_lib = { source = "https://github.com/you/my-ingot.git", rev = "a1b2c3d4" }
```

**Note:** Fe requires commit hashes for `rev` (not tags or branches) to ensure reproducible builds without lock files.

## Repository Structure

A well-organized published ingot:

```
my-ingot/
├── fe.toml
├── README.md           # Usage instructions
├── LICENSE             # License file
└── src/
    ├── lib.fe          # Public exports
    └── ...             # Implementation
```

## Versioning Guidelines

### When to Bump Versions

| Change Type | Version Bump | Example |
|-------------|--------------|---------|
| Bug fix | Patch | 1.0.0 → 1.0.1 |
| New feature (compatible) | Minor | 1.0.0 → 1.1.0 |
| Breaking change | Major | 1.0.0 → 2.0.0 |

### What Counts as Breaking

- Removing public items
- Changing function signatures
- Changing struct field types
- Renaming public items

### What's Not Breaking

- Adding new public items
- Adding optional parameters with defaults
- Internal implementation changes
- Performance improvements

## Best Practices

### Use Descriptive Names

Choose a name that clearly indicates what your ingot does:

```toml
# Good
name = "erc20_token"
name = "access_control"

# Less clear
name = "utils"
name = "helpers"
```

### Pin Your Dependencies

When publishing, pin dependencies to specific versions:

```toml
[dependencies]
# Good - pinned to specific commit
base_lib = { source = "https://github.com/org/base.git", rev = "abc1234" }

# Risky - branch can change
base_lib = { source = "https://github.com/org/base.git", rev = "main" }
```

### Include Examples

Show users how to use your ingot in your README:

```markdown
## Usage

Add to your `fe.toml`:

\`\`\`toml
[dependencies]
my_lib = { source = "https://github.com/you/my-lib.git", rev = "a1b2c3d4" }
\`\`\`

Then import and use:

\`\`\`fe
use my_lib::Token

contract MyContract {
    // ...
}
\`\`\`
```

## Summary

| Step | Action |
|------|--------|
| Prepare | Complete metadata, clean API, add docs |
| Version | Use semantic versioning |
| Publish | Push to git, tag releases |
| Share | Provide dependency line for users |
