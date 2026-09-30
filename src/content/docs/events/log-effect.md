---
title: The Log Effect
description: Why logging is an explicit capability
---

In Fe, logging is an effect, a capability that must be explicitly declared. This makes event emission visible in function signatures and enables powerful patterns for testing and composition.

## Logging as an Effect

Unlike languages where logging is implicit, Fe treats it as a tracked capability:

```fe
//<hide>
pub struct TokenStorage { pub balances: StorageMap<Address, u256> }
//</hide>

#[event]
struct Transfer {
    #[indexed]
    from: Address,
    #[indexed]
    to: Address,
    amount: u256,
}

impl TokenStorage {
    // This method CAN emit events
    fn transfer_with_event(mut self, from: Address, to: Address, amount: u256)
        uses (log: mut Log)
    {
        // ... transfer logic ...
        //<hide>
        let _ = (from, to, amount)
        //</hide>
        log.emit(event: Transfer { from, to, amount })
    }

    // This method CANNOT emit events
    fn transfer_silent(mut self, from: Address, to: Address, amount: u256) {
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
#[event]
struct Transfer {
    #[indexed]
    from: Address,
    #[indexed]
    to: Address,
    amount: u256,
}
//</hide>

// Read-only logging isn't meaningful, so always use mut
fn emit_transfer(from: Address, to: Address, amount: u256) uses (log: mut Log) {
    log.emit(event: Transfer { from, to, amount })
}
```

## Why Explicit Logging?

### Clear Function Contracts

Function signatures reveal side effects:

```fe
//<hide>
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

The standard `Log` trait is a sealed EVM capability, so an application cannot implement it on an arbitrary mock. Use `Evm` integration tests and `fe test --show-logs` to inspect emitted events. For unit-testable business logic, define your own application-level event-sink trait and supply a recording implementation; see [Mocking Effects](/testing/mocking/).

### Composition Control

Compose functions while controlling which can log:

```fe
//<hide>
pub struct Balances { pub data: u256 }
#[event]
struct Deposit {
    #[indexed]
    account: Address,
    amount: u256,
}
//</hide>

impl Balances {
    // Internal helper - no logging
    fn update_balance(mut self, account: Address, delta: u256) {
        // Pure state update, no events
        //<hide>
        let _ = (account, delta)
        //</hide>
    }

    // Public interface - with logging
    fn deposit(mut self, account: Address, amount: u256) uses (log: mut Log) {
        self.update_balance(account, delta: amount)
        log.emit(event: Deposit { account, amount })
    }
}
```

## Effect Propagation

Functions calling logging functions must declare the effect:

```fe
//<hide>
pub struct TokenStorage { pub balances: StorageMap<Address, u256> }
#[event]
struct Transfer {
    #[indexed]
    from: Address,
    #[indexed]
    to: Address,
    amount: u256,
}
//</hide>

fn emit_transfer(from: Address, to: Address, amount: u256) uses (log: mut Log) {
    log.emit(event: Transfer { from, to, amount })
}

impl TokenStorage {
    // Must declare Log because it calls emit_transfer
    fn do_transfer(mut self, from: Address, to: Address, amount: u256)
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
    fn broken_transfer(mut self, from: Address, to: Address, amount: u256) -> bool {
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
pub struct TokenStorage { pub balances: StorageMap<Address, u256> }
impl TokenStorage {
    fn do_transfer(mut self, from: Address, to: Address, amount: u256) -> bool uses (log: mut Log) {
        let _ = (from, to, amount, log)
        true
    }
}
msg TokenMsg {
    #[selector = sol("transfer(address,uint256)")]
    Transfer { to: Address, amount: u256 } -> bool,
}
//</hide>

contract Token uses (ctx: Ctx, log: mut Log) {
    mut store: TokenStorage,

    recv TokenMsg {
        Transfer { to, amount } -> bool uses (ctx, mut store, mut log) {
            store.do_transfer(from: ctx.caller(), to, amount)
        }
    }
}
```

## Restricting Which Events a Function Can Emit

`Log` is sealed, so you cannot implement it for your own type, and a `uses (log: mut Log)` function can emit any event. To narrow that, wrap the real `Log` in a struct that only exposes the events you allow, and pass the wrapper as the effect:

```fe
//<hide>
use std::abi::sol
//</hide>
#[event]
struct OwnershipTransferred {
    #[indexed]
    previous_owner: Address,
    #[indexed]
    new_owner: Address,
}

pub struct AdminLog<L> {
    inner: L,
}

impl<L: Log> AdminLog<L> {
    pub fn ownership_transferred(mut self, previous_owner: Address, new_owner: Address) {
        self.inner.emit(event: OwnershipTransferred { previous_owner, new_owner })
    }
}

pub struct AdminStorage {
    pub owner: Address,
}

// Can emit OwnershipTransferred, and nothing else
fn transfer_ownership<L: Log>(new_owner: Address)
    uses (store: mut AdminStorage, admin_log: mut AdminLog<L>)
{
    let previous = store.owner
    store.owner = new_owner
    admin_log.ownership_transferred(previous_owner: previous, new_owner)
}

msg AdminMsg {
    #[selector = sol("transferOwnership(address)")]
    TransferOwnership { new_owner: Address },
}

pub contract Admin uses (log: mut Log) {
    mut store: AdminStorage,

    recv AdminMsg {
        TransferOwnership { new_owner } uses (mut store, mut log) {
            with (AdminLog { inner: log }) {
                transfer_ownership(new_owner)
            }
        }
    }
}
```

`AdminLog` has no general `emit` method, so `admin_log.emit(event: ...)` is a compile error inside `transfer_ownership`. The events still go through the real `Log`, so they appear in the transaction logs as usual.

## Optional Logging

Make logging optional by separating concerns:

```fe
//<hide>
#[event]
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
| Testing | EVM integration tests; custom application effects for unit tests | Requires observing emitted logs |
| Composition | Fine-grained control | All-or-nothing |
| Refactoring | Compiler catches missing effects | Silent failures |

## Summary

| Concept | Description |
|---------|-------------|
| `Log` | Standard sealed event-emission trait |
| `uses (log: mut Log)` | Declare logging capability |
| `log.emit(...)` | Emit an event |
| Effect propagation | Callers must declare effects of callees |
| Handler `uses` | Bind effect in contract handlers |

Explicit logging effects make your contract's behavior transparent. Every function signature tells the full story of what it can do.
