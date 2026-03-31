---
title: Contract Declaration
description: Declaring contracts in Fe
---

Contracts are the primary building blocks of Fe smart contract development. They define storage, initialization logic, and message handlers.

## Basic Contract Syntax

Declare a contract with the `contract` keyword:

```fe
contract Token {
    // Contract body
}
```

A contract can contain:
- **Fields**: Storage and effect bindings
- **Init block**: Constructor logic (optional)
- **Recv blocks**: Message handlers

```fe
//<hide>
use std::abi::sol
msg TokenMsg {
    #[selector = sol("transfer(address,uint256)")]
    Transfer { to: u256, amount: u256 } -> bool,
}

pub struct TokenStorage {
    pub total_supply: u256,
}
//</hide>

contract Token {
    // Fields
    store: TokenStorage,

    // Init block
    init(initial_supply: u256) {
        // initialization logic
    }

    // Recv blocks
    recv TokenMsg {
        Transfer { to, amount } -> bool {
            true
        }
    }
}
```

## Contract Fields

Fields declare the contract's storage and effect dependencies:

```fe
pub struct TokenStorage {
    pub balances: StorageMap<u256, u256>,
    pub total_supply: u256,
}

contract Token {
    store: TokenStorage,
}
```

Fields are bound to effect types. The field name (`store`) becomes available for use in `with` expressions to provide effects to functions.

## What Contracts Cannot Have

Unlike structs, contracts have specific restrictions:

- **No impl blocks**: You cannot implement methods on contracts
- **No associated functions**: Contracts don't have `fn` declarations inside them
- **No direct field access**: Storage is accessed through effects, not `self.field`

```fe ignore
// WRONG: Contracts cannot have impl blocks
contract Token {
    store: TokenStorage,
}

impl Token {  // Error!
    fn get_balance(self) -> u256 { ... }
}
```

Instead, define methods on the storage struct and call them through the effect binding:

```fe
//<hide>
use std::abi::sol
//</hide>

pub struct TokenStorage {
    pub balances: StorageMap<u256, u256>,
}

impl TokenStorage {
    fn get_balance(self, account: u256) -> u256 {
        self.balances.get(key: account)
    }
}

//<hide>
msg TokenMsg {
    #[selector = sol("balanceOf(address)")]
    BalanceOf { account: u256 } -> u256,
}
//</hide>

contract Token {
    store: TokenStorage,

    recv TokenMsg {
        BalanceOf { account } -> u256 uses store {
            store.get_balance(account)
        }
    }
}
```

## Contract Structure

The canonical structure of a Fe contract:

```fe
//<hide>
use std::abi::sol
pub struct Ctx {}
impl Ctx {
    pub fn caller(self) -> u256 { todo() }
}
//</hide>

// 1. Storage struct definition
pub struct TokenStorage {
    pub balances: StorageMap<u256, u256>,
    pub total_supply: u256,
}

// 2. Methods on the storage struct
impl TokenStorage {
    fn do_transfer(mut self, from: u256, to: u256, amount: u256) -> bool {
        let from_bal = self.balances.get(key: from)
        if from_bal < amount {
            return false
        }
        self.balances.set(key: from, value: from_bal - amount)

        let to_bal = self.balances.get(key: to)
        self.balances.set(key: to, value: to_bal + amount)
        true
    }
}

// 3. Message definitions
msg TokenMsg {
    #[selector = sol("transfer(address,uint256)")]
    Transfer { to: u256, amount: u256 } -> bool,

    #[selector = sol("balanceOf(address)")]
    BalanceOf { account: u256 } -> u256,
}

// 4. Contract declaration
contract Token {
    mut store: TokenStorage,

    init(initial_supply: u256) uses (mut store) {
        store.total_supply = initial_supply
    }

    recv TokenMsg {
        Transfer { to, amount } -> bool uses (ctx: Ctx, mut store) {
            store.do_transfer(from: ctx.caller(), to, amount)
        }

        BalanceOf { account } -> u256 uses store {
            store.balances.get(key: account)
        }
    }
}
```

## Multiple Contracts

A single Fe file can define multiple contracts:

```fe
//<hide>
pub struct TokenStorage {
    pub total_supply: u256,
}
//</hide>

contract TokenA {
    store: TokenStorage,
}

contract TokenB {
    store: TokenStorage,
}
```

Each contract is compiled to separate bytecode and deployed independently.

## Summary

| Element | Description |
|---------|-------------|
| `contract Name { }` | Declares a contract |
| Fields | Storage and effect bindings |
| `init() { }` | Constructor logic |
| `recv MsgType { }` | Message handlers |

Contracts are intentionally simple. They hold state, initialize it, and handle messages. Business logic lives in impl blocks on storage structs, keeping related behavior cohesive.
