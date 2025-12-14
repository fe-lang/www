# Change: Add Compound Types Documentation

## Why
Compound types are essential building blocks for organizing data in Fe programs. Developers need comprehensive documentation covering tuples, structs, enums, and maps to write effective smart contracts.

## What Changes
- Complete documentation for `src/content/docs/compound-types/tuples.md`
- Complete documentation for `src/content/docs/compound-types/structs.md`
- Complete documentation for `src/content/docs/compound-types/enums.md`
- Complete documentation for `src/content/docs/compound-types/maps.md`

### Tuples
- Tuple type syntax: `(T1, T2, T3)`
- Tuple expressions: `(value1, value2, value3)`
- Single-element tuples with trailing comma: `(value,)`
- Index access: `tuple.0`, `tuple.1`
- Tuple destructuring in patterns
- Tuples in function return types

### Structs
- Struct definition with `struct` keyword
- Field definitions with types and visibility (`pub`)
- Generic parameters and trait bounds
- Struct instantiation: `Struct { field: value }`
- Field access: `instance.field`
- Struct patterns for destructuring

### Enums
- Enum definition with `enum` keyword
- Unit variants: `None`, `Empty`
- Tuple variants: `Some(T)`, `Pair(u32, u32)`
- Struct variants: `Point { x: i32, y: i32 }`
- Pattern matching on enums
- Exhaustive matching requirement
- Generic enums

### Maps
- StorageMap from the standard library
- Map declaration in contract storage
- `get(key)` and `set(key, value)` operations
- Key and value type requirements
- Storage layout (Solidity-compatible keccak256 hashing)

## Impact
- Affected specs: `documentation`
- Affected code: All files in `src/content/docs/compound-types/`
- No breaking changes - this is additive documentation
