---
title: The Log Effect
description: Why logging is an explicit capability
---

In Fe, logging is an effect, a capability that must be explicitly declared. This makes event emission visible in function signatures and enables powerful patterns for testing and composition.

## Logging as an Effect

Unlike languages where logging is implicit, Fe treats it as a tracked capability:

```fe
//<hide>
use _boilerplate::Log
pub struct TokenStorage { pub balances: StorageMap<u256, u256> }
//</hide>

#[event]
struct Transfer {
    #[indexed]
    from: u256,
    #[indexed]
    to: u256,
    amount: u256,
}

impl TokenStorage {
    // This method CAN emit events
    fn transfer_with_event(mut self, from: u256, to: u256, amount: u256)
        uses (log: mut Log)
    {
        // ... transfer logic ...
        //<hide>
        let _ = (from, to, amount)
        //</hide>
        log.emit(event: Transfer { from, to, amount })
    }

    // This method CANNOT emit events
    fn transfer_silent(mut self, from: u256, to: u256, amount: u256) {
        // ... transfer logic only ...
        // log.emit(...) would be a compile error here
        //<hide>
        let _ = (from, to, amount)
        //</hide>
    }
}
```

Use it in function signatures:

```fe
//<hide>
use _boilerplate::Log
#[event]
struct Transfer {
    #[indexed]
    from: u256,
    #[indexed]
    to: u256,
    amount: u256,
}
//</hide>

// Read-only logging isn't meaningful, so always use mut
fn emit_transfer(from: u256, to: u256, amount: u256) uses (log: mut Log) {
    log.emit(event: Transfer { from, to, amount })
}
```

## Why Explicit Logging?

### Clear Function Contracts

Function signatures reveal side effects:

```fe
//<hide>
use _boilerplate::Log
pub struct Config { pub fee: u256 }
pub struct Balances { pub data: u256 }
//</hide>

// Looking at this signature, you know:
// - It reads Config (immutable)
// - It modifies Balances (mutable)
// - It emits events (mutable Log)
fn process_payment(amount: u256)
    -> bool uses (config: Config, balances: mut Balances, log: mut Log)
{
    //<hide>
    let _ = (amount, config, balances, log)
    //</hide>
    true
}
```

In Solidity, you'd need to read the implementation to know if events are emitted.

### Testability

Mock or replace the Log effect in tests:

```fe ignore
pub struct MockEventLog {
    pub events: Vec<u256>,  // Track emitted events
}

fn test_transfer() {
    let storage = TokenStorage { ... }
    let mock_log = MockEventLog { events: Vec::new() }

    with (TokenStorage = storage, EventLog = mock_log) {
        transfer(alice, bob, 100)
    }

    // Verify events were emitted
    assert(mock_log.events.len() == 1)
}
```

### Composition Control

Compose functions while controlling which can log:

```fe
//<hide>
use _boilerplate::Log
pub struct Balances { pub data: u256 }
#[event]
struct Deposit {
    #[indexed]
    account: u256,
    amount: u256,
}
//</hide>

impl Balances {
    // Internal helper - no logging
    fn update_balance(mut self, account: u256, delta: u256) {
        // Pure state update, no events
        //<hide>
        let _ = (account, delta)
        //</hide>
    }

    // Public interface - with logging
    fn deposit(mut self, account: u256, amount: u256) uses (log: mut Log) {
        self.update_balance(account, delta: amount)
        log.emit(event: Deposit { account, amount })
    }
}
```

## Effect Propagation

Functions calling logging functions must declare the effect:

```fe
//<hide>
use _boilerplate::Log
pub struct TokenStorage { pub balances: StorageMap<u256, u256> }
#[event]
struct Transfer {
    #[indexed]
    from: u256,
    #[indexed]
    to: u256,
    amount: u256,
}
//</hide>

fn emit_transfer(from: u256, to: u256, amount: u256) uses (log: mut Log) {
    log.emit(event: Transfer { from, to, amount })
}

impl TokenStorage {
    // Must declare Log because it calls emit_transfer
    fn do_transfer(mut self, from: u256, to: u256, amount: u256)
        -> bool uses (log: mut Log)
    {
        // ... transfer logic ...
        //<hide>
        let _ = (from, to, amount)
        //</hide>
        emit_transfer(from, to, amount)  // Requires Log effect
        true
    }
}
```

```fe ignore
// Compile error: missing Log effect
impl TokenStorage {
    fn broken_transfer(mut self, from: u256, to: u256, amount: u256) -> bool {
        // ... transfer logic ...
        emit_transfer(from, to, amount)  // Error: Log not available
        true
    }
}
```

## Binding in Contracts

Contracts provide the Log effect via the `uses` clause on handlers:

```fe
//<hide>
use std::abi::sol
use _boilerplate::{Log, caller}
pub struct TokenStorage { pub balances: StorageMap<u256, u256> }
impl TokenStorage {
    fn do_transfer(mut self, from: u256, to: u256, amount: u256) -> bool uses (log: mut Log) {
        let _ = (from, to, amount, log)
        true
    }
}
msg TokenMsg {
    #[selector = sol("transfer(address,uint256)")]
    Transfer { to: u256, amount: u256 } -> bool,
}
//</hide>

contract Token uses (log: mut Log) {
    mut store: TokenStorage,

    recv TokenMsg {
        Transfer { to, amount } -> bool uses (mut store, mut log) {
            store.do_transfer(from: caller(), to, amount)
        }
    }
}
```

## Separate Log Effects

Use different Log effects for different event categories:

```fe
//<hide>
pub struct TokenStorage { pub balances: StorageMap<u256, u256> }
pub struct AdminStorage { pub owner: u256 }
//</hide>

pub struct TransferLog {}
impl TransferLog {
    pub fn emit<T>(self, event: T) { todo() }
}

pub struct AdminLog {}
impl AdminLog {
    pub fn emit<T>(self, event: T) { todo() }
}

#[event]
struct Transfer {
    #[indexed]
    from: u256,
    #[indexed]
    to: u256,
    amount: u256,
}

#[event]
struct OwnershipTransferred {
    #[indexed]
    previous_owner: u256,
    #[indexed]
    new_owner: u256,
}

impl TokenStorage {
    fn transfer(mut self, from: u256, to: u256, amount: u256)
        uses (log: mut TransferLog)
    {
        // ... transfer logic ...
        //<hide>
        let _ = (from, to, amount)
        //</hide>
        log.emit(event: Transfer { from, to, amount })
    }
}

impl AdminStorage {
    fn transfer_ownership(mut self, new_owner: u256) uses (log: mut AdminLog) {
        let previous = self.owner
        self.owner = new_owner
        log.emit(event: OwnershipTransferred { previous_owner: previous, new_owner })
    }
}
```

This gives fine-grained control over which functions can emit which events.

## Log Effect Patterns

### Combined Storage and Log

Often storage and its events are paired:

```fe
//<hide>
#[event]
struct Transfer {
    #[indexed]
    from: u256,
    #[indexed]
    to: u256,
    amount: u256,
}
//</hide>

pub struct TokenStorage {
    pub balances: StorageMap<u256, u256>,
    pub total_supply: u256,
}

pub struct TokenEvents {}
impl TokenEvents {
    pub fn emit<T>(self, event: T) { todo() }
}

impl TokenStorage {
    fn mint(mut self, to: u256, amount: u256) uses (log: mut TokenEvents) {
        self.balances.set(key: to, value: self.balances.get(key: to) + amount)
        self.total_supply = self.total_supply + amount
        log.emit(event: Transfer { from: 0, to, amount })
    }
}
```

### Event-Only Functions

Some functions exist solely to emit events:

```fe
pub struct DebugLog {}
impl DebugLog {
    pub fn emit<T>(self, event: T) { todo() }
}

struct DebugMessage {
    value: u256,
}

fn log_debug(message: u256) uses (log: mut DebugLog) {
    log.emit(event: DebugMessage { value: message })
}
```

### Optional Logging

Make logging optional by separating concerns:

```fe
//<hide>
use _boilerplate::Log
struct FeeComputed {
    amount: u256,
    fee: u256,
}
//</hide>

pub struct Config { pub fee_rate: u256 }

impl Config {
    // Core logic - no logging
    fn compute_fee(self, amount: u256) -> u256 {
        amount * self.fee_rate / 10000
    }

    // With logging wrapper
    fn compute_fee_logged(self, amount: u256) -> u256 uses (log: mut Log) {
        let fee = self.compute_fee(amount)
        log.emit(event: FeeComputed { amount, fee })
        fee
    }
}
```

## Comparison with Implicit Logging

| Aspect | Fe (Explicit) | Implicit Logging |
|--------|---------------|------------------|
| Signature | Shows `uses (log: mut Log)` | No indication |
| Testing | Easy to mock | Harder to intercept |
| Composition | Fine-grained control | All-or-nothing |
| Refactoring | Compiler catches missing effects | Silent failures |

## Summary

| Concept | Description |
|---------|-------------|
| `pub struct Log {}` | Define a log effect type |
| `uses (log: mut Log)` | Declare logging capability |
| `log.emit(...)` | Emit an event |
| Effect propagation | Callers must declare effects of callees |
| Handler `uses` | Bind effect in contract handlers |

Explicit logging effects make your contract's behavior transparent. Every function signature tells the full story of what it can do.
