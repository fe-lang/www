# Change: Add Primitive Types Documentation

## Why
The Fe Guide needs comprehensive documentation of primitive types to help developers understand the available data types in Fe. This is a foundational section that other documentation pages will reference.

## What Changes
- Add new documentation page at `src/content/docs/foundations/primitive-types.md`
- Document all primitive types: `bool`, signed integers (`i8`-`i256`, `isize`), unsigned integers (`u8`-`u256`, `usize`), and `String`
- Include type sizes, ranges, and usage examples
- Cover type literals and type inference

## Impact
- Affected specs: `documentation` (new capability)
- Affected code: `src/content/docs/foundations/primitive-types.md`
- No breaking changes - this is additive documentation
