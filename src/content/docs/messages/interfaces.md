---
title: Message Groups as Interfaces
description: How messages define contract interfaces
---

Message groups in Fe serve as interface definitions. They specify what operations a contract can receive, making the contract's API explicit and type-safe.

## Messages as Interface Specifications

A message group defines a contract interface:

```fe ignore
msg Erc20 {
    #[selector = 0xa9059cbb]
    Transfer { to: u256, amount: u256 } -> bool,

    #[selector = 0x095ea7b3]
    Approve { spender: u256, amount: u256 } -> bool,

    #[selector = 0x23b872dd]
    TransferFrom { from: u256, to: u256, amount: u256 } -> bool,

    #[selector = 0x70a08231]
    BalanceOf { account: u256 } -> u256,

    #[selector = 0xdd62ed3e]
    Allowance { owner: u256, spender: u256 } -> u256,

    #[selector = 0x18160ddd]
    TotalSupply -> u256,
}
```

Any contract with `recv Erc20 { ... }` implements this interface.

## The MsgVariant Trait

Under the hood, each message variant becomes a struct that implements the `MsgVariant` trait:

```fe ignore
// Conceptually, Transfer becomes:
struct Transfer {
    to: u256,
    amount: u256,
}

impl MsgVariant for Transfer {
    const SELECTOR: u32 = 0xa9059cbb
    type Return = bool
}
```

The `MsgVariant` trait provides:
- `SELECTOR`: The 4-byte function identifier
- `Return`: The type returned by handlers of this variant

## How Messages Desugar

When you write:

```fe ignore
msg TokenMsg {
    #[selector = 0xa9059cbb]
    Transfer { to: u256, amount: u256 } -> bool,
}
```

The compiler generates equivalent code like:

```fe ignore
// The variant as a struct
struct TokenMsg_Transfer {
    to: u256,
    amount: u256,
}

// Implementation of MsgVariant
impl MsgVariant for TokenMsg_Transfer {
    const SELECTOR: u32 = 0xa9059cbb
    type Return = bool
}
```

This desugaring enables:
- Type-safe message construction
- Compile-time selector verification
- Return type checking in handlers

## Interface Composition

Define standard interfaces as separate message groups:

```fe ignore
// Core ERC20 operations
msg Erc20 {
    #[selector = 0xa9059cbb]
    Transfer { to: u256, amount: u256 } -> bool,
    // ...
}

// Metadata extension
msg Erc20Metadata {
    #[selector = 0x06fdde03]
    Name -> String,

    #[selector = 0x95d89b41]
    Symbol -> String,

    #[selector = 0x313ce567]
    Decimals -> u8,
}

// Permit extension (ERC2612)
msg Erc20Permit {
    #[selector = 0xd505accf]
    Permit { owner: u256, spender: u256, value: u256, deadline: u256, v: u8, r: u256, s: u256 },

    #[selector = 0x7ecebe00]
    Nonces { owner: u256 } -> u256,

    #[selector = 0x3644e515]
    DomainSeparator -> u256,
}
```

Contracts can implement any combination:

```fe ignore
// Basic token
contract SimpleToken {
    recv Erc20 { /* ... */ }
}

// Token with metadata
contract MetadataToken {
    recv Erc20 { /* ... */ }
    recv Erc20Metadata { /* ... */ }
}

// Full-featured token
contract FullToken {
    recv Erc20 { /* ... */ }
    recv Erc20Metadata { /* ... */ }
    recv Erc20Permit { /* ... */ }
}
```

## Defining Custom Interfaces

Create your own interfaces for custom protocols:

```fe ignore
msg Ownable {
    #[selector = 0x8da5cb5b]
    Owner -> u256,

    #[selector = 0xf2fde38b]
    TransferOwnership { new_owner: u256 },

    #[selector = 0x715018a6]
    RenounceOwnership,
}

msg Pausable {
    #[selector = 0x5c975abb]
    Paused -> bool,

    #[selector = 0x8456cb59]
    Pause,

    #[selector = 0x3f4ba83a]
    Unpause,
}

contract ManagedToken {
    recv Erc20 { /* ... */ }
    recv Ownable { /* ... */ }
    recv Pausable { /* ... */ }
}
```

## Interface Documentation

Document your interfaces with comments:

```fe ignore
/// Standard ERC20 token interface
///
/// Defines the core operations for fungible tokens:
/// - Transfer: Move tokens between accounts
/// - Approve: Grant spending allowance
/// - TransferFrom: Spend on behalf of another account
msg Erc20 {
    /// Transfer tokens to another account
    /// Returns true on success
    #[selector = 0xa9059cbb]
    Transfer { to: u256, amount: u256 } -> bool,

    /// Approve a spender to transfer tokens on your behalf
    #[selector = 0x095ea7b3]
    Approve { spender: u256, amount: u256 } -> bool,

    // ...
}
```

## Benefits of Message-Based Interfaces

1. **Explicit contracts**: The interface is visible in the source code
2. **Compiler verification**: The compiler ensures all variants are handled
3. **ABI compatibility**: Selectors match Ethereum's calling convention
4. **Separation of concerns**: Interface definition separate from implementation
5. **Composability**: Mix and match interface components

## Summary

| Concept | Description |
|---------|-------------|
| Message group | Defines a contract interface |
| MsgVariant trait | Underlying trait for message variants |
| SELECTOR | 4-byte function identifier constant |
| Return type | Associated type for handler return value |
| Composition | Contracts can implement multiple message groups |
