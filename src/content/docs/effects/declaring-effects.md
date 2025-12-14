---
title: Declaring Effects
description: The uses clause syntax for functions and contracts
---

The `uses` clause declares what effects a function or contract requires. This section covers all the syntax variations.

## Basic Syntax

Add a `uses` clause after the parameter list and before the return type:

```fe ignore
fn function_name() uses EffectType {
    // function body
}

fn with_params(x: u256) uses EffectType -> u256 {
    // function body with return type
}
```

## Single Effect

The simplest form declares a single effect:

```fe ignore
pub struct Storage {
    pub data: u256,
}

fn read_data() uses Storage -> u256 {
    Storage.data
}

fn write_data(value: u256) uses mut Storage {
    Storage.data = value
}
```

## Named Effects

Give an effect a local name for clearer code:

```fe ignore
fn process() uses store: Storage {
    // Access via the name 'store'
    let value = store.data
}

fn update() uses mut store: Storage {
    store.data = 100
}
```

Named effects are especially useful when:
- The effect type name is long
- You want more descriptive names in your function body
- You have multiple effects of similar types

## Multiple Effects

Declare multiple effects using parentheses:

```fe ignore
fn complex_operation() uses (Storage, Logger, Config) {
    // Has access to all three effects
}
```

Combine with names and mutability:

```fe ignore
fn transfer() uses (mut balances: Balances, config: Config, mut log: Logger) {
    // balances and log are mutable
    // config is read-only
}
```

## Effects on Contracts

Contracts can declare effects in their definition:

```fe ignore
contract Token uses (mut ctx: Context) {
    store: TokenStorage,
}
```

The contract's effects are available within its recv blocks. Helper functions called from recv blocks receive effects explicitly:

```fe ignore
pub struct TokenStorage {
    pub balances: StorageMap<u256, u256>,
}

// Helper function with explicit effects
fn do_transfer(from: u256, to: u256, amount: u256) uses mut TokenStorage {
    let from_balance = TokenStorage.balances.get(from)
    let to_balance = TokenStorage.balances.get(to)

    TokenStorage.balances.set(from, from_balance - amount)
    TokenStorage.balances.set(to, to_balance + amount)
}
```

## Effect Types

Effects can be any type or trait:

### Struct Effects

```fe ignore
pub struct AppConfig {
    pub max_value: u256,
    pub enabled: bool,
}

fn check_config() uses AppConfig -> bool {
    AppConfig.enabled
}
```

### Generic Effects

```fe ignore
pub struct Cache<T> {
    pub value: T,
}

fn get_cached<T>() uses Cache<T> -> T {
    Cache.value
}
```

## Syntax Summary

| Form | Example |
|------|---------|
| Single effect | `uses Effect` |
| Mutable effect | `uses mut Effect` |
| Named effect | `uses name: Effect` |
| Named mutable | `uses mut name: Effect` |
| Multiple effects | `uses (E1, E2, E3)` |
| Mixed | `uses (mut a: A, b: B)` |
| On contract | `contract C uses (Effect) { }` |

## Common Patterns

### Read-Only Helper

```fe ignore
fn get_balance(account: u256) uses Balances -> u256 {
    Balances.get(account)
}
```

### Mutable Operation

```fe ignore
fn set_balance(account: u256, amount: u256) uses mut Balances {
    Balances.set(account, amount)
}
```

### Multiple Concerns

```fe ignore
fn logged_transfer(from: u256, to: u256, amount: u256)
    uses (mut balances: Balances, mut log: TransferLog)
{
    balances.transfer(from, to, amount)
    log.record(from, to, amount)
}
```
