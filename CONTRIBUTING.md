# Contributing to The Fe Guide

## Code Examples

The documentation includes Fe code examples that are type-checked to ensure they remain valid as the language evolves.

### Code Block Conventions

Use the following markdown annotations for Fe code blocks:

**Complete examples** (type-checked):
```markdown
```fe
// This code must pass `fe check`
pub contract Example {
    // ...
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

### Running the Type Checker

Check all documentation examples:
```bash
npm run check:examples
```

Check with verbose output:
```bash
npm run check:examples:verbose
```

Check a specific file:
```bash
npm run check:examples -- src/content/docs/examples/erc20.md
```

### Adding New Examples

1. **Complete examples** in `src/content/docs/examples/` should use ` ```fe ` and include all necessary type definitions (see ERC20 example for reference)

2. **Illustrative snippets** throughout the documentation should use ` ```fe ignore ` since they are not complete programs

3. Run `npm run check:examples` before committing to verify all examples pass

### Updating the Fe Binary

The Fe binary is stored at `bin/fe-linux-x86_64`. To update it:

1. Build Fe from source or obtain a new binary
2. Copy to `bin/fe-linux-x86_64`
3. Ensure it's executable: `chmod +x bin/fe-linux-x86_64`
4. Run `npm run check:examples` to verify compatibility
5. Commit the updated binary

Note: Only Linux x86_64 is currently supported for local checking. CI runs on Linux.

### CI Integration

The type checker runs automatically on:
- Pull requests to `main`
- Pushes to `main`

If the check fails, the PR/build will be marked as failed with error details showing the file and line number.
