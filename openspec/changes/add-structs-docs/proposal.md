# Change: Add Structs & Impl Blocks Documentation

## Why
Part 8 of The Fe Guide covers structs and impl blocks—the primary way to define custom types and their associated behavior in Fe. Unlike contracts (which cannot have impl blocks), regular structs can have methods, making this an important distinction to document clearly.

## What Changes
- Document struct definition syntax and field visibility
- Document impl blocks for adding methods to structs
- Document associated functions (static methods)
- Document storage structs (structs used as effect types)
- Document helper structs (utility types for organizing logic)

## Impact
- Affected specs: `documentation`
- Affected code: `src/content/docs/structs/*.md` (5 files)
- Dependencies: Part 4 (Compound Types) introduces structs; this part expands on them
- Important distinction: Structs can have impl blocks, contracts cannot
