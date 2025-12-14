# Change: Add Messages & Receive Blocks Documentation

## Why
Messages and receive blocks are Fe's mechanism for handling external calls to contracts. They define the contract's public interface, similar to Solidity's external functions. Developers need comprehensive documentation to understand how to define messages, handle them in receive blocks, and work with selectors for ABI compatibility.

## What Changes
- Complete documentation for `src/content/docs/messages/defining-messages.md`
- Complete documentation for `src/content/docs/messages/fields.md`
- Complete documentation for `src/content/docs/messages/selectors.md`
- Complete documentation for `src/content/docs/messages/receive-blocks.md`
- Complete documentation for `src/content/docs/messages/handler-syntax.md`
- Complete documentation for `src/content/docs/messages/multiple-types.md`
- Complete documentation for `src/content/docs/messages/interfaces.md`

### Defining Messages
- The `msg` keyword syntax
- Message variants with parameters and return types
- Basic message definition structure

### Message Fields
- Field syntax within message variants
- Field types and constraints
- Optional fields and defaults

### Selectors
- 4-byte function selectors for ABI compatibility
- The `#[selector = 0x...]` attribute
- Selector uniqueness requirements
- How selectors enable external calls

### Receive Blocks
- Named recv blocks: `recv MsgType { }`
- Bare recv blocks: `recv { }`
- Recv blocks in contracts
- Exhaustiveness checking

### Handler Syntax
- Pattern matching on message variants
- Field destructuring in handlers
- Return types in handlers
- The uses clause for effects

### Multiple Message Types
- Multiple recv blocks in one contract
- Cross-message selector uniqueness
- Organizing handlers by concern

### Message Groups as Interfaces
- The MsgVariant trait
- How messages desugar to modules and structs
- Creating custom message-like types
- Interface composition

## Impact
- Affected specs: `documentation`
- Affected code: All files in `src/content/docs/messages/`
- No breaking changes - this is additive documentation
