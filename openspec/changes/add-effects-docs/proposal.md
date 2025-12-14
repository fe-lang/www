# Change: Add Effects & the uses Clause Documentation

## Why
Effects are a core feature of Fe that provide capability-based access control for functions. They track what external resources a function can access and distinguish between read-only and mutable access. This is particularly important for smart contract security. Developers need comprehensive documentation to understand and use this system effectively.

## What Changes
- Complete documentation for `src/content/docs/effects/what-are-effects.md`
- Complete documentation for `src/content/docs/effects/declaring-effects.md`
- Complete documentation for `src/content/docs/effects/mutability.md`
- Complete documentation for `src/content/docs/effects/propagation.md`
- Complete documentation for `src/content/docs/effects/built-in.md`
- Complete documentation for `src/content/docs/effects/storage.md`
- Complete documentation for `src/content/docs/effects/why-effects-matter.md`

### What Are Effects?
- Definition of effects as capabilities
- Purpose: tracking resource access
- High-level overview of the system
- Comparison to other capability systems

### Declaring Effects
- The `uses` keyword syntax
- Single effect: `fn foo() uses Effect { }`
- Named effects: `fn foo() uses e: Effect { }`
- Multiple effects: `fn foo() uses (Effect1, Effect2) { }`
- Effects on contracts

### Mutability in Effects
- Immutable effects: `uses Effect`
- Mutable effects: `uses mut Effect`
- Mutability matching rules
- When to use mutable vs immutable

### Effect Propagation
- How effects flow through function calls
- Caller must provide required effects
- The `with` expression for providing effects
- Effect scoping rules

### Built-in Effects
- Effects are user-defined types/traits
- Common effect patterns
- Context effects

### Storage as Effects
- Contract fields as effect sources
- Accessing storage through effects
- Field-based effect derivation

### Why Effects Matter
- Security benefits for smart contracts
- Compile-time resource tracking
- Explicit capability requirements
- Preventing unauthorized access

## Impact
- Affected specs: `documentation`
- Affected code: All files in `src/content/docs/effects/`
- No breaking changes - this is additive documentation
