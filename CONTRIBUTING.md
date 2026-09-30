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

The guide targets Fe 26.4. All unignored `fe` blocks are checked with `fe check`; blocks containing `#[test]` are also executed with `fe test`. Standalone examples in `src/examples/` are included. Shell and TOML examples need separate verification.

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
store.balances.set(key: from, value: balance - amount)
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

The only stub traits are `Hashable`, `Printable`, `Readable`, and `Writable`. Opt in explicitly with `use _boilerplate::{Hashable, Printable}` for illustrative trait examples. Use real standard-library types and effects everywhere else; do not shadow them with mocks to make an outdated snippet compile.

`Address`, `StorageMap`, `Ctx`, `Log`, `Option<T>`, and `Result<E, T>` are supplied by the standard prelude. Other APIs need their actual imports. Runtime test blocks must be self-contained: the checker removes shared boilerplate before executing tests.

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
3. Fix errors against the target compiler; use hide directives for required context. Reserve `ignore` for explicitly explained non-executable or intentionally invalid examples.
4. Commit when all checks pass

## Reference Documentation

When writing new sections, consult existing documentation for patterns:

- `examples/erc20.md` - Canonical contract example with effects, messages, recv blocks
- `foundations/` - Core language concepts
- `effects/` - Effect system patterns

For language behavior not covered in docs, consult the [Fe compiler source](https://github.com/argotorg/fe).

## Updating the Fe Binary

Example validation uses the release in `.fe-version`. `scripts/fe` downloads the appropriate binary on first use and caches it in `bin/`. API generation uses the same release and a source checkout at its tag.

```bash
bash scripts/check-examples.sh
FE_BIN=/path/to/fe bash scripts/check-examples.sh
bash scripts/generate-docs.sh
```

To update the compiler, change `.fe-version`, run the full example checks and tests, update release-sensitive prose, and regenerate the API reference. Use `FE_VERSION=latest` to try the newest release without changing the pin. `FE_BIN` explicitly overrides binary selection; `GITHUB_TOKEN` can authenticate downloads. Pinned downloads never fall back to a different cached version.

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
