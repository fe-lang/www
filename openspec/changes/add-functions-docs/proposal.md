# Change: Add Functions Documentation

## Why
Functions are the building blocks of Fe programs. The guide needs comprehensive documentation covering function declaration, parameters (including Fe's unique labeled parameters), return types, visibility, and the self receiver for methods.

## What Changes
- Add complete documentation page at `src/content/docs/foundations/functions.md`
- Document function declaration syntax with `fn` keyword
- Document labeled parameters (a unique Fe feature for call-site clarity)
- Document the `self` receiver for methods
- Document return types and the `->` syntax
- Document visibility with `pub` keyword
- Cover generic functions (brief intro, detailed in traits section)
- Cover the `uses` clause for effects (brief intro, detailed in effects section)

## Impact
- Affected specs: `documentation`
- Affected code: `src/content/docs/foundations/functions.md`
- No breaking changes - this is additive documentation
