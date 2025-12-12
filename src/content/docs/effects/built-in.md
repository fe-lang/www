---
title: Built-in Effects
description: Common effect patterns and user-defined effect types
---

Unlike some languages with fixed built-in effects, Fe's effects are user-defined types. This gives you complete control over what capabilities your code requires.

## Effects Are User-Defined

Any struct or trait can serve as an effect:

```fe
// Define your own effect type
pub struct Logger {
    pub entries: u256,  // Simplified for example
}

// Use it as an effect
fn log_message(value: u256) uses (mut logger: Logger) {
    logger.entries = value
}
```

This means:
- You define exactly what your effects contain
- Effects are regular types with fields and methods
- No magic: effects are just capability markers

## Common Effect Patterns

While Fe doesn't prescribe specific built-in effects, certain patterns are common:

### Context Effect

A context effect provides execution environment information:

```fe
//<hide>
fn require(cond: bool) { if cond { } else { todo() } }
//</hide>

pub struct Ctx {
    pub caller: u256,
    pub block_number: u256,
    pub timestamp: u256,
}

fn only_owner(owner: u256) uses (ctx: Ctx) {
    require(ctx.caller == owner)
}

fn get_timestamp() -> u256 uses (ctx: Ctx) {
    ctx.timestamp
}
```

### Storage Effect

A storage effect represents contract state:

```fe
//<hide>
use _boilerplate::Map
//</hide>

pub struct TokenStore {
    pub balances: Map<u256, u256>,
    pub total_supply: u256,
}

fn balance_of(account: u256) -> u256 uses (store: TokenStore) {
    store.balances.get(account)
}

fn mint(to: u256, amount: u256) uses (mut store: TokenStore) {
    let current = store.balances.get(to)
    store.balances.set(to, current + amount)
    store.total_supply = store.total_supply + amount
}
```

### Logger Effect

A logger effect tracks events:

```fe
pub struct EventLog {
    // Event logging state
    pub data: u256,
}

fn emit_transfer(from: u256, to: u256, amount: u256) uses (mut log: EventLog) {
    // Emit transfer event
    //<hide>
    let _ = (from, to, amount, log)
    //</hide>
}
```

### Config Effect

A configuration effect provides settings:

```fe
pub struct Config {
    pub max_transfer: u256,
    pub fee_rate: u256,
    pub paused: bool,
}

fn check_transfer(amount: u256) -> bool uses (config: Config) {
    if config.paused {
        return false
    }
    amount <= config.max_transfer
}

fn calculate_fee(amount: u256) -> u256 uses (config: Config) {
    amount * config.fee_rate / 10000
}
```

## Combining Multiple Effects

Real contracts often need multiple effects:

```fe
//<hide>
pub struct Ctx { pub caller: u256 }
pub struct Config { pub paused: bool }
pub struct EventLog { pub data: u256 }
pub struct Map<K, V> {}
impl<K, V> Map<K, V> {
    pub fn get(self, key: K) -> V { todo() }
    pub fn set(mut self, key: K, value: V) { todo() }
}
pub struct TokenStore { pub balances: Map<u256, u256> }
fn emit_transfer(from: u256, to: u256, amount: u256) uses (mut log: EventLog) {
    let _ = (from, to, amount, log)
}
fn require(cond: bool) { if cond { } else { todo() } }
//</hide>

fn transfer(from: u256, to: u256, amount: u256)
    uses (ctx: Ctx, mut store: TokenStore, config: Config, mut log: EventLog)
{
    // Check caller authorization
    require(ctx.caller == from)

    // Check not paused
    require(config.paused == false)

    // Perform transfer
    let from_balance = store.balances.get(from)
    let to_balance = store.balances.get(to)

    store.balances.set(from, from_balance - amount)
    store.balances.set(to, to_balance + amount)

    // Log the event
    emit_transfer(from, to, amount)
}
```

## Generic Effects

Effects can be generic:

```fe
//<hide>
enum Option<T> {
    Some(T),
    None,
}
//</hide>

pub struct Cache<T> {
    pub value: T,
    pub valid: bool,
}

fn get_cached<T>() -> Option<T> uses (cache: Cache<T>) {
    if cache.valid {
        Option::Some(cache.value)
    } else {
        Option::None
    }
}

fn set_cached<T>(value: T) uses (mut cache: Cache<T>) {
    cache.value = value
    cache.valid = true
}
```

## Structs as Effects

Structs can serve as effects, allowing you to inject behavior:

```fe
//<hide>
use _boilerplate::Option
//</hide>
// Define a validator effect
pub struct RangeValidator {
    pub min: u256,
    pub max: u256,
}

impl RangeValidator {
    pub fn is_valid(self, value: u256) -> bool {
        value >= self.min && value <= self.max
    }
}

fn validate(value: u256) -> bool uses (v: RangeValidator) {
    v.is_valid(value)
}
```

## Designing Your Effects

When creating effects, consider:

### Separation of Concerns

Keep effects focused on one responsibility:

```fe
// Good: separate concerns
pub struct Balances { pub data: u256 }
pub struct Allowances { pub data: u256 }
pub struct EventLog { pub data: u256 }

// Less ideal: everything in one effect
pub struct TokenState {
    balances: u256,
    allowances: u256,
    events: u256,
}
```

### Minimal Mutability

Only require `mut` when necessary:

```fe
//<hide>
pub struct Balances {}
impl Balances {
    pub fn get(self, account: u256) -> u256 { todo() }
    pub fn set(mut self, account: u256, amount: u256) { todo() }
}
//</hide>

// Read-only check
fn has_balance(account: u256, amount: u256) -> bool uses (balances: Balances) {
    balances.get(account) >= amount
}

// Only this needs mut
fn debit(account: u256, amount: u256) uses (mut balances: Balances) {
    let current = balances.get(account)
    balances.set(account, current - amount)
}
```

### Clear Naming

Name effects to reflect their purpose:

```fe
// Clear purpose
pub struct TokenBalances { pub data: u256 }
pub struct AccessControl { pub data: u256 }
pub struct TransferLog { pub data: u256 }

// Less clear
pub struct Data { pub value: u256 }
pub struct State { pub value: u256 }
```

## Summary

| Pattern | Purpose |
|---------|---------|
| Context | Execution environment (caller, block info) |
| Storage | Persistent contract state |
| Logger | Event emission |
| Config | Runtime configuration |
| Cache | Temporary computed values |

Effects in Fe are not magic. They're regular types that declare capabilities. This gives you full control over your contract's dependency structure.
