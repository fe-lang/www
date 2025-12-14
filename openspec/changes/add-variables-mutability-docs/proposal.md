# Change: Add Variables & Mutability Documentation

## Why
The Fe Guide needs comprehensive documentation on variable declaration and mutability. This is a foundational topic that developers need to understand before writing any Fe code. Variables and mutability are core concepts that affect how data flows through programs.

## What Changes
- Add complete documentation page at `src/content/docs/foundations/variables.md`
- Document `let` statement syntax with patterns, type annotations, and initializers
- Document `mut` keyword for mutable bindings
- Explain Fe's immutability-by-default philosophy
- Cover variable shadowing and scope
- Include practical examples

## Impact
- Affected specs: `documentation`
- Affected code: `src/content/docs/foundations/variables.md`
- No breaking changes - this is additive documentation
