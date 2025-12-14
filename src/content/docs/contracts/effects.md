---
title: Contract-Level Effects
description: How contracts provide effects to handlers
---

Contracts bridge the gap between storage and the effect system. Contract fields hold storage, and handlers use `with` expressions to provide those fields as effects to functions.

## The Contract-Effect Relationship

When you declare a contract field with a storage type, that field can be provided as an effect:

```fe ignore
pub struct TokenStorage {
    pub balances: StorageMap<u256, u256>,
    pub total_supply: u256,
}

contract Token {
    store: TokenStorage,  // Field of effect type

    recv TokenMsg {
        BalanceOf { account } -> u256 {
            // Provide 'store' as the TokenStorage effect
            with (TokenStorage = store) {
                TokenStorage.balances.get(account)
            }
        }
    }
}
```

The `with (TokenStorage = store)` expression:
1. Takes the contract field `store`
2. Makes it available as the `TokenStorage` effect
3. Allows code inside the block to use `TokenStorage.field` syntax

## Providing Effects to Functions

The primary use of contract-level effects is providing them to helper functions:

```fe ignore
fn get_balance(account: u256) uses TokenStorage -> u256 {
    TokenStorage.balances.get(account)
}

fn add_balance(account: u256, amount: u256) uses mut TokenStorage {
    let current = TokenStorage.balances.get(account)
    TokenStorage.balances.set(account, current + amount)
}

contract Token {
    store: TokenStorage,

    recv TokenMsg {
        BalanceOf { account } -> u256 {
            with (TokenStorage = store) {
                get_balance(account)
            }
        }

        Transfer { to, amount } -> bool {
            with (TokenStorage = store) {
                add_balance(to, amount)
            }
            true
        }
    }
}
```

## Mutable vs Immutable Effects

Use `mut` when you need to modify storage:

```fe ignore
contract Token {
    store: TokenStorage,

    recv TokenMsg {
        // Read-only: no mut needed
        BalanceOf { account } -> u256 {
            with (TokenStorage = store) {
                TokenStorage.balances.get(account)
            }
        }

        // Writing: mut required
        Transfer { to, amount } -> bool {
            with (TokenStorage = store) {  // mut is inferred from usage
                TokenStorage.balances.set(to, amount)
            }
            true
        }
    }
}
```

When calling functions that require `mut` effects, the `with` block automatically provides mutable access.

## Multiple Effect Fields

Contracts can have multiple fields for different effects:

```fe ignore
pub struct TokenStorage {
    pub balances: StorageMap<u256, u256>,
    pub total_supply: u256,
}

pub struct AllowanceStorage {
    pub allowances: StorageMap<u256, StorageMap<u256, u256>>,
}

contract Token {
    tokens: TokenStorage,
    permits: AllowanceStorage,

    recv TokenMsg {
        Transfer { to, amount } -> bool {
            with (TokenStorage = tokens) {
                do_transfer(caller(), to, amount)
            }
        }

        Approve { spender, amount } -> bool {
            with (AllowanceStorage = permits) {
                set_allowance(caller(), spender, amount)
            }
        }

        TransferFrom { from, to, amount } -> bool {
            // Provide multiple effects
            with (TokenStorage = tokens, AllowanceStorage = permits) {
                do_transfer_from(caller(), from, to, amount)
            }
        }
    }
}
```

## Effect Scope

Effects are only available within their `with` block:

```fe ignore
recv TokenMsg {
    Transfer { to, amount } -> bool {
        with (TokenStorage = store) {
            // TokenStorage is available here
            let balance = TokenStorage.balances.get(caller())
        }
        // TokenStorage is NOT available here
        true
    }
}
```

This explicit scoping makes it clear where storage access occurs.

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

```fe ignore
// Fe - explicit effect dependency
fn transfer(to: u256, amount: u256) uses mut TokenStorage -> bool {
    // Clear that this function needs TokenStorage
    TokenStorage.balances.set(...)
}
```

## Summary

| Concept | Description |
|---------|-------------|
| Contract field | Holds storage, can be provided as effect |
| `with (Effect = field)` | Provides field as an effect |
| Multiple effects | `with (A = a, B = b)` |
| Mutable access | Automatic when calling `mut` functions |
