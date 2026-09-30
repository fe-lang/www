---
title: Defining Messages
description: The msg declaration for contract interfaces
---

Messages define the external interface of a contract: the operations that can be called from outside. They're similar to external functions in Solidity but with a cleaner, more explicit design.

## The msg Declaration

Define a message group using the `msg` keyword:

```fe
use std::abi::sol

msg TokenMsg {
    #[selector = sol("transfer(address,uint256)")]
    Transfer { to: Address, amount: u256 } -> bool,

    #[selector = sol("balanceOf(address)")]
    BalanceOf { account: Address } -> u256,

    #[selector = sol("totalSupply()")]
    TotalSupply -> u256,
}
```

Each message group contains one or more **variants**: individual operations that can be called.

## Message Variants

A variant defines a single callable operation:

```fe
//<hide>
use std::abi::sol
msg Example {
//</hide>
    #[selector = sol("transfer(address,uint256)")]
    Transfer { to: Address, amount: u256 } -> bool,
//<hide>
}
//</hide>
```

Components:
- **Selector attribute**: The 4-byte identifier (`#[selector = sol(...)]`)
- **Name**: The variant name (`Transfer`)
- **Fields**: Parameters in curly braces (`{ to: Address, amount: u256 }`)
- **Return type**: What the handler returns (`-> bool`)

### Variants Without Parameters

Some operations don't need parameters:

```fe
//<hide>
use std::abi::sol
msg Example {
//</hide>
    #[selector = sol("totalSupply()")]
    TotalSupply -> u256,
//<hide>
}
//</hide>
```

### Variants Without Return Values

Operations that don't return a value omit the return type:

```fe
//<hide>
use std::abi::sol
msg Example {
//</hide>
    #[selector = sol("safeTransferFrom(address,address,uint256)")]
    SafeTransfer { from: Address, to: Address, token_id: u256 },
//<hide>
}
//</hide>
```

This implicitly returns `()` (unit).

## Complete Example

A simple token message interface:

```fe
use std::abi::sol

msg Erc20 {
    #[selector = sol("transfer(address,uint256)")]
    Transfer { to: Address, amount: u256 } -> bool,

    #[selector = sol("approve(address,uint256)")]
    Approve { spender: Address, amount: u256 } -> bool,

    #[selector = sol("transferFrom(address,address,uint256)")]
    TransferFrom { from: Address, to: Address, amount: u256 } -> bool,

    #[selector = sol("balanceOf(address)")]
    BalanceOf { account: Address } -> u256,

    #[selector = sol("allowance(address,address)")]
    Allowance { owner: Address, spender: Address } -> u256,

    #[selector = sol("totalSupply()")]
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

```fe
//<hide>
use std::abi::sol
msg Erc20 {
    #[selector = sol("transfer(address,uint256)")]
    Transfer { to: Address, amount: u256 } -> bool,
}
//</hide>

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

## Multiple Return Values

A handler returning a tuple uses Solidity's multiple-return-value encoding. For example, `-> (DynString, u256)` corresponds to `returns (string, uint256)`. The ABI lists two outputs, and the dynamic string's offset is measured from that output parameter list.

Fe 26.4 corrects the encoding of tuples containing dynamic elements: earlier compilers could insert an extra outer offset. Static tuple returns are unchanged. A single `DynString` return still follows the usual single-dynamic-output encoding.

```fe
use std::abi::{sol, DynString}

msg InfoMsg {
    #[selector = sol("info()")]
    Info -> (DynString, u256),
}

pub contract Info {
    recv InfoMsg {
        Info -> (DynString, u256) { ("Fe", 264) }
    }
}

#[test]
fn multiple_return_values() uses (evm: mut Evm) {
    let target = evm.create2<Info>(value: 0, args: (), salt: 0)
    let outcome = evm.try_call(addr: target, gas: 1000000, value: 0, message: InfoMsg::Info {})
    assert!(outcome.success())
    let data = outcome.returndata()
    assert!(data.word_at(0) == 64) // String tail follows the two-word head.
    assert!(data.word_at(32) == 264)
    let (name, version): (DynString, u256) = evm.call(
        addr: target, gas: 1000000, value: 0, message: InfoMsg::Info {},
    )
    assert!(name == "Fe" && version == 264)
}
```
