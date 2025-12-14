# Tasks: Add Control Flow Documentation

## 1. Research
- [x] 1.1 Review Fe compiler source for control flow (`ast/stmt.rs`, `ast/expr.rs`)
- [x] 1.2 Verify if/else/match expression syntax
- [x] 1.3 Confirm loop syntax and control statements

## 2. Documentation Content
- [x] 2.1 Write Conditionals section:
  - `if` expressions
  - `else` branches
  - `else if` chaining
  - if as an expression (returns value)
- [x] 2.2 Write Pattern Matching section:
  - `match` expression syntax
  - Match arms with patterns
  - Enum variant matching
  - Struct pattern matching
  - Wildcard patterns
  - Exhaustiveness
- [x] 2.3 Write Loops section:
  - `for` loops with `in` keyword
  - Pattern binding in for loops
  - `while` loops with conditions
- [x] 2.4 Write Loop Control section:
  - `break` statement
  - `continue` statement
  - Combining break and continue
- [x] 2.5 Write Early Return section:
  - `return` with and without value
  - Return vs implicit return
- [x] 2.6 Add Summary table

## 3. Integration
- [x] 3.1 Ensure page follows Starlight/Astro conventions
- [x] 3.2 Add proper frontmatter (title, description)
- [x] 3.3 Verify sidebar entry exists in astro.config.mjs
- [x] 3.4 Build and preview to verify rendering

## 4. Review
- [x] 4.1 Cross-reference with Fe compiler to ensure accuracy
- [ ] 4.2 Verify code examples compile (requires Fe toolchain - skipped)
