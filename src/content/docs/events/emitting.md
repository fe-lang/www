---
title: Emitting Events
description: Recording on-chain activity with log.emit()
---

Events are emitted using a Log effect, which records data to the blockchain that external systems can observe. This section covers how to emit events in your Fe contracts.

## The emit Syntax

Emit an event through a Log effect:

```fe
pub struct EventLog {
    // Event logging capability
}

struct Transfer {
    #[indexed]
    from: u256,
    #[indexed]
    to: u256,
    amount: u256,
}

fn emit_transfer(from: u256, to: u256, amount: u256) uses mut EventLog {
    EventLog.emit(Transfer { from, to, amount })
}
```

The `emit` method takes an event struct instance and records it to the blockchain.

## Emitting in Message Handlers

Events are typically emitted within message handlers:

```fe
pub struct TokenStorage {
    pub balances: StorageMap<u256, u256>,
}

pub struct EventLog {}

struct Transfer {
    #[indexed]
    from: u256,
    #[indexed]
    to: u256,
    amount: u256,
}

fn do_transfer(from: u256, to: u256, amount: u256)
    uses (mut TokenStorage, mut EventLog)
    -> bool
{
    let from_bal = TokenStorage.balances.get(from)
    if from_bal < amount {
        return false
    }

    TokenStorage.balances.set(from, from_bal - amount)
    let to_bal = TokenStorage.balances.get(to)
    TokenStorage.balances.set(to, to_bal + amount)

    // Emit event after successful state change
    EventLog.emit(Transfer { from, to, amount })

    true
}
```

## Emit After State Changes

A critical pattern: emit events after state changes succeed, not before:

```fe
fn transfer(from: u256, to: u256, amount: u256)
    uses (mut TokenStorage, mut EventLog)
    -> bool
{
    // 1. Validate
    let from_bal = TokenStorage.balances.get(from)
    if from_bal < amount {
        return false
    }

    // 2. Update state
    TokenStorage.balances.set(from, from_bal - amount)
    TokenStorage.balances.set(to, TokenStorage.balances.get(to) + amount)

    // 3. Emit event (state change succeeded)
    EventLog.emit(Transfer { from, to, amount })

    true
}
```

This ensures events reflect actual state changes.

## Contract Integration

In contracts, bind the EventLog effect like other storage:

```fe
pub struct TokenStorage {
    pub balances: StorageMap<u256, u256>,
}

pub struct EventLog {}

struct Transfer {
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
    store: TokenStorage,
    events: EventLog,

    recv TokenMsg {
        Transfer { to, amount } -> bool {
            with (TokenStorage = store, EventLog = events) {
                do_transfer(caller(), to, amount)
            }
        }
    }
}
```

## Multiple Event Types

Emit different event types from the same handler:

```fe
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
    uses (mut TokenStorage, mut EventLog)
    -> bool
{
    // Check and update allowance
    let allowed = TokenStorage.allowances.get(from).get(spender)
    if allowed < amount {
        return false
    }
    TokenStorage.allowances.get(from).set(spender, allowed - amount)

    // Perform transfer
    let from_bal = TokenStorage.balances.get(from)
    TokenStorage.balances.set(from, from_bal - amount)
    TokenStorage.balances.set(to, TokenStorage.balances.get(to) + amount)

    // Emit both events
    EventLog.emit(Approval {
        owner: from,
        spender,
        amount: allowed - amount,
    })
    EventLog.emit(Transfer { from, to, amount })

    true
}
```

## When to Emit Events

### State Changes

Emit when persistent state changes:

```fe
fn mint(to: u256, amount: u256) uses (mut TokenStorage, mut EventLog) {
    TokenStorage.balances.set(to, TokenStorage.balances.get(to) + amount)
    TokenStorage.total_supply = TokenStorage.total_supply + amount

    EventLog.emit(Transfer { from: 0, to, amount })
}

fn burn(from: u256, amount: u256) uses (mut TokenStorage, mut EventLog) {
    TokenStorage.balances.set(from, TokenStorage.balances.get(from) - amount)
    TokenStorage.total_supply = TokenStorage.total_supply - amount

    EventLog.emit(Transfer { from, to: 0, amount })
}
```

### Administrative Actions

Emit for ownership and configuration changes:

```fe
struct OwnershipTransferred {
    #[indexed]
    previous_owner: u256,
    #[indexed]
    new_owner: u256,
}

fn transfer_ownership(new_owner: u256)
    uses (mut AdminStorage, mut EventLog)
{
    let previous = AdminStorage.owner
    AdminStorage.owner = new_owner

    EventLog.emit(OwnershipTransferred {
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
fn emit_transfer(from: u256, to: u256, amount: u256) uses mut EventLog {
    EventLog.emit(Transfer { from, to, amount })
}

fn emit_approval(owner: u256, spender: u256, amount: u256) uses mut EventLog {
    EventLog.emit(Approval { owner, spender, amount })
}

fn transfer(from: u256, to: u256, amount: u256)
    uses (mut TokenStorage, mut EventLog)
    -> bool
{
    // ... transfer logic ...

    emit_transfer(from, to, amount)
    true
}
```

## Conditional Emission

Only emit when something meaningful happens:

```fe
fn set_approval(owner: u256, spender: u256, new_amount: u256)
    uses (mut TokenStorage, mut EventLog)
{
    let current = TokenStorage.allowances.get(owner).get(spender)

    // Only emit if value actually changes
    if current != new_amount {
        TokenStorage.allowances.get(owner).set(spender, new_amount)
        EventLog.emit(Approval { owner, spender, amount: new_amount })
    }
}
```

## Summary

| Pattern | Description |
|---------|-------------|
| `EventLog.emit(Event { ... })` | Emit an event |
| Emit after state change | Ensures event reflects actual changes |
| Multiple events | Same handler can emit different types |
| Helper functions | Centralize event emission |
| Conditional emit | Only emit on meaningful changes |

Events are your contract's public record. Emit them consistently after successful state changes to enable reliable off-chain indexing.
