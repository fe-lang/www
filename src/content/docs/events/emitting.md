---
title: Emitting Events
description: Recording on-chain activity with log.emit()
---

Events are emitted using a Log effect, which records data to the blockchain that external systems can observe. This section covers how to emit events in your Fe contracts.

## The emit Syntax

Emit an event through a Log effect:

```fe
pub struct Log {}
impl Log {
    pub fn emit<T>(self, event: T) { todo() }
}

struct Transfer {
    #[indexed]
    from: u256,
    #[indexed]
    to: u256,
    amount: u256,
}

fn emit_transfer(from: u256, to: u256, amount: u256) uses (mut log: Log) {
    log.emit(Transfer { from, to, amount })
}
```

The `emit` method takes an event struct instance and records it to the blockchain.

## Emitting in Message Handlers

Events are typically emitted within message handlers:

```fe
//<hide>
use _boilerplate::{Map, Log}
//</hide>

pub struct TokenStorage {
    pub balances: Map<u256, u256>,
}

struct Transfer {
    #[indexed]
    from: u256,
    #[indexed]
    to: u256,
    amount: u256,
}

fn do_transfer(from: u256, to: u256, amount: u256)
    -> bool uses (mut store: TokenStorage, mut log: Log)
{
    let from_bal = store.balances.get(from)
    if from_bal < amount {
        return false
    }

    store.balances.set(from, from_bal - amount)
    let to_bal = store.balances.get(to)
    store.balances.set(to, to_bal + amount)

    // Emit event after successful state change
    log.emit(Transfer { from, to, amount })

    true
}
```

## Emit After State Changes

A critical pattern: emit events after state changes succeed, not before:

```fe
//<hide>
use _boilerplate::{Map, Log}
pub struct TokenStorage { pub balances: Map<u256, u256> }
struct Transfer {
    #[indexed]
    from: u256,
    #[indexed]
    to: u256,
    amount: u256,
}
//</hide>

fn transfer(from: u256, to: u256, amount: u256)
    -> bool uses (mut store: TokenStorage, mut log: Log)
{
    // 1. Validate
    let from_bal = store.balances.get(from)
    if from_bal < amount {
        return false
    }

    // 2. Update state
    store.balances.set(from, from_bal - amount)
    store.balances.set(to, store.balances.get(to) + amount)

    // 3. Emit event (state change succeeded)
    log.emit(Transfer { from, to, amount })

    true
}
```

This ensures events reflect actual state changes.

## Contract Integration

In contracts, declare storage and log as contract fields, then access them via `uses`:

```fe
//<hide>
use _boilerplate::{Map, Log, caller}
fn do_transfer(c: u256, to: u256, amount: u256) -> bool uses (mut store: TokenStorage, mut log: Log) {
    let _ = (c, to, amount, store, log)
    true
}
//</hide>

pub struct TokenStorage {
    pub balances: Map<u256, u256>,
}

struct TransferEvent {
    #[indexed]
    from: u256,
    #[indexed]
    to: u256,
    amount: u256,
}

msg TokenMsg {
    #[selector = 0xa9059cbb]
    Transfer { to: u256, amount: u256 } -> bool,
}

contract Token {
    mut store: TokenStorage,
    mut log: Log,

    recv TokenMsg {
        Transfer { to, amount } -> bool uses (mut store, mut log) {
            do_transfer(caller(), to, amount)
        }
    }
}
```

## Multiple Event Types

Emit different event types from the same handler:

```fe
//<hide>
use _boilerplate::{Map, Log}
pub struct TokenStorage {
    pub balances: Map<u256, u256>,
    pub allowances: Map<u256, Map<u256, u256>>,
}
//</hide>

struct Transfer {
    #[indexed]
    from: u256,
    #[indexed]
    to: u256,
    amount: u256,
}

struct Approval {
    #[indexed]
    owner: u256,
    #[indexed]
    spender: u256,
    amount: u256,
}

fn transfer_from(spender: u256, from: u256, to: u256, amount: u256)
    -> bool uses (mut store: TokenStorage, mut log: Log)
{
    // Check and update allowance
    let allowed = store.allowances.get(from).get(spender)
    if allowed < amount {
        return false
    }
    store.allowances.get(from).set(spender, allowed - amount)

    // Perform transfer
    let from_bal = store.balances.get(from)
    store.balances.set(from, from_bal - amount)
    store.balances.set(to, store.balances.get(to) + amount)

    // Emit both events
    log.emit(Approval {
        owner: from,
        spender,
        amount: allowed - amount,
    })
    log.emit(Transfer { from, to, amount })

    true
}
```

## When to Emit Events

### State Changes

Emit when persistent state changes:

```fe
//<hide>
use _boilerplate::{Map, Log}
pub struct TokenStorage {
    pub balances: Map<u256, u256>,
    pub total_supply: u256,
}
struct Transfer {
    #[indexed]
    from: u256,
    #[indexed]
    to: u256,
    amount: u256,
}
//</hide>

fn mint(to: u256, amount: u256) uses (mut store: TokenStorage, mut log: Log) {
    store.balances.set(to, store.balances.get(to) + amount)
    store.total_supply = store.total_supply + amount

    log.emit(Transfer { from: 0, to, amount })
}

fn burn(from: u256, amount: u256) uses (mut store: TokenStorage, mut log: Log) {
    store.balances.set(from, store.balances.get(from) - amount)
    store.total_supply = store.total_supply - amount

    log.emit(Transfer { from, to: 0, amount })
}
```

### Administrative Actions

Emit for ownership and configuration changes:

```fe
//<hide>
use _boilerplate::Log
pub struct AdminStorage { pub owner: u256 }
//</hide>

struct OwnershipTransferred {
    #[indexed]
    previous_owner: u256,
    #[indexed]
    new_owner: u256,
}

fn transfer_ownership(new_owner: u256)
    uses (mut admin: AdminStorage, mut log: Log)
{
    let previous = admin.owner
    admin.owner = new_owner

    log.emit(OwnershipTransferred {
        previous_owner: previous,
        new_owner,
    })
}
```

### Significant Read Operations

Occasionally emit for important queries (use sparingly):

```fe
struct BalanceChecked {
    #[indexed]
    account: u256,
    balance: u256,
}

// Usually not needed - avoid unless there's a specific reason
```

## Event Helpers

Create helper functions for common events:

```fe
//<hide>
use _boilerplate::{Map, Log}
pub struct TokenStorage { pub balances: Map<u256, u256> }
struct Transfer {
    #[indexed]
    from: u256,
    #[indexed]
    to: u256,
    amount: u256,
}
struct Approval {
    #[indexed]
    owner: u256,
    #[indexed]
    spender: u256,
    amount: u256,
}
//</hide>

fn emit_transfer(from: u256, to: u256, amount: u256) uses (mut log: Log) {
    log.emit(Transfer { from, to, amount })
}

fn emit_approval(owner: u256, spender: u256, amount: u256) uses (mut log: Log) {
    log.emit(Approval { owner, spender, amount })
}

fn transfer(from: u256, to: u256, amount: u256)
    -> bool uses (mut store: TokenStorage, mut log: Log)
{
    // ... transfer logic ...
    //<hide>
    let _ = (from, to, amount, store)
    //</hide>

    emit_transfer(from, to, amount)
    true
}
```

## Conditional Emission

Only emit when something meaningful happens:

```fe
//<hide>
use _boilerplate::{Map, Log}
pub struct TokenStorage { pub allowances: Map<u256, Map<u256, u256>> }
struct Approval {
    #[indexed]
    owner: u256,
    #[indexed]
    spender: u256,
    amount: u256,
}
//</hide>

fn set_approval(owner: u256, spender: u256, new_amount: u256)
    uses (mut store: TokenStorage, mut log: Log)
{
    let current = store.allowances.get(owner).get(spender)

    // Only emit if value actually changes
    if current != new_amount {
        store.allowances.get(owner).set(spender, new_amount)
        log.emit(Approval { owner, spender, amount: new_amount })
    }
}
```

## Summary

| Pattern | Description |
|---------|-------------|
| `log.emit(Event { ... })` | Emit an event |
| Emit after state change | Ensures event reflects actual changes |
| Multiple events | Same handler can emit different types |
| Helper functions | Centralize event emission |
| Conditional emit | Only emit on meaningful changes |

Events are your contract's public record. Emit them consistently after successful state changes to enable reliable off-chain indexing.
