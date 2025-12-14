---
title: Built-in Effects
description: Common effect patterns and user-defined effect types
---

Unlike some languages with fixed built-in effects, Fe's effects are user-defined types. This gives you complete control over what capabilities your code requires.

## Effects Are User-Defined

Any struct or trait can serve as an effect:

```fe ignore
// Define your own effect type
pub struct Logger {
    pub entries: Vec<String>,
}

// Use it as an effect
fn log_message(msg: String) uses mut Logger {
    Logger.entries.push(msg)
}
```

This means:
- You define exactly what your effects contain
- Effects are regular types with fields and methods
- No magic—effects are just capability markers

## Common Effect Patterns

While Fe doesn't prescribe specific built-in effects, certain patterns are common:

### Context Effect

A context effect provides execution environment information:

```fe ignore
pub struct Ctx {
    pub caller: u256,
    pub block_number: u256,
    pub timestamp: u256,
}

fn only_owner(owner: u256) uses Ctx {
    if Ctx.caller != owner {
        revert
    }
}

fn get_timestamp() uses Ctx -> u256 {
    Ctx.timestamp
}
```

### Storage Effect

A storage effect represents contract state:

```fe ignore
pub struct TokenStore {
    pub balances: StorageMap<u256, u256>,
    pub total_supply: u256,
}

fn balance_of(account: u256) uses TokenStore -> u256 {
    TokenStore.balances.get(account)
}

fn mint(to: u256, amount: u256) uses mut TokenStore {
    let current = TokenStore.balances.get(to)
    TokenStore.balances.set(to, current + amount)
    TokenStore.total_supply = TokenStore.total_supply + amount
}
```

### Logger Effect

A logger effect tracks events:

```fe ignore
pub struct EventLog {
    // Event logging state
}

fn emit_transfer(from: u256, to: u256, amount: u256) uses mut EventLog {
    // Emit transfer event
}
```

### Config Effect

A configuration effect provides settings:

```fe ignore
pub struct Config {
    pub max_transfer: u256,
    pub fee_rate: u256,
    pub paused: bool,
}

fn check_transfer(amount: u256) uses Config -> bool {
    if Config.paused {
        return false
    }
    amount <= Config.max_transfer
}

fn calculate_fee(amount: u256) uses Config -> u256 {
    amount * Config.fee_rate / 10000
}
```

## Combining Multiple Effects

Real contracts often need multiple effects:

```fe ignore
fn transfer(from: u256, to: u256, amount: u256)
    uses (Ctx, mut TokenStore, Config, mut EventLog)
{
    // Check caller authorization
    if Ctx.caller != from {
        revert
    }

    // Check configuration
    if Config.paused {
        revert
    }

    // Perform transfer
    let from_balance = TokenStore.balances.get(from)
    let to_balance = TokenStore.balances.get(to)

    TokenStore.balances.set(from, from_balance - amount)
    TokenStore.balances.set(to, to_balance + amount)

    // Log the event
    emit_transfer(from, to, amount)
}
```

## Generic Effects

Effects can be generic:

```fe ignore
pub struct Cache<T> {
    pub value: T,
    pub valid: bool,
}

fn get_cached<T>() uses Cache<T> -> Option<T> {
    if Cache.valid {
        Option::Some(Cache.value)
    } else {
        Option::None
    }
}

fn set_cached<T>(value: T) uses mut Cache<T> {
    Cache.value = value
    Cache.valid = true
}
```

## Traits as Effects

Traits can also serve as effects, enabling polymorphism:

```fe ignore
trait Validator {
    fn is_valid(self, value: u256) -> bool
}

fn validate(value: u256) uses impl Validator -> bool {
    Validator.is_valid(value)
}
```

## Designing Your Effects

When creating effects, consider:

### Separation of Concerns

Keep effects focused on one responsibility:

```fe ignore
// Good: separate concerns
pub struct Balances { ... }
pub struct Allowances { ... }
pub struct EventLog { ... }

// Less ideal: everything in one effect
pub struct TokenState {
    balances: ...,
    allowances: ...,
    events: ...,
}
```

### Minimal Mutability

Only require `mut` when necessary:

```fe ignore
// Read-only check
fn has_balance(account: u256, amount: u256) uses Balances -> bool {
    Balances.get(account) >= amount
}

// Only this needs mut
fn debit(account: u256, amount: u256) uses mut Balances {
    let current = Balances.get(account)
    Balances.set(account, current - amount)
}
```

### Clear Naming

Name effects to reflect their purpose:

```fe ignore
// Clear purpose
pub struct TokenBalances { ... }
pub struct AccessControl { ... }
pub struct TransferLog { ... }

// Less clear
pub struct Data { ... }
pub struct State { ... }
```

## Summary

| Pattern | Purpose |
|---------|---------|
| Context | Execution environment (caller, block info) |
| Storage | Persistent contract state |
| Logger | Event emission |
| Config | Runtime configuration |
| Cache | Temporary computed values |

Effects in Fe are not magic—they're regular types that declare capabilities. This gives you full control over your contract's dependency structure.
