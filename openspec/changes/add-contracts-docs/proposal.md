# Change: Add Contracts Documentation

## Why
Part 7 of The Fe Guide covers contracts—the core building block of Fe smart contracts. Users need comprehensive documentation on how to declare contracts, define storage, write init blocks, and organize contract logic.

## What Changes
- Document contract declaration syntax (`contract Name { }`)
- Document contract-level effect dependencies
- Document storage fields and their relationship to effects
- Document the init block for constructor logic
- Document recv blocks within contracts (building on Part 6)
- Document contract composition patterns

## Impact
- Affected specs: `documentation`
- Affected code: `src/content/docs/contracts/*.md` (6 files)
- Dependencies: Part 5 (Effects) and Part 6 (Messages) should be completed first
