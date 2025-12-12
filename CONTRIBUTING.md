# Contributing to The Fe Guide

Thank you for contributing to Fe's documentation! This guide covers conventions for writing documentation, validating code examples, and customizing the site.

## Writing Documentation

Documentation files are Markdown (`.md`) located in `src/content/docs/`. Each file requires frontmatter:

```markdown
---
title: Page Title
description: Brief description for SEO and previews
---

Your content here...
```

## Code Examples

The documentation includes Fe code examples that are type-checked to ensure they remain valid as the language evolves.

### Code Block Conventions

Use the following markdown annotations for Fe code blocks:

**Complete examples** (type-checked):
```markdown
```fe
// This code must pass `fe check`
fn add(a: u256, b: u256) -> u256 {
    a + b
}
```(end)
```

**Snippets** (not type-checked):
```markdown
```fe ignore
// This is illustrative, may be incomplete
store.balances[from] -= amount
```(end)
```

Use `fe ignore` for:
- Error demonstrations
- Pseudocode or incomplete snippets
- Examples of syntax that intentionally doesn't compile
- Future features not yet implemented

### Hide Directives

Use hide directives to include necessary boilerplate without cluttering the visible example:

```markdown
```fe
//<hide>
use core::StorageMap

pub struct TokenStorage {
    pub balances: StorageMap<u256, u256>,
}
//</hide>
fn get_balance(account: u256) -> u256 uses (store: TokenStorage) {
    store.balances.get(account)
}
```(end)
```

Hidden sections are removed from the rendered docs but kept for `fe check`, so you can include minimal scaffolding without showing it to readers.

**Common patterns:**

Wrapping in a function:
```markdown
```fe
//<hide>
fn example() {
//</hide>
let x: u256 = 42
let y = x + 1
//<hide>
let _ = y
}
//</hide>
```(end)
```

### The Boilerplate Module

The file `scripts/boilerplate.fe` is automatically prepended to all Fe code blocks during type checking. It provides a `_boilerplate` module with common stubs that snippets can import:

**Available imports:**

| Category | Items |
|----------|-------|
| **Storage** | `StorageMap` (re-exported from core), `Map` (non-storage), `Storage` |
| **Effects** | `Log`, `Ctx` (execution context with caller, block info, etc.) |
| **Types** | `Address`, `Option<T>`, `Result<T, E>` |
| **Intrinsics** | `caller`, `revert`, `keccak`, `sload`, `sstore` (from core) |
| **Functions** | `assert`, `self_address`, `block_number`, `block_timestamp`, `keccak256`, `sha256`, etc. |
| **Traits** | `Hashable`, `Printable`, `Clone`, `Default`, `Readable`, `Writable`, `Storable` |

**Usage:**
```markdown
```fe
//<hide>
use _boilerplate::{Map, caller, Address}
//</hide>
// Your visible code here
```(end)
```

This allows documentation to show focused examples without repeating type definitions that readers don't need to see.

Suppressing unused warnings:
```markdown
```fe
//<hide>
let _ = unused_variable
//</hide>
```(end)
```

## Running the Type Checker

Check all documentation examples:
```bash
bash scripts/check-examples.sh
```

Check a specific Fe file:
```bash
./scripts/fe check path/to/file.fe
```

The output shows:
- Total blocks checked
- Passed/failed counts
- Error details with file and line numbers

### Validation Workflow

1. Write or modify documentation
2. Run `bash scripts/check-examples.sh`
3. Fix any errors (add hide directives, fix syntax, or mark as `ignore`)
4. Commit when all checks pass

## Reference Documentation

When writing new sections, consult existing documentation for patterns:

- `examples/erc20.md` - Canonical contract example with effects, messages, recv blocks
- `foundations/` - Core language concepts
- `effects/` - Effect system patterns

For language behavior not covered in docs, consult the [Fe compiler source](https://github.com/fe-lang/fe).

## Updating the Fe Binary

The Fe binary is stored in `bin/`. A platform-detecting wrapper is at `scripts/fe`.

To update the compiler:

1. Build Fe from source or obtain a new binary
2. Copy to `bin/fe-linux-x86_64` (or appropriate platform)
3. Ensure it's executable: `chmod +x bin/fe-linux-x86_64`
4. Run `bash scripts/check-examples.sh` to verify compatibility
5. Commit the updated binary

Note: Only Linux x86_64 is currently supported for local checking. CI runs on Linux.

## Site Customization

The Fe Guide is built with [Starlight](https://starlight.astro.build/), a documentation theme for [Astro](https://astro.build).

### Configuration

- `astro.config.mjs` - Site configuration, sidebar navigation
- `src/styles/custom.css` - Custom styling
- `public/` - Static assets (favicon, images)

### Adding Pages

1. Create a `.md` file in `src/content/docs/`
2. Add frontmatter with `title` and `description`
3. Add to sidebar in `astro.config.mjs` if needed

### Sidebar Navigation

Edit `astro.config.mjs` to modify the sidebar:

```javascript
sidebar: [
  {
    label: 'Section Name',
    items: [
      { label: 'Page Title', slug: 'path/to/page' },
    ],
  },
],
```

### Learn More

- [Starlight Documentation](https://starlight.astro.build/)
- [Astro Documentation](https://docs.astro.build)
- [Astro Discord](https://astro.build/chat)

## CI Integration

The type checker runs automatically on:
- Pull requests to `main`
- Pushes to `main`

If the check fails, the PR/build will be marked as failed with error details showing the file and line number.

## Pull Request Guidelines

1. Ensure all code examples pass validation
2. Preview changes locally with `npm run dev`
3. Build successfully with `npm run build`
4. Keep commits focused and descriptive
