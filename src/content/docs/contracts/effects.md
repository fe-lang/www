---
title: Contract-Level Effects
description: How contracts provide effects to handlers
---

Contracts bridge the gap between storage and the effect system. Contract fields hold storage, and handlers use `uses` clauses to access those fields as effects.

## The Contract-Effect Relationship

When you declare a contract field with a storage type, that field becomes available as an effect in handlers:

```fe
//<hide>
use _boilerplate::Map
pub struct TokenStorage {
    pub balances: Map<u256, u256>,
    pub total_supply: u256,
}
msg TokenMsg {
    #[selector = 0x12345678]
    BalanceOf { account: u256 } -> u256,
}
//</hide>

contract Token {
    mut store: TokenStorage,  // Storage field

    recv TokenMsg {
        BalanceOf { account } -> u256 uses (store) {
            // Access storage through the uses clause
            store.balances.get(account)
        }
    }
}
```

The `uses (store)` clause on the handler:
1. Makes the contract field `store` available in the handler
2. Allows code to use `store.field` syntax directly
3. Propagates the effect to any called functions

## Providing Effects to Functions

The primary use of contract-level effects is providing them to helper functions:

```fe
//<hide>
use _boilerplate::Map
pub struct TokenStorage {
    pub balances: Map<u256, u256>,
    pub total_supply: u256,
}
msg TokenMsg {
    #[selector = 0x12345678]
    BalanceOf { account: u256 } -> u256,
    #[selector = 0x87654321]
    Transfer { to: u256, amount: u256 } -> bool,
}
//</hide>

fn get_balance(account: u256) -> u256 uses (store: TokenStorage) {
    store.balances.get(account)
}

fn add_balance(account: u256, amount: u256) uses (mut store: TokenStorage) {
    let current = store.balances.get(account)
    store.balances.set(account, current + amount)
}

contract Token {
    mut store: TokenStorage,

    recv TokenMsg {
        BalanceOf { account } -> u256 uses (store) {
            get_balance(account)
        }

        Transfer { to, amount } -> bool uses (mut store) {
            add_balance(to, amount)
            true
        }
    }
}
```

## Mutable vs Immutable Effects

Use `mut` when you need to modify storage:

```fe
//<hide>
use _boilerplate::Map
pub struct TokenStorage {
    pub balances: Map<u256, u256>,
    pub total_supply: u256,
}
msg TokenMsg {
    #[selector = 0x12345678]
    BalanceOf { account: u256 } -> u256,
    #[selector = 0x87654321]
    Transfer { to: u256, amount: u256 } -> bool,
}
//</hide>

contract Token {
    mut store: TokenStorage,

    recv TokenMsg {
        // Read-only: no mut needed
        BalanceOf { account } -> u256 uses (store) {
            store.balances.get(account)
        }

        // Writing: mut required
        Transfer { to, amount } -> bool uses (mut store) {
            store.balances.set(to, amount)
            true
        }
    }
}
```

When calling functions that require `mut` effects, the handler must declare `mut` access.

## Multiple Effect Fields

Contracts can have multiple fields for different effects:

```fe
//<hide>
use _boilerplate::{Map, caller}
fn do_transfer(c: u256, to: u256, amount: u256) -> bool uses (mut tokens: TokenStorage) {
    let _ = (c, to, amount, tokens)
    true
}
fn set_allowance(c: u256, spender: u256, amount: u256) uses (mut permits: AllowanceStorage) {
    let _ = (c, spender, amount, permits)
}
fn do_transfer_from(c: u256, from: u256, to: u256, amount: u256) -> bool
    uses (mut tokens: TokenStorage, mut permits: AllowanceStorage)
{
    let _ = (c, from, to, amount, tokens, permits)
    true
}
msg TokenMsg {
    #[selector = 0x12345678]
    Transfer { to: u256, amount: u256 } -> bool,
    #[selector = 0x87654321]
    Approve { spender: u256, amount: u256 } -> bool,
    #[selector = 0xabcdef12]
    TransferFrom { from: u256, to: u256, amount: u256 } -> bool,
}
//</hide>

pub struct TokenStorage {
    pub balances: Map<u256, u256>,
    pub total_supply: u256,
}

pub struct AllowanceStorage {
    pub allowances: Map<u256, Map<u256, u256>>,
}

contract Token {
    mut tokens: TokenStorage,
    mut permits: AllowanceStorage,

    recv TokenMsg {
        Transfer { to, amount } -> bool uses (mut tokens) {
            do_transfer(caller(), to, amount)
        }

        Approve { spender, amount } -> bool uses (mut permits) {
            set_allowance(caller(), spender, amount)
            true
        }

        TransferFrom { from, to, amount } -> bool uses (mut tokens, mut permits) {
            // Multiple effects in one handler
            do_transfer_from(caller(), from, to, amount)
        }
    }
}
```

## Effect Scope

Effects declared in a handler's `uses` clause are available throughout that handler:

```fe
//<hide>
use _boilerplate::{Map, caller}
pub struct TokenStorage {
    pub balances: Map<u256, u256>,
}
msg TokenMsg {
    #[selector = 0x12345678]
    Transfer { to: u256, amount: u256 } -> bool,
}
//</hide>

contract Token {
    mut store: TokenStorage,

    recv TokenMsg {
        Transfer { to, amount } -> bool uses (store) {
            // store is available throughout this handler
            let balance = store.balances.get(caller())
            let _ = (to, amount, balance)
            true
        }
    }
}
```

Effects are scoped to the handler that declares them, making it clear what storage each handler accesses.

## Why This Design?

The contract-effect pattern provides:

1. **Explicit dependencies**: Functions declare what storage they need
2. **Testability**: Effects can be mocked in tests
3. **Clarity**: Storage access is always visible in the code
4. **Separation**: Business logic (functions) is separate from state (contracts)

Compare to Solidity:

```solidity
// Solidity - implicit state access
contract Token {
    mapping(address => uint256) balances;

    function transfer(address to, uint256 amount) public {
        balances[msg.sender] -= amount;  // Hidden dependency on contract state
        balances[to] += amount;
    }
}
```

```fe
//<hide>
use _boilerplate::Map
pub struct TokenStorage { pub balances: Map<u256, u256> }
//</hide>

// Fe - explicit effect dependency
fn transfer(to: u256, amount: u256) -> bool uses (mut store: TokenStorage) {
    // Clear that this function needs TokenStorage
    store.balances.set(to, amount)
    true
}
```

## Summary

| Concept | Description |
|---------|-------------|
| Contract field | `mut store: Storage` holds storage as effect |
| Handler `uses` | `uses (store)` accesses storage in handler |
| Multiple effects | `uses (mut a, mut b)` |
| Mutable access | Use `mut` when modifying storage |
