# Change: Add Operators & Expressions Documentation

## Why
Operators and expressions are fundamental to writing Fe code. The guide needs comprehensive documentation covering all operator categories (arithmetic, comparison, logical, bitwise, unary) and expression types (literals, blocks, function calls, field access, indexing, etc.).

## What Changes
- Add complete documentation page at `src/content/docs/foundations/operators.md`
- Document arithmetic operators: `+`, `-`, `*`, `/`, `%`, `**` (power)
- Document comparison operators: `==`, `!=`, `<`, `<=`, `>`, `>=`
- Document logical operators: `&&`, `||`, `!`
- Document bitwise operators: `&`, `|`, `^`, `~`, `<<`, `>>`
- Document unary operators: `+`, `-`, `!`, `~`
- Document assignment and augmented assignment: `=`, `+=`, `-=`, etc.
- Document expression types: blocks, function calls, method calls, field access, indexing, tuples, arrays, if-else, match

## Impact
- Affected specs: `documentation`
- Affected code: `src/content/docs/foundations/operators.md`
- No breaking changes - this is additive documentation
