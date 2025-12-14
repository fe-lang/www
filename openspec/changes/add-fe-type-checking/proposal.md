# Change: Add Fe Type Checking for Documentation Examples

## Why

Code examples in documentation can drift out of sync with the actual Fe language as it evolves. Currently, there's no automated verification that code examples compile correctly. This leads to:
- Broken examples frustrating learners
- Outdated syntax going unnoticed
- No confidence that documentation reflects working code

## What Changes

### 1. Fe Binary Distribution
- Commit a pre-built `fe` binary for Linux x86_64 to the repository
- Store in `bin/fe-linux-x86_64` (or use Git LFS for cleaner history)
- Add wrapper script `scripts/fe` that selects the appropriate binary (future-proofed for multi-platform)

### 2. Code Block Extraction System
- Script to extract code blocks from markdown files
- Support two types of code blocks:
  - ` ```fe ` - Complete, self-contained examples (must compile)
  - ` ```fe ignore ` - Snippets for illustration only (skipped)
- Extract to temporary `.fe` files preserving source location for error reporting

### 3. Type Checking Infrastructure
- `scripts/check-examples.sh` - Main entry point for checking all examples
- Extracts code blocks, runs `fe check`, reports errors with source locations
- Exit code indicates pass/fail for CI integration

### 4. CI Integration
- GitHub Action runs on PRs and pushes to main
- Fails PR if any ` ```fe ` block doesn't compile
- Clear error messages pointing to the markdown file and line

### 5. Local Developer Workflow
- `npm run check:examples` - Run type checking locally
- Works on Linux directly, other platforms show helpful skip message
- Fast feedback during documentation writing

## Code Block Strategy

### Self-Contained Examples (checked)
```fe
// This compiles as-is
struct Point {
    x: u256,
    y: u256,
}
```

### Snippets (not checked)
```fe ignore
// This is illustrative, missing context
store.balances[from] -= amount
```

### Wrapper Templates (future enhancement)
For snippets that should be checked but need context, we could support:
```fe wrap=function
// Wrapped in: fn example() { ... }
let x = 10
let y = x + 5
```

## Impact

- Affected specs: New tooling capability
- Affected code:
  - New `bin/` directory with fe binary
  - New `scripts/` directory with checking scripts
  - New GitHub Action workflow
  - Markdown files may need `ignore` annotations on snippets
- **BREAKING**: Existing broken examples will be surfaced and need fixing

## Rollout Strategy

### Phase 1: Self-Contained Examples Only
- Start with `src/content/docs/examples/` directory
- These are complete, working programs (ERC20, etc.)
- Establishes the infrastructure

### Phase 2: Expand to All Documentation
- Audit all ` ```fe ` blocks across documentation
- Add `ignore` annotation to intentional snippets
- Fix any broken complete examples

### Phase 3: Snippet Wrapper Templates (Optional)
- Add wrapper template support for common patterns
- Allows more snippets to be type-checked with minimal boilerplate
