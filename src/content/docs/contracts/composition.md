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

```fe
// Modular storage
pub struct BalanceStorage { pub total: u256 }
pub struct OwnerStorage { pub owner: u256 }

// Reusable functions
fn transfer(from: u256, to: u256, amount: u256) -> bool uses (balances: mut BalanceStorage) {
    let _ = (from, to, amount)
    true
}

fn only_owner() uses (ownership: OwnerStorage) {
    let _ = ownership
}

// Contract composes everything
contract Token {
    mut balances: BalanceStorage,
    mut ownership: OwnerStorage,
}
```

## Helper Functions

Extract business logic into functions that declare their effect dependencies:

```fe
pub struct TokenStorage {
    pub balances: StorageMap<u256, u256>,
    pub total_supply: u256,
}

// Read-only helper
fn get_balance(account: u256) -> u256 uses (store: TokenStorage) {
    store.balances.get(key: account)
}

// Mutating helper
fn add_balance(account: u256, amount: u256) uses (store: mut TokenStorage) {
    let current = store.balances.get(key: account)
    store.balances.set(key: account, value: current + amount)
}

fn sub_balance(account: u256, amount: u256) -> bool uses (store: mut TokenStorage) {
    let current = store.balances.get(key: account)
    if current < amount {
        return false
    }
    store.balances.set(key: account, value: current - amount)
    true
}

// Higher-level helper composing lower-level ones
fn transfer(from: u256, to: u256, amount: u256) -> bool uses (store: mut TokenStorage) {
    if !sub_balance(account: from, amount) {
        return false
    }
    add_balance(account: to, amount)
    true
}
```

## Modular Storage

Split storage into logical units:

```fe
//<hide>
use std::abi::sol
pub struct Ctx {}
impl Ctx {
    pub fn caller(self) -> u256 { todo() }
}

fn require_not_paused() uses (pause_state: PauseStorage) {
    assert!(!pause_state.paused, "paused")
}

fn require_owner(expected: u256) uses (ctx: Ctx) {
    assert!(ctx.caller() == expected, "not owner")
}

fn transfer(from: u256, to: u256, amount: u256) -> bool uses (balances: mut BalanceStorage) {
    let current = balances.balances.get(key: from)
    if current < amount { return false }
    balances.balances.set(key: from, value: current - amount)
    balances.balances.set(key: to, value: balances.balances.get(key: to) + amount)
    true
}

fn set_paused(value: bool) uses (pause_state: mut PauseStorage) {
    pause_state.paused = value
}
//</hide>

// Core token state
pub struct BalanceStorage {
    pub balances: StorageMap<u256, u256>,
    pub total_supply: u256,
}

// Ownership state
pub struct OwnerStorage {
    pub owner: u256,
}

// Pausability state
pub struct PauseStorage {
    pub paused: bool,
}

// Message definitions
msg TokenMsg {
    #[selector = sol("transfer(address,uint256)")]
    Transfer { to: u256, amount: u256 } -> bool,
}

msg AdminMsg {
    #[selector = sol("pause()")]
    Pause {} -> bool,
}

contract Token {
    mut balances: BalanceStorage,
    mut ownership: OwnerStorage,
    mut pause_state: PauseStorage,

    // Each handler uses only what it needs
    recv TokenMsg {
        Transfer { to, amount } -> bool uses (ctx: Ctx, mut balances, pause_state) {
            require_not_paused()
            transfer(from: ctx.caller(), to, amount)
        }
    }

    recv AdminMsg {
        Pause {} -> bool uses (ctx: Ctx, ownership, mut pause_state) {
            require_owner(expected: ownership.owner)
            set_paused(value: true)
            true
        }
    }
}
```

## Access Control Pattern

Implement access control as a reusable module:

```fe
//<hide>
use std::abi::sol
pub struct TokenStorage {
    pub balances: StorageMap<u256, u256>,
}

pub struct Ctx {}
impl Ctx {
    pub fn caller(self) -> u256 { todo() }
}

fn mint_tokens(to: u256, amount: u256) uses (store: mut TokenStorage) {
    store.balances.set(key: to, value: store.balances.get(key: to) + amount)
}
//</hide>

pub struct OwnerStorage {
    pub owner: u256,
}

fn get_owner() -> u256 uses (ownership: OwnerStorage) {
    ownership.owner
}

fn require_owner() uses (ctx: Ctx, ownership: OwnerStorage) {
    assert!(ctx.caller() == ownership.owner, "not owner")
}

fn transfer_ownership(new_owner: u256) uses (ctx: Ctx, ownership: mut OwnerStorage) {
    require_owner()
    ownership.owner = new_owner
}

// Message definitions
msg AdminMsg {
    #[selector = sol("transferOwnership(address)")]
    TransferOwnership { new_owner: u256 } -> bool,

    #[selector = sol("mint(address,uint256)")]
    Mint { to: u256, amount: u256 } -> bool,
}

// Use in any contract
contract OwnableToken {
    mut ownership: OwnerStorage,
    mut store: TokenStorage,

    init() uses (ctx: Ctx, mut ownership) {
        ownership.owner = ctx.caller()
    }

    recv AdminMsg {
        TransferOwnership { new_owner } -> bool uses (ctx: Ctx, mut ownership) {
            transfer_ownership(new_owner)
            true
        }

        Mint { to, amount } -> bool uses (ctx: Ctx, ownership, mut store) {
            require_owner()
            mint_tokens(to, amount)
            true
        }
    }
}
```

## Pausable Pattern

```fe
//<hide>
use std::abi::sol
pub struct TokenStorage {
    pub balances: StorageMap<u256, u256>,
}

pub struct OwnerStorage {
    pub owner: u256,
}

pub struct Ctx {}
impl Ctx {
    pub fn caller(self) -> u256 { todo() }
}

fn require_owner() uses (ctx: Ctx, ownership: OwnerStorage) {
    assert!(ctx.caller() == ownership.owner, "not owner")
}

fn transfer(from: u256, to: u256, amount: u256) -> bool uses (store: mut TokenStorage) {
    let current = store.balances.get(key: from)
    if current < amount { return false }
    store.balances.set(key: from, value: current - amount)
    store.balances.set(key: to, value: store.balances.get(key: to) + amount)
    true
}

msg TokenMsg {
    #[selector = sol("transfer(address,uint256)")]
    Transfer { to: u256, amount: u256 } -> bool,
}

msg AdminMsg {
    #[selector = sol("pause()")]
    Pause {} -> bool,
    #[selector = sol("unpause()")]
    Unpause {} -> bool,
}
//</hide>

pub struct PauseStorage {
    pub paused: bool,
}

fn is_paused() -> bool uses (pause_state: PauseStorage) {
    pause_state.paused
}

fn require_not_paused() uses (pause_state: PauseStorage) {
    assert!(!pause_state.paused, "paused")
}

fn set_paused(paused: bool) uses (pause_state: mut PauseStorage) {
    pause_state.paused = paused
}

contract PausableToken {
    mut pause_state: PauseStorage,
    mut ownership: OwnerStorage,
    mut store: TokenStorage,

    recv TokenMsg {
        Transfer { to, amount } -> bool uses (ctx: Ctx, pause_state, mut store) {
            require_not_paused()
            transfer(from: ctx.caller(), to, amount)
        }
    }

    recv AdminMsg {
        Pause {} -> bool uses (ctx: Ctx, ownership, mut pause_state) {
            require_owner()
            set_paused(paused: true)
            true
        }

        Unpause {} -> bool uses (ctx: Ctx, ownership, mut pause_state) {
            require_owner()
            set_paused(paused: false)
            true
        }
    }
}
```

## Composing Multiple Effects

Functions can require multiple effects:

```fe
//<hide>
use std::abi::sol
pub struct TokenStorage {
    pub balances: StorageMap<u256, u256>,
}

pub struct OwnerStorage {
    pub owner: u256,
}

pub struct PauseStorage {
    pub paused: bool,
}

pub struct Ctx {}
impl Ctx {
    pub fn caller(self) -> u256 { todo() }
}

fn require_not_paused() uses (pause_state: PauseStorage) {
    assert!(!pause_state.paused, "paused")
}

fn transfer(from: u256, to: u256, amount: u256) -> bool uses (store: mut TokenStorage) {
    let current = store.balances.get(key: from)
    if current < amount { return false }
    store.balances.set(key: from, value: current - amount)
    store.balances.set(key: to, value: store.balances.get(key: to) + amount)
    true
}

msg TokenMsg {
    #[selector = sol("transfer(address,uint256)")]
    Transfer { to: u256, amount: u256 } -> bool,
}
//</hide>

fn guarded_transfer(
    from: u256,
    to: u256,
    amount: u256
) -> bool uses (store: mut TokenStorage, pause_state: PauseStorage) {
    require_not_paused()
    transfer(from, to, amount)
}

contract Token {
    mut store: TokenStorage,
    mut pause_state: PauseStorage,
    mut ownership: OwnerStorage,

    recv TokenMsg {
        Transfer { to, amount } -> bool uses (ctx: Ctx, mut store, pause_state) {
            guarded_transfer(from: ctx.caller(), to, amount)
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
