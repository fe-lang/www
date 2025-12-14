---
title: Contract Composition
description: Organizing and structuring Fe contracts
---

Fe's effect system enables clean contract composition through helper functions and modular storage. This section covers patterns for organizing well-structured contracts.

## The Fe Composition Model

Unlike Solidity's inheritance, Fe uses composition through:
- **Standalone functions** with effect dependencies
- **Modular storage structs** for logical separation
- **Multiple recv blocks** for interface organization

```fe ignore
// Modular storage
pub struct BalanceStorage { /* ... */ }
pub struct OwnerStorage { /* ... */ }

// Reusable functions
fn transfer(from: u256, to: u256, amount: u256) uses mut BalanceStorage -> bool { /* ... */ }
fn only_owner() uses OwnerStorage { /* ... */ }

// Contract composes everything
contract Token {
    balances: BalanceStorage,
    ownership: OwnerStorage,
    // ...
}
```

## Helper Functions

Extract business logic into functions that declare their effect dependencies:

```fe ignore
pub struct TokenStorage {
    pub balances: StorageMap<u256, u256>,
    pub total_supply: u256,
}

// Read-only helper
fn get_balance(account: u256) uses TokenStorage -> u256 {
    TokenStorage.balances.get(account)
}

// Mutating helper
fn add_balance(account: u256, amount: u256) uses mut TokenStorage {
    let current = TokenStorage.balances.get(account)
    TokenStorage.balances.set(account, current + amount)
}

fn sub_balance(account: u256, amount: u256) uses mut TokenStorage -> bool {
    let current = TokenStorage.balances.get(account)
    if current < amount {
        return false
    }
    TokenStorage.balances.set(account, current - amount)
    true
}

// Higher-level helper composing lower-level ones
fn transfer(from: u256, to: u256, amount: u256) uses mut TokenStorage -> bool {
    if !sub_balance(from, amount) {
        return false
    }
    add_balance(to, amount)
    true
}
```

## Modular Storage

Split storage into logical units:

```fe ignore
// Core token state
pub struct BalanceStorage {
    pub balances: StorageMap<u256, u256>,
    pub total_supply: u256,
}

// Allowance state
pub struct AllowanceStorage {
    pub allowances: StorageMap<u256, StorageMap<u256, u256>>,
}

// Ownership state
pub struct OwnerStorage {
    pub owner: u256,
}

// Pausability state
pub struct PauseStorage {
    pub paused: bool,
}

contract Token {
    balances: BalanceStorage,
    allowances: AllowanceStorage,
    ownership: OwnerStorage,
    pause_state: PauseStorage,

    // Each handler uses only what it needs
    recv TokenMsg {
        Transfer { to, amount } -> bool {
            with (BalanceStorage = balances, PauseStorage = pause_state) {
                require_not_paused()
                transfer(caller(), to, amount)
            }
        }
    }

    recv AdminMsg {
        Pause { } {
            with (OwnerStorage = ownership, PauseStorage = pause_state) {
                require_owner()
                set_paused(true)
            }
        }
    }
}
```

## Access Control Pattern

Implement access control as a reusable module:

```fe ignore
pub struct OwnerStorage {
    pub owner: u256,
}

fn get_owner() uses OwnerStorage -> u256 {
    OwnerStorage.owner
}

fn require_owner() uses OwnerStorage {
    if caller() != OwnerStorage.owner {
        revert
    }
}

fn transfer_ownership(new_owner: u256) uses mut OwnerStorage {
    require_owner()
    OwnerStorage.owner = new_owner
}

// Use in any contract
contract OwnableToken {
    ownership: OwnerStorage,
    store: TokenStorage,

    init() {
        ownership.owner = caller()
    }

    recv AdminMsg {
        TransferOwnership { new_owner } {
            with (OwnerStorage = ownership) {
                transfer_ownership(new_owner)
            }
        }

        Mint { to, amount } {
            with (OwnerStorage = ownership, TokenStorage = store) {
                require_owner()
                mint_tokens(to, amount)
            }
        }
    }
}
```

## Pausable Pattern

```fe ignore
pub struct PauseStorage {
    pub paused: bool,
}

fn is_paused() uses PauseStorage -> bool {
    PauseStorage.paused
}

fn require_not_paused() uses PauseStorage {
    if PauseStorage.paused {
        revert
    }
}

fn set_paused(paused: bool) uses mut PauseStorage {
    PauseStorage.paused = paused
}

contract PausableToken {
    pause_state: PauseStorage,
    ownership: OwnerStorage,
    store: TokenStorage,

    recv TokenMsg {
        Transfer { to, amount } -> bool {
            with (PauseStorage = pause_state, TokenStorage = store) {
                require_not_paused()
                transfer(caller(), to, amount)
            }
        }
    }

    recv AdminMsg {
        Pause { } {
            with (OwnerStorage = ownership, PauseStorage = pause_state) {
                require_owner()
                set_paused(true)
            }
        }

        Unpause { } {
            with (OwnerStorage = ownership, PauseStorage = pause_state) {
                require_owner()
                set_paused(false)
            }
        }
    }
}
```

## Composing Multiple Effects

Functions can require multiple effects:

```fe ignore
fn guarded_transfer(
    from: u256,
    to: u256,
    amount: u256
) uses mut TokenStorage, PauseStorage, OwnerStorage -> bool {
    require_not_paused()
    // Optionally check ownership or other conditions
    transfer(from, to, amount)
}

contract Token {
    store: TokenStorage,
    pause_state: PauseStorage,
    ownership: OwnerStorage,

    recv TokenMsg {
        Transfer { to, amount } -> bool {
            with (
                TokenStorage = store,
                PauseStorage = pause_state,
                OwnerStorage = ownership
            ) {
                guarded_transfer(caller(), to, amount)
            }
        }
    }
}
```

## File Organization

For larger projects, organize code across files:

```
src/
├── main.fe           # Contract definitions
├── storage.fe        # Storage struct definitions
├── token.fe          # Token-related functions
├── access.fe         # Access control functions
└── pausable.fe       # Pausability functions
```

Each file exports its functions and types for use in the main contract.

## Benefits of Composition

| Aspect | Inheritance (Solidity) | Composition (Fe) |
|--------|------------------------|------------------|
| Reuse | Inherit from base | Import functions |
| State | Mixed in parent | Explicit storage fields |
| Dependencies | Implicit via `super` | Explicit via `uses` |
| Testing | Mock entire contract | Mock individual effects |
| Clarity | Diamond problem risk | Clear function flow |

## Summary

| Pattern | Description |
|---------|-------------|
| Helper functions | Extract logic with `uses` clause |
| Modular storage | Separate storage structs per concern |
| Access control | Reusable ownership/role checking |
| Pausability | Reusable pause state management |
| Multi-effect | Functions requiring multiple effects |
