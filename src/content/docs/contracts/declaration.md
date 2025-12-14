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
contract Token {
    // Fields
    store: TokenStorage,

    // Init block
    init(initial_supply: u256) {
        // initialization logic
    }

    // Recv blocks
    recv TokenMsg {
        // message handlers
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

Fields are bound to effect types—the field name (`store`) becomes available for use in `with` expressions to provide effects to functions.

## What Contracts Cannot Have

Unlike structs, contracts have specific restrictions:

- **No impl blocks**: You cannot implement methods on contracts
- **No associated functions**: Contracts don't have `fn` declarations inside them
- **No direct field access**: Storage is accessed through effects, not `self.field`

```fe
// WRONG: Contracts cannot have impl blocks
contract Token {
    store: TokenStorage,
}

impl Token {  // Error!
    fn get_balance(self) -> u256 { ... }
}
```

Instead, use standalone functions with effects:

```fe
// CORRECT: Use functions with effects
fn get_balance(account: u256) uses TokenStorage -> u256 {
    TokenStorage.balances.get(account)
}

contract Token {
    store: TokenStorage,

    recv TokenMsg {
        BalanceOf { account } -> u256 {
            with (TokenStorage = store) {
                get_balance(account)
            }
        }
    }
}
```

## Contract Structure

The canonical structure of a Fe contract:

```fe
// 1. Storage struct definition
pub struct TokenStorage {
    pub balances: StorageMap<u256, u256>,
    pub total_supply: u256,
}

// 2. Message definitions
msg TokenMsg {
    #[selector = 0xa9059cbb]
    Transfer { to: u256, amount: u256 } -> bool,

    #[selector = 0x70a08231]
    BalanceOf { account: u256 } -> u256,
}

// 3. Helper functions with effects
fn do_transfer(from: u256, to: u256, amount: u256) uses mut TokenStorage -> bool {
    let from_bal = TokenStorage.balances.get(from)
    if from_bal < amount {
        return false
    }
    TokenStorage.balances.set(from, from_bal - amount)

    let to_bal = TokenStorage.balances.get(to)
    TokenStorage.balances.set(to, to_bal + amount)
    true
}

// 4. Contract declaration
contract Token {
    store: TokenStorage,

    init(initial_supply: u256) {
        store.total_supply = initial_supply
    }

    recv TokenMsg {
        Transfer { to, amount } -> bool {
            with (TokenStorage = store) {
                do_transfer(caller(), to, amount)
            }
        }

        BalanceOf { account } -> u256 {
            with (TokenStorage = store) {
                TokenStorage.balances.get(account)
            }
        }
    }
}
```

## Multiple Contracts

A single Fe file can define multiple contracts:

```fe
contract TokenA {
    store: TokenStorage,
    // ...
}

contract TokenB {
    store: TokenStorage,
    // ...
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

Contracts are intentionally simple—they hold state, initialize it, and handle messages. All business logic lives in standalone functions that use effects.
