---
title: Emitting Events
description: Recording on-chain activity with log.emit()
---

Events are emitted using a Log effect, which records data to the blockchain that external systems can observe. This section covers how to emit events in your Fe contracts.

## The emit Syntax

Emit an event through a Log effect:

```fe
//<hide>
use _boilerplate::Log
//</hide>


#[event]
struct Transfer {
    #[indexed]
    from: u256,
    #[indexed]
    to: u256,
    amount: u256,
}

fn emit_transfer(from: u256, to: u256, amount: u256) uses (log: mut Log) {
    log.emit(Transfer { from, to, amount })
}
```

The `emit` method takes an event struct instance and records it to the blockchain.

## Emitting in Message Handlers

Events are typically emitted within message handlers:

```fe
//<hide>
use _boilerplate::Log
//</hide>

pub struct TokenStorage {
    pub balances: StorageMap<u256, u256>,
}

#[event]
struct Transfer {
    #[indexed]
    from: u256,
    #[indexed]
    to: u256,
    amount: u256,
}

impl TokenStorage {
    fn do_transfer(mut self, from: u256, to: u256, amount: u256)
        -> bool uses (log: mut Log)
    {
        let from_bal = self.balances.get(from)
        if from_bal < amount {
            return false
        }

        self.balances.set(from, from_bal - amount)
        let to_bal = self.balances.get(to)
        self.balances.set(to, to_bal + amount)

        // Emit event after successful state change
        log.emit(Transfer { from, to, amount })

        true
    }
}
```

## Emit After State Changes

A critical pattern: emit events after state changes succeed, not before:

```fe
pub struct TokenStorage {
    pub balances: StorageMap<u256, u256>,
}

#[event]
struct Transfer {
    #[indexed]
    from: u256,
    #[indexed]
    to: u256,
    amount: u256,
}

impl TokenStorage {
    fn transfer(mut self, from: u256, to: u256, amount: u256)
        -> bool uses (log: mut Log)
    {
        // 1. Validate
        let from_bal = self.balances.get(from)
        if from_bal < amount {
            return false
        }

        // 2. Update state
        self.balances.set(from, from_bal - amount)
        self.balances.set(to, self.balances.get(to) + amount)

        // 3. Emit event (state change succeeded)
        log.emit(Transfer { from, to, amount })

        true
    }
}
```

This ensures events reflect actual state changes.

## Contract Integration

In contracts, declare storage and log as contract fields, then access them via `uses`:

```fe
//<hide>
use std::abi::sol
use _boilerplate::{Log, caller}
//</hide>

pub struct TokenStorage {
    pub balances: StorageMap<u256, u256>,
}

impl TokenStorage {
    fn do_transfer(mut self, from: u256, to: u256, amount: u256) -> bool uses (log: mut Log) {
        //<hide>
        let _ = (from, to, amount, log)
        //</hide>
        true
    }
}

#[event]
struct TransferEvent {
    #[indexed]
    from: u256,
    #[indexed]
    to: u256,
    amount: u256,
}

msg TokenMsg {
    #[selector = sol("transfer(address,uint256)")]
    Transfer { to: u256, amount: u256 } -> bool,
}

contract Token uses (log: mut Log) {
    mut store: TokenStorage,

    recv TokenMsg {
        Transfer { to, amount } -> bool uses (mut store, mut log) {
            store.do_transfer(caller(), to, amount)
        }
    }
}
```

## Multiple Event Types

Emit different event types from the same handler:

```fe
//<hide>
pub struct TokenStorage {
    pub balances: StorageMap<u256, u256>,
    pub allowances: StorageMap<(u256, u256), u256>,
}
//</hide>

#[event]
struct Transfer {
    #[indexed]
    from: u256,
    #[indexed]
    to: u256,
    amount: u256,
}

#[event]
struct Approval {
    #[indexed]
    owner: u256,
    #[indexed]
    spender: u256,
    amount: u256,
}

impl TokenStorage {
    fn transfer_from(mut self, spender: u256, from: u256, to: u256, amount: u256)
        -> bool uses (log: mut Log)
    {
        // Check and update allowance
        let allowed = self.allowances.get((from, spender))
        if allowed < amount {
            return false
        }
        self.allowances.set((from, spender), allowed - amount)

        // Perform transfer
        let from_bal = self.balances.get(from)
        self.balances.set(from, from_bal - amount)
        self.balances.set(to, self.balances.get(to) + amount)

        // Emit both events
        log.emit(Approval {
            owner: from,
            spender,
            amount: allowed - amount,
        })
        log.emit(Transfer { from, to, amount })

        true
    }
}
```

## When to Emit Events

### State Changes

Emit when persistent state changes:

```fe
//<hide>
pub struct TokenStorage {
    pub balances: StorageMap<u256, u256>,
    pub total_supply: u256,
}
#[event]
struct Transfer {
    #[indexed]
    from: u256,
    #[indexed]
    to: u256,
    amount: u256,
}
//</hide>

impl TokenStorage {
    fn mint(mut self, to: u256, amount: u256) uses (log: mut Log) {
        self.balances.set(to, self.balances.get(to) + amount)
        self.total_supply = self.total_supply + amount

        log.emit(Transfer { from: 0, to, amount })
    }

    fn burn(mut self, from: u256, amount: u256) uses (log: mut Log) {
        self.balances.set(from, self.balances.get(from) - amount)
        self.total_supply = self.total_supply - amount

        log.emit(Transfer { from, to: 0, amount })
    }
}
```

### Administrative Actions

Emit for ownership and configuration changes:

```fe
//<hide>
use _boilerplate::Log
pub struct AdminStorage { pub owner: u256 }
//</hide>

#[event]
struct OwnershipTransferred {
    #[indexed]
    previous_owner: u256,
    #[indexed]
    new_owner: u256,
}

impl AdminStorage {
    fn transfer_ownership(mut self, new_owner: u256) uses (log: mut Log) {
        let previous = self.owner
        self.owner = new_owner

        log.emit(OwnershipTransferred {
            previous_owner: previous,
            new_owner,
        })
    }
}
```

### Significant Read Operations

Occasionally emit for important queries (use sparingly):

```fe
#[event]
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
pub struct TokenStorage { pub balances: StorageMap<u256, u256> }
#[event]
struct Transfer {
    #[indexed]
    from: u256,
    #[indexed]
    to: u256,
    amount: u256,
}
#[event]
struct Approval {
    #[indexed]
    owner: u256,
    #[indexed]
    spender: u256,
    amount: u256,
}
//</hide>

fn emit_transfer(from: u256, to: u256, amount: u256) uses (log: mut Log) {
    log.emit(Transfer { from, to, amount })
}

fn emit_approval(owner: u256, spender: u256, amount: u256) uses (log: mut Log) {
    log.emit(Approval { owner, spender, amount })
}

impl TokenStorage {
    fn transfer(mut self, from: u256, to: u256, amount: u256)
        -> bool uses (log: mut Log)
    {
        // ... transfer logic ...
        //<hide>
        let _ = (from, to, amount)
        //</hide>

        emit_transfer(from, to, amount)
        true
    }
}
```

## Conditional Emission

Only emit when something meaningful happens:

```fe
//<hide>
pub struct TokenStorage { pub allowances: StorageMap<(u256, u256), u256> }
#[event]
struct Approval {
    #[indexed]
    owner: u256,
    #[indexed]
    spender: u256,
    amount: u256,
}
//</hide>

impl TokenStorage {
    fn set_approval(mut self, owner: u256, spender: u256, new_amount: u256)
        uses (log: mut Log)
    {
        let current = self.allowances.get((owner, spender))

        // Only emit if value actually changes
        if current != new_amount {
            self.allowances.set((owner, spender), new_amount)
            log.emit(Approval { owner, spender, amount: new_amount })
        }
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
