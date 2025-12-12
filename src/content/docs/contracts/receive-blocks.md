---
title: Receive Blocks in Contracts
description: Handling messages within contract context
---

Receive blocks inside contracts handle incoming messages and have access to the contract's storage through effects. This section focuses on how recv blocks work within the contract context.

## Recv Blocks and Contract State

In a contract, recv blocks access storage via `uses` clauses:

```fe
//<hide>
use _boilerplate::{Map, caller}
fn do_transfer(from: u256, to: u256, amount: u256) -> bool uses (mut store: TokenStorage) {
    let _ = (from, to, amount, store)
    true
}
//</hide>

pub struct TokenStorage {
    pub balances: Map<u256, u256>,
    pub total_supply: u256,
}

msg TokenMsg {
    #[selector = 0x70a08231]
    BalanceOf { account: u256 } -> u256,

    #[selector = 0xa9059cbb]
    Transfer { to: u256, amount: u256 } -> bool,
}

contract Token {
    mut store: TokenStorage,

    recv TokenMsg {
        BalanceOf { account } -> u256 uses (store) {
            store.balances.get(account)
        }

        Transfer { to, amount } -> bool uses (mut store) {
            do_transfer(caller(), to, amount)
        }
    }
}
```

## The uses Clause

The `uses` clause on a handler declares which contract fields it needs:

```fe
//<hide>
use _boilerplate::Map
pub struct TokenStorage { pub balances: Map<u256, u256> }
msg TokenMsg {
    #[selector = 0x12345678]
    BalanceOf { account: u256 } -> u256,
}
contract Token {
    mut store: TokenStorage,
    recv TokenMsg {
//</hide>
        BalanceOf { account } -> u256 uses (store) {
            // store is available here
            store.balances.get(account)
        }
//<hide>
    }
}
//</hide>
```

This pattern:
1. Declares that the handler needs the `store` field
2. Makes `store` directly accessible in the handler body
3. Propagates the effect to any called functions

## Calling Helper Functions

Handlers typically delegate to helper functions:

```fe
//<hide>
use _boilerplate::{Map, caller}
pub struct TokenStorage { pub balances: Map<u256, u256> }
msg TokenMsg {
    #[selector = 0x70a08231]
    BalanceOf { account: u256 } -> u256,
    #[selector = 0xa9059cbb]
    Transfer { to: u256, amount: u256 } -> bool,
}
//</hide>

fn get_balance(account: u256) -> u256 uses (store: TokenStorage) {
    store.balances.get(account)
}

fn do_transfer(from: u256, to: u256, amount: u256) -> bool uses (mut store: TokenStorage) {
    let from_bal = store.balances.get(from)
    if from_bal < amount {
        return false
    }

    store.balances.set(from, from_bal - amount)

    let to_bal = store.balances.get(to)
    store.balances.set(to, to_bal + amount)
    true
}

contract Token {
    mut store: TokenStorage,

    recv TokenMsg {
        BalanceOf { account } -> u256 uses (store) {
            get_balance(account)
        }

        Transfer { to, amount } -> bool uses (mut store) {
            do_transfer(caller(), to, amount)
        }
    }
}
```

## Multiple Storage Effects

When handlers need multiple storage types:

```fe
//<hide>
use _boilerplate::{Map, caller}
fn do_transfer_from(c: u256, from: u256, to: u256, amount: u256) -> bool
    uses (mut balances: BalanceStorage, mut allowances: AllowanceStorage)
{
    let _ = (c, from, to, amount, balances, allowances)
    true
}
msg TokenMsg {
    #[selector = 0x23b872dd]
    TransferFrom { from: u256, to: u256, amount: u256 } -> bool,
}
//</hide>

pub struct BalanceStorage {
    pub balances: Map<u256, u256>,
}

pub struct AllowanceStorage {
    pub allowances: Map<u256, Map<u256, u256>>,
}

contract Token {
    mut balances: BalanceStorage,
    mut allowances: AllowanceStorage,

    recv TokenMsg {
        TransferFrom { from, to, amount } -> bool uses (mut balances, mut allowances) {
            do_transfer_from(caller(), from, to, amount)
        }
    }
}
```

## Complete Contract Example

For a full ERC20-style token contract demonstrating all these patterns, see the [Complete ERC20 example](/examples/erc20/).

## Handler Organization

For contracts with many handlers, organize by interface:

```fe
//<hide>
pub struct TokenStorage { pub total: u256 }

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
    TotalSupply {} -> u256,
}

msg Erc20Metadata {
    #[selector = 0x06fdde03]
    Name {} -> String<32>,
    #[selector = 0x95d89b41]
    Symbol {} -> String<8>,
    #[selector = 0x313ce567]
    Decimals {} -> u8,
}
//</hide>

contract Token {
    store: TokenStorage,

    // Core ERC20 operations
    recv Erc20 {
        Transfer { to, amount } -> bool {
            let _ = (to, amount)
            true
        }
        Approve { spender, amount } -> bool {
            let _ = (spender, amount)
            true
        }
        TransferFrom { from, to, amount } -> bool {
            let _ = (from, to, amount)
            true
        }
        BalanceOf { account } -> u256 {
            let _ = account
            0
        }
        Allowance { owner, spender } -> u256 {
            let _ = (owner, spender)
            0
        }
        TotalSupply {} -> u256 { 0 }
    }

    // Metadata extension
    recv Erc20Metadata {
        Name {} -> String<32> { "Token" }
        Symbol {} -> String<8> { "TKN" }
        Decimals {} -> u8 { 18 }
    }
}
```

## Summary

| Concept | Description |
|---------|-------------|
| `recv MsgType { }` | Recv block in contract |
| `uses (field)` | Access storage in handler |
| Helper functions | Functions with `uses` clause |
| Multiple effects | `uses (mut a, mut b)` |
| Organization | Separate recv blocks per interface |
