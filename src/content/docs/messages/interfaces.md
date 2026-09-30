---
title: Message Groups as Interfaces
description: How messages define contract interfaces
---

Message groups in Fe serve as interface definitions. They specify what operations a contract can receive, making the contract's API explicit and type-safe.

## Messages as Interface Specifications

A message group defines a contract interface:

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
    TotalSupply {} -> u256,
}
```

Any contract with `recv Erc20 { ... }` implements this interface.

## The MsgVariant Trait

Under the hood, each message variant becomes a struct. For every variant, the compiler generates `AbiSize`, `Encode<Sol>`, and `Decode<Sol>` implementations, plus an implementation of the `MsgVariant` trait from `core::message`:

```fe ignore
pub trait MsgVariant<A: Abi>: Encode<A> + Decode<A> {
    const SELECTOR: A::Selector
    type Return: Decode<A>
}
```

`SELECTOR` associates the variant with its 4-byte function selector, and `Return` is the type the handler must return. For the `Transfer` variant of the `Erc20` group above, a hand-written equivalent looks roughly like this:

```fe
use std::abi::Sol
use core::abi::{AbiSize, Encode, Decode, AbiDecoder, store_word}
use core::message::MsgVariant

// The variant struct
struct Transfer {
    to: Address,
    amount: u256,
}

// ABI size: two static words = 64 bytes
impl AbiSize for Transfer {
    const HEAD_SIZE: u256 = 64
    const IS_DYNAMIC: bool = false
}

// Encoding: write each field as a 32-byte word
impl Encode<Sol> for Transfer {
    fn encode(own self, _ ptr: *u8) {
        store_word(ptr: ptr, value: self.to.inner)
        store_word(ptr: core::ptr::offset_bytes(ptr, 32), value: self.amount)
    }
}

// Decoding: read each field back
impl Decode<Sol> for Transfer {
    fn decode_payload<D: AbiDecoder<Sol>>(_ d: mut D) -> Self {
        Transfer {
            to: Address::decode_payload(mut d),
            amount: u256::decode_payload(mut d),
        }
    }
}

// Selector and return type
impl MsgVariant<Sol> for Transfer {
    const SELECTOR: u32 = 0xa9059cbb
    type Return = bool
}
```

You never need to write this yourself. Let the compiler derive the ABI implementation from the message declaration rather than maintaining a handwritten encoder. With a `msg` declaration, the compiler generates all of this automatically, and you can access the generated `SELECTOR` constant:

```fe
use std::abi::sol

msg TokenMsg {
    #[selector = sol("transfer(address,uint256)")]
    Transfer { to: Address, amount: u256 } -> bool,
}

fn get_selector() -> u32 {
    TokenMsg::Transfer::SELECTOR
}
```

This desugaring enables:
- Type-safe message construction
- Compile-time selector verification
- Return type checking in handlers

## Interface Composition

Define standard interfaces as separate message groups:

```fe
use std::abi::{sol, Bytes32}

// Core ERC20 operations
msg Erc20 {
    #[selector = sol("transfer(address,uint256)")]
    Transfer { to: Address, amount: u256 } -> bool,
}

// Metadata extension
msg Erc20Metadata {
    #[selector = sol("name()")]
    Name {} -> String<31>,

    #[selector = sol("symbol()")]
    Symbol {} -> String<8>,

    #[selector = sol("decimals()")]
    Decimals {} -> u8,
}

// Permit extension (ERC-2612)
msg Erc20Permit {
    #[selector = sol("permit(address,address,uint256,uint256,uint8,bytes32,bytes32)")]
    Permit { owner: Address, spender: Address, value: u256, deadline: u256, v: u8, r: Bytes32, s: Bytes32 },

    #[selector = sol("nonces(address)")]
    Nonces { owner: Address } -> u256,

    #[selector = sol("DOMAIN_SEPARATOR()")]
    DomainSeparator {} -> Bytes32,
}

// Application-specific extension
msg TokenAdmin {
    #[selector = sol("mint(address,uint256)")]
    Mint { to: Address, amount: u256 },
}
```

Contracts can implement any combination:

```fe
//<hide>
use std::abi::{sol, Bytes32}
msg Erc20 {
    #[selector = sol("transfer(address,uint256)")]
    Transfer { to: Address, amount: u256 } -> bool,
}

msg Erc20Metadata {
    #[selector = sol("name()")]
    Name {} -> String<31>,
    #[selector = sol("symbol()")]
    Symbol {} -> String<8>,
    #[selector = sol("decimals()")]
    Decimals {} -> u8,
}

msg Erc20Permit {
    #[selector = sol("permit(address,address,uint256,uint256,uint8,bytes32,bytes32)")]
    Permit { owner: Address, spender: Address, value: u256, deadline: u256, v: u8, r: Bytes32, s: Bytes32 },
    #[selector = sol("nonces(address)")]
    Nonces { owner: Address } -> u256,
    #[selector = sol("DOMAIN_SEPARATOR()")]
    DomainSeparator {} -> Bytes32,
}
//</hide>

// Basic token
contract SimpleToken {
    recv Erc20 {
        Transfer { to, amount } -> bool {
            let _ = (to, amount)
            true
        }
    }
}

// Token with metadata
contract MetadataToken {
    recv Erc20 {
        Transfer { to, amount } -> bool {
            let _ = (to, amount)
            true
        }
    }
    recv Erc20Metadata {
        Name {} -> String<31> { "Token" }
        Symbol {} -> String<8> { "TKN" }
        Decimals {} -> u8 { 18 }
    }
}

// Full-featured token
contract FullToken {
    recv Erc20 {
        Transfer { to, amount } -> bool {
            let _ = (to, amount)
            true
        }
    }
    recv Erc20Metadata {
        Name {} -> String<31> { "Token" }
        Symbol {} -> String<8> { "TKN" }
        Decimals {} -> u8 { 18 }
    }
    recv Erc20Permit {
        Permit { owner, spender, value, deadline, v, r, s } {
            let _ = (owner, spender, value, deadline, v, r, s)
        }
        Nonces { owner } -> u256 {
            let _ = owner
            0
        }
        DomainSeparator {} -> Bytes32 { Bytes32 { val: 0 } }
    }
}
```

Each `recv` block must handle every variant in its group. See [Multiple Message Types](/messages/multiple-types/) for the syntax and [CoolCoin](/examples/erc20/) for handlers with real balance and permission checks.

## Defining Custom Interfaces

Create your own interfaces for custom protocols:

```fe
//<hide>
use std::abi::sol
msg Erc20 {
    #[selector = sol("transfer(address,uint256)")]
    Transfer { to: Address, amount: u256 } -> bool,
}
//</hide>

msg Ownable {
    #[selector = sol("owner()")]
    Owner {} -> Address,

    #[selector = sol("transferOwnership(address)")]
    TransferOwnership { new_owner: Address } -> bool,

    #[selector = sol("renounceOwnership()")]
    RenounceOwnership {} -> bool,
}

msg Pausable {
    #[selector = sol("paused()")]
    Paused {} -> bool,

    #[selector = sol("pause()")]
    Pause {} -> bool,

    #[selector = sol("unpause()")]
    Unpause {} -> bool,
}

contract ManagedToken {
    recv Erc20 {
        Transfer { to, amount } -> bool {
            let _ = (to, amount)
            true
        }
    }
    recv Ownable {
        Owner {} -> Address { Address::zero() }
        TransferOwnership { new_owner } -> bool {
            let _ = new_owner
            true
        }
        RenounceOwnership {} -> bool { true }
    }
    recv Pausable {
        Paused {} -> bool { false }
        Pause {} -> bool { true }
        Unpause {} -> bool { true }
    }
}
```

## Interface Documentation

Document your interfaces with comments:

```fe
use std::abi::sol

/// Standard ERC20 token interface
///
/// Defines the core operations for fungible tokens:
/// - Transfer: Move tokens between accounts
/// - Approve: Grant spending allowance
/// - TransferFrom: Spend on behalf of another account
msg Erc20 {
    /// Transfer tokens to another account
    /// Returns true on success
    #[selector = sol("transfer(address,uint256)")]
    Transfer { to: Address, amount: u256 } -> bool,

    /// Approve a spender to transfer tokens on your behalf
    #[selector = sol("approve(address,uint256)")]
    Approve { spender: Address, amount: u256 } -> bool,
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
