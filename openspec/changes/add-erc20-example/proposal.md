# Change: Add Complete ERC20 Example from Compiler Fixtures

## Why
Part 14 (By Example) needs a complete, working ERC20 example. The Fe compiler's test fixtures contain a well-tested ERC20 implementation (`crates/fmt/tests/fixtures/erc20.fe`) that demonstrates real Fe patterns including contract-level effects, access control, events, and message handling.

## What Changes
- Replace the placeholder ERC20 example page with documentation based on the actual compiler fixture
- Use the provided ERC20 Fe code as is without modification
- Provide a complete walkthrough of a production-quality ERC20 implementation
- Demonstrate real Fe idioms: contract effects, storage structs, access control, events

## Impact
- Affected specs: `documentation`
- Affected code: `src/content/docs/examples/erc20.md`
- Source: `~/Documents/hacking/ef/fe/crates/fmt/tests/fixtures/erc20.fe`
