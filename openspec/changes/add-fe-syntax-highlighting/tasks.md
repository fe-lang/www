# Tasks: Add Fe Syntax Highlighting

## 1. Research
- [x] 1.1 Review Shiki/TextMate grammar format
- [x] 1.2 Analyze Fe syntax from ERC20 example (`src/content/docs/examples/erc20.md`)
- [x] 1.3 Identify all Fe language constructs needing highlighting

## 2. Grammar Development
- [x] 2.1 Create TextMate grammar file for Fe language
- [x] 2.2 Define scopes for keywords (contract, msg, recv, init, fn, let, mut, etc.)
- [x] 2.3 Define scopes for types (u256, bool, Address, String, Map, etc.)
- [x] 2.4 Define scopes for literals (numbers, strings, hex values)
- [x] 2.5 Define scopes for comments
- [x] 2.6 Define scopes for operators and punctuation
- [x] 2.7 Define scopes for attributes (#[selector], #[indexed])

## 3. Integration
- [x] 3.1 Configure Astro/Starlight to load custom language
- [x] 3.2 Update ec.config.mjs with language configuration

## 4. Verification
- [x] 4.1 Test highlighting against ERC20 example
- [x] 4.2 Verify all code blocks in documentation render correctly
- [x] 4.3 Run build and confirm no errors
