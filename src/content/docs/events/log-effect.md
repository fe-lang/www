---
title: The Log Effect
description: Why logging is an explicit capability
---

In Fe, logging is an effect—a capability that must be explicitly declared. This makes event emission visible in function signatures and enables powerful patterns for testing and composition.

## Logging as an Effect

Unlike languages where logging is implicit, Fe treats it as a tracked capability:

```fe ignore
pub struct EventLog {}

struct Transfer {
    #[indexed]
    from: u256,
    #[indexed]
    to: u256,
    amount: u256,
}

// This function CAN emit events
fn transfer_with_event(from: u256, to: u256, amount: u256)
    uses (mut TokenStorage, mut EventLog)
{
    // ... transfer logic ...
    EventLog.emit(Transfer { from, to, amount })
}

// This function CANNOT emit events
fn transfer_silent(from: u256, to: u256, amount: u256)
    uses mut TokenStorage
{
    // ... transfer logic only ...
    // EventLog.emit(...) would be a compile error here
}
```

The function signature tells you exactly what the function can do.

## Declaring Log Effects

Define a Log effect as a struct:

```fe ignore
pub struct EventLog {}
```

Use it in function signatures:

```fe ignore
// Read-only logging isn't meaningful, so always use mut
fn emit_transfer(from: u256, to: u256, amount: u256) uses mut EventLog {
    EventLog.emit(Transfer { from, to, amount })
}
```

## Why Explicit Logging?

### Clear Function Contracts

Function signatures reveal side effects:

```fe ignore
// Looking at this signature, you know:
// - It reads Config (immutable)
// - It modifies Balances (mutable)
// - It emits events (mutable EventLog)
fn process_payment(amount: u256)
    uses (Config, mut Balances, mut EventLog)
    -> bool
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

```fe ignore
// Internal helper - no logging
fn update_balance(account: u256, delta: i256) uses mut Balances {
    // Pure state update, no events
}

// Public interface - with logging
fn deposit(account: u256, amount: u256)
    uses (mut Balances, mut EventLog)
{
    update_balance(account, amount as i256)
    EventLog.emit(Deposit { account, amount })
}
```

## Effect Propagation

Functions calling logging functions must declare the effect:

```fe ignore
fn emit_transfer(from: u256, to: u256, amount: u256) uses mut EventLog {
    EventLog.emit(Transfer { from, to, amount })
}

// Must declare EventLog because it calls emit_transfer
fn do_transfer(from: u256, to: u256, amount: u256)
    uses (mut TokenStorage, mut EventLog)
    -> bool
{
    // ... transfer logic ...
    emit_transfer(from, to, amount)  // Requires EventLog effect
    true
}

// Compile error: missing EventLog effect
fn broken_transfer(from: u256, to: u256, amount: u256)
    uses mut TokenStorage
    -> bool
{
    // ... transfer logic ...
    emit_transfer(from, to, amount)  // Error: EventLog not available
    true
}
```

## Binding in Contracts

Contracts provide the Log effect via `with`:

```fe ignore
pub struct EventLog {}

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

## Separate Log Effects

Use different Log effects for different event categories:

```fe ignore
pub struct TransferLog {}
pub struct AdminLog {}

struct Transfer {
    #[indexed]
    from: u256,
    #[indexed]
    to: u256,
    amount: u256,
}

struct OwnershipTransferred {
    #[indexed]
    previous_owner: u256,
    #[indexed]
    new_owner: u256,
}

fn transfer(from: u256, to: u256, amount: u256)
    uses (mut TokenStorage, mut TransferLog)
{
    // ... transfer logic ...
    TransferLog.emit(Transfer { from, to, amount })
}

fn transfer_ownership(new_owner: u256)
    uses (mut AdminStorage, mut AdminLog)
{
    let previous = AdminStorage.owner
    AdminStorage.owner = new_owner
    AdminLog.emit(OwnershipTransferred { previous_owner: previous, new_owner })
}
```

This gives fine-grained control over which functions can emit which events.

## Log Effect Patterns

### Combined Storage and Log

Often storage and its events are paired:

```fe ignore
pub struct TokenStorage {
    pub balances: StorageMap<u256, u256>,
    pub total_supply: u256,
}

pub struct TokenEvents {}

fn mint(to: u256, amount: u256)
    uses (mut TokenStorage, mut TokenEvents)
{
    TokenStorage.balances.set(to, TokenStorage.balances.get(to) + amount)
    TokenStorage.total_supply = TokenStorage.total_supply + amount
    TokenEvents.emit(Transfer { from: 0, to, amount })
}
```

### Event-Only Functions

Some functions exist solely to emit events:

```fe ignore
fn log_debug(message: u256) uses mut DebugLog {
    DebugLog.emit(DebugMessage { value: message })
}
```

### Optional Logging

Make logging optional by separating concerns:

```fe ignore
// Core logic - no logging
fn compute_fee(amount: u256) uses Config -> u256 {
    amount * Config.fee_rate / 10000
}

// With logging wrapper
fn compute_fee_logged(amount: u256)
    uses (Config, mut EventLog)
    -> u256
{
    let fee = compute_fee(amount)
    EventLog.emit(FeeComputed { amount, fee })
    fee
}
```

## Comparison with Implicit Logging

| Aspect | Fe (Explicit) | Implicit Logging |
|--------|---------------|------------------|
| Signature | Shows `uses mut EventLog` | No indication |
| Testing | Easy to mock | Harder to intercept |
| Composition | Fine-grained control | All-or-nothing |
| Refactoring | Compiler catches missing effects | Silent failures |

## Summary

| Concept | Description |
|---------|-------------|
| `pub struct EventLog {}` | Define a log effect type |
| `uses mut EventLog` | Declare logging capability |
| `EventLog.emit(...)` | Emit an event |
| Effect propagation | Callers must declare effects of callees |
| `with (EventLog = field)` | Bind effect in contracts |

Explicit logging effects make your contract's behavior transparent. Every function signature tells the full story of what it can do.
