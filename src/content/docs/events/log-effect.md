---
title: The Log Effect
description: Why logging is an explicit capability
---

In Fe, logging is an effect, a capability that must be explicitly declared. This makes event emission visible in function signatures and enables powerful patterns for testing and composition.

## Logging as an Effect

Unlike languages where logging is implicit, Fe treats it as a tracked capability:

```fe
//<hide>
use _boilerplate::Map
pub struct TokenStorage { pub balances: Map<u256, u256> }
//</hide>

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

// This function CAN emit events
fn transfer_with_event(from: u256, to: u256, amount: u256)
    uses (mut store: TokenStorage, mut log: Log)
{
    // ... transfer logic ...
    //<hide>
    let _ = (from, to, amount, store)
    //</hide>
    log.emit(Transfer { from, to, amount })
}

// This function CANNOT emit events
fn transfer_silent(from: u256, to: u256, amount: u256)
    uses (mut store: TokenStorage)
{
    // ... transfer logic only ...
    // log.emit(...) would be a compile error here
    //<hide>
    let _ = (from, to, amount, store)
    //</hide>
}
```

The function signature tells you exactly what the function can do.

## Declaring Log Effects

Define a Log effect as a struct:

```fe
pub struct Log {}
impl Log {
    pub fn emit<T>(self, event: T) { todo() }
}
```

Use it in function signatures:

```fe
//<hide>
use _boilerplate::Log
struct Transfer {
    #[indexed]
    from: u256,
    #[indexed]
    to: u256,
    amount: u256,
}
//</hide>

// Read-only logging isn't meaningful, so always use mut
fn emit_transfer(from: u256, to: u256, amount: u256) uses (mut log: Log) {
    log.emit(Transfer { from, to, amount })
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
    -> bool uses (config: Config, mut balances: Balances, mut log: Log)
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
struct Deposit {
    #[indexed]
    account: u256,
    amount: u256,
}
//</hide>

// Internal helper - no logging
fn update_balance(account: u256, delta: u256) uses (mut balances: Balances) {
    // Pure state update, no events
    //<hide>
    let _ = (account, delta, balances)
    //</hide>
}

// Public interface - with logging
fn deposit(account: u256, amount: u256)
    uses (mut balances: Balances, mut log: Log)
{
    update_balance(account, amount)
    log.emit(Deposit { account, amount })
}
```

## Effect Propagation

Functions calling logging functions must declare the effect:

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

fn emit_transfer(from: u256, to: u256, amount: u256) uses (mut log: Log) {
    log.emit(Transfer { from, to, amount })
}

// Must declare Log because it calls emit_transfer
fn do_transfer(from: u256, to: u256, amount: u256)
    -> bool uses (mut store: TokenStorage, mut log: Log)
{
    // ... transfer logic ...
    //<hide>
    let _ = (from, to, amount, store)
    //</hide>
    emit_transfer(from, to, amount)  // Requires Log effect
    true
}
```

```fe ignore
// Compile error: missing Log effect
fn broken_transfer(from: u256, to: u256, amount: u256)
    uses (mut store: TokenStorage)
    -> bool
{
    // ... transfer logic ...
    emit_transfer(from, to, amount)  // Error: Log not available
    true
}
```

## Binding in Contracts

Contracts provide the Log effect via the `uses` clause on handlers:

```fe
//<hide>
use _boilerplate::{Map, Log, caller}
pub struct TokenStorage { pub balances: Map<u256, u256> }
fn do_transfer(c: u256, to: u256, amount: u256) -> bool uses (mut store: TokenStorage, mut log: Log) {
    let _ = (c, to, amount, store, log)
    true
}
msg TokenMsg {
    #[selector = 0xa9059cbb]
    Transfer { to: u256, amount: u256 } -> bool,
}
//</hide>

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

## Separate Log Effects

Use different Log effects for different event categories:

```fe
//<hide>
use _boilerplate::Map
pub struct TokenStorage { pub balances: Map<u256, u256> }
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
    uses (mut store: TokenStorage, mut log: TransferLog)
{
    // ... transfer logic ...
    //<hide>
    let _ = (from, to, amount, store)
    //</hide>
    log.emit(Transfer { from, to, amount })
}

fn transfer_ownership(new_owner: u256)
    uses (mut admin: AdminStorage, mut log: AdminLog)
{
    let previous = admin.owner
    admin.owner = new_owner
    log.emit(OwnershipTransferred { previous_owner: previous, new_owner })
}
```

This gives fine-grained control over which functions can emit which events.

## Log Effect Patterns

### Combined Storage and Log

Often storage and its events are paired:

```fe
//<hide>
use _boilerplate::Map
struct Transfer {
    #[indexed]
    from: u256,
    #[indexed]
    to: u256,
    amount: u256,
}
//</hide>

pub struct TokenStorage {
    pub balances: Map<u256, u256>,
    pub total_supply: u256,
}

pub struct TokenEvents {}
impl TokenEvents {
    pub fn emit<T>(self, event: T) { todo() }
}

fn mint(to: u256, amount: u256)
    uses (mut store: TokenStorage, mut log: TokenEvents)
{
    store.balances.set(to, store.balances.get(to) + amount)
    store.total_supply = store.total_supply + amount
    log.emit(Transfer { from: 0, to, amount })
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

fn log_debug(message: u256) uses (mut log: DebugLog) {
    log.emit(DebugMessage { value: message })
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

// Core logic - no logging
fn compute_fee(amount: u256) -> u256 uses (config: Config) {
    amount * config.fee_rate / 10000
}

// With logging wrapper
fn compute_fee_logged(amount: u256)
    -> u256 uses (config: Config, mut log: Log)
{
    let fee = compute_fee(amount)
    log.emit(FeeComputed { amount, fee })
    fee
}
```

## Comparison with Implicit Logging

| Aspect | Fe (Explicit) | Implicit Logging |
|--------|---------------|------------------|
| Signature | Shows `uses (mut log: Log)` | No indication |
| Testing | Easy to mock | Harder to intercept |
| Composition | Fine-grained control | All-or-nothing |
| Refactoring | Compiler catches missing effects | Silent failures |

## Summary

| Concept | Description |
|---------|-------------|
| `pub struct Log {}` | Define a log effect type |
| `uses (mut log: Log)` | Declare logging capability |
| `log.emit(...)` | Emit an event |
| Effect propagation | Callers must declare effects of callees |
| Handler `uses` | Bind effect in contract handlers |

Explicit logging effects make your contract's behavior transparent. Every function signature tells the full story of what it can do.
