---
title: Defining Messages
description: The msg declaration for contract interfaces
---

Messages define the external interface of a contract—the operations that can be called from outside. They're similar to external functions in Solidity but with a cleaner, more explicit design.

## The msg Declaration

Define a message group using the `msg` keyword:

```fe ignore
msg TokenMsg {
    #[selector = 0xa9059cbb]
    Transfer { to: u256, amount: u256 } -> bool,

    #[selector = 0x70a08231]
    BalanceOf { account: u256 } -> u256,

    #[selector = 0x18160ddd]
    TotalSupply -> u256,
}
```

Each message group contains one or more **variants**—individual operations that can be called.

## Message Variants

A variant defines a single callable operation:

```fe ignore
#[selector = 0xa9059cbb]
Transfer { to: u256, amount: u256 } -> bool
```

Components:
- **Selector attribute**: The 4-byte identifier (`#[selector = 0x...]`)
- **Name**: The variant name (`Transfer`)
- **Fields**: Parameters in curly braces (`{ to: u256, amount: u256 }`)
- **Return type**: What the handler returns (`-> bool`)

### Variants Without Parameters

Some operations don't need parameters:

```fe ignore
#[selector = 0x18160ddd]
TotalSupply -> u256
```

### Variants Without Return Values

Operations that don't return a value omit the return type:

```fe ignore
#[selector = 0x42842e0e]
SafeTransfer { from: u256, to: u256, token_id: u256 }
```

This implicitly returns `()` (unit).

## Complete Example

A simple token message interface:

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

## Why Messages?

Messages provide:

1. **Clear interface definition**: All callable operations in one place
2. **ABI compatibility**: Selectors match Ethereum's function selector mechanism
3. **Type safety**: Parameters and return types are checked at compile time
4. **Separation of concerns**: Interface definition separate from implementation

## Using Messages

Messages are handled in recv blocks within contracts:

```fe ignore
contract Token {
    // storage fields...

    recv Erc20 {
        Transfer { to, amount } -> bool {
            // handle transfer
            true
        }
        // ... other handlers
    }
}
```

See [Receive Blocks](/messages/receive-blocks/) for details on implementing handlers.
