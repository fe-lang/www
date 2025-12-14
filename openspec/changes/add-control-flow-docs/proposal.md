# Change: Add Control Flow Documentation

## Why
Control flow constructs are essential for writing any meaningful program. The guide needs comprehensive documentation covering conditionals (if/else), pattern matching (match), loops (for/while), and loop control statements (break/continue/return).

## What Changes
- Add complete documentation page at `src/content/docs/foundations/control-flow.md`
- Document `if`/`else`/`else if` expressions (note: expressions that return values)
- Document `match` expressions with pattern matching
- Document `for` loops with pattern iteration
- Document `while` loops with conditions
- Document loop control: `break`, `continue`
- Document early return with `return`

## Impact
- Affected specs: `documentation`
- Affected code: `src/content/docs/foundations/control-flow.md`
- No breaking changes - this is additive documentation
