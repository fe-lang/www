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
fn transfer(from: u256, to: u256, amount: u256) -> bool uses (mut balances: BalanceStorage) {
    let _ = (from, to, amount)
    true
}

fn only_owner() uses (ownership: OwnerStorage) {
    let _ = ownership
}

// Contract composes everything
contract Token {
    balances: BalanceStorage,
    ownership: OwnerStorage,
}
```

## Helper Functions

Extract business logic into functions that declare their effect dependencies:

```fe
//<hide>
use core::StorageMap
//</hide>

pub struct TokenStorage {
    pub balances: StorageMap<u256, u256>,
    pub total_supply: u256,
}

// Read-only helper
fn get_balance(account: u256) -> u256 uses (store: TokenStorage) {
    store.balances.get(account)
}

// Mutating helper
fn add_balance(account: u256, amount: u256) uses (mut store: TokenStorage) {
    let current = store.balances.get(account)
    store.balances.set(account, current + amount)
}

fn sub_balance(account: u256, amount: u256) -> bool uses (mut store: TokenStorage) {
    let current = store.balances.get(account)
    if current < amount {
        return false
    }
    store.balances.set(account, current - amount)
    true
}

// Higher-level helper composing lower-level ones
fn transfer(from: u256, to: u256, amount: u256) -> bool uses (mut store: TokenStorage) {
    if !sub_balance(from, amount) {
        return false
    }
    add_balance(to, amount)
    true
}
```

## Modular Storage

Split storage into logical units:

```fe
//<hide>
use core::{StorageMap, revert}

pub struct Ctx {}
impl Ctx {
    pub fn caller(self) -> u256 { todo() }
}

fn require_not_paused() uses (pause_state: PauseStorage) {
    if pause_state.paused { revert(0, 0) }
}

fn require_owner(expected: u256) uses (ctx: Ctx) {
    if ctx.caller() != expected { revert(0, 0) }
}

fn transfer(from: u256, to: u256, amount: u256) -> bool uses (mut balances: BalanceStorage) {
    let current = balances.balances.get(from)
    if current < amount { return false }
    balances.balances.set(from, current - amount)
    balances.balances.set(to, balances.balances.get(to) + amount)
    true
}

fn set_paused(value: bool) uses (mut pause_state: PauseStorage) {
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
    #[selector = 0xa9059cbb]
    Transfer { to: u256, amount: u256 } -> bool,
}

msg AdminMsg {
    #[selector = 0x8456cb59]
    Pause {} -> bool,
}

contract Token {
    mut balances: BalanceStorage,
    ownership: OwnerStorage,
    mut pause_state: PauseStorage,

    // Each handler uses only what it needs
    recv TokenMsg {
        Transfer { to, amount } -> bool uses (ctx: Ctx, mut balances, pause_state) {
            require_not_paused()
            transfer(ctx.caller(), to, amount)
        }
    }

    recv AdminMsg {
        Pause {} -> bool uses (ctx: Ctx, ownership, mut pause_state) {
            require_owner(ownership.owner)
            set_paused(true)
            true
        }
    }
}
```

## Access Control Pattern

Implement access control as a reusable module:

```fe
//<hide>
use core::{StorageMap, revert}

pub struct TokenStorage {
    pub balances: StorageMap<u256, u256>,
}

pub struct Ctx {}
impl Ctx {
    pub fn caller(self) -> u256 { todo() }
}

fn mint_tokens(to: u256, amount: u256) uses (mut store: TokenStorage) {
    store.balances.set(to, store.balances.get(to) + amount)
}
//</hide>

pub struct OwnerStorage {
    pub owner: u256,
}

fn get_owner() -> u256 uses (ownership: OwnerStorage) {
    ownership.owner
}

fn require_owner() uses (ctx: Ctx, ownership: OwnerStorage) {
    if ctx.caller() != ownership.owner {
        revert(0, 0)
    }
}

fn transfer_ownership(new_owner: u256) uses (ctx: Ctx, mut ownership: OwnerStorage) {
    require_owner()
    ownership.owner = new_owner
}

// Message definitions
msg AdminMsg {
    #[selector = 0xf2fde38b]
    TransferOwnership { new_owner: u256 } -> bool,

    #[selector = 0x40c10f19]
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
use core::{StorageMap, revert}

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
    if ctx.caller() != ownership.owner { revert(0, 0) }
}

fn transfer(from: u256, to: u256, amount: u256) -> bool uses (mut store: TokenStorage) {
    let current = store.balances.get(from)
    if current < amount { return false }
    store.balances.set(from, current - amount)
    store.balances.set(to, store.balances.get(to) + amount)
    true
}

msg TokenMsg {
    #[selector = 0xa9059cbb]
    Transfer { to: u256, amount: u256 } -> bool,
}

msg AdminMsg {
    #[selector = 0x8456cb59]
    Pause {} -> bool,
    #[selector = 0x3f4ba83a]
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
    if pause_state.paused {
        revert(0, 0)
    }
}

fn set_paused(paused: bool) uses (mut pause_state: PauseStorage) {
    pause_state.paused = paused
}

contract PausableToken {
    mut pause_state: PauseStorage,
    ownership: OwnerStorage,
    mut store: TokenStorage,

    recv TokenMsg {
        Transfer { to, amount } -> bool uses (ctx: Ctx, pause_state, mut store) {
            require_not_paused()
            transfer(ctx.caller(), to, amount)
        }
    }

    recv AdminMsg {
        Pause {} -> bool uses (ctx: Ctx, ownership, mut pause_state) {
            require_owner()
            set_paused(true)
            true
        }

        Unpause {} -> bool uses (ctx: Ctx, ownership, mut pause_state) {
            require_owner()
            set_paused(false)
            true
        }
    }
}
```

## Composing Multiple Effects

Functions can require multiple effects:

```fe
//<hide>
use core::{StorageMap, revert}

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
    if pause_state.paused { revert(0, 0) }
}

fn transfer(from: u256, to: u256, amount: u256) -> bool uses (mut store: TokenStorage) {
    let current = store.balances.get(from)
    if current < amount { return false }
    store.balances.set(from, current - amount)
    store.balances.set(to, store.balances.get(to) + amount)
    true
}

msg TokenMsg {
    #[selector = 0xa9059cbb]
    Transfer { to: u256, amount: u256 } -> bool,
}
//</hide>

fn guarded_transfer(
    from: u256,
    to: u256,
    amount: u256
) -> bool uses (mut store: TokenStorage, pause_state: PauseStorage) {
    require_not_paused()
    transfer(from, to, amount)
}

contract Token {
    mut store: TokenStorage,
    pause_state: PauseStorage,
    ownership: OwnerStorage,

    recv TokenMsg {
        Transfer { to, amount } -> bool uses (ctx: Ctx, mut store, pause_state) {
            guarded_transfer(ctx.caller(), to, amount)
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
