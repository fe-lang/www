---
title: Declaring Effects
description: The uses clause syntax for functions and contracts
---

The `uses` clause declares what effects a function or contract requires. This section covers all the syntax variations.

## Basic Syntax

Add a `uses` clause after the return type (if any):

```fe
//<hide>
pub struct EffectType {
    pub data: u256,
}
//</hide>

fn function_name() uses (effect: EffectType) {
    // function body
    //<hide>
    let _ = effect
    //</hide>
}

fn with_params(x: u256) -> u256 uses (effect: EffectType) {
    // function body with return type
    //<hide>
    let _ = effect
    //</hide>
    x
}
```

## Single Effect

The simplest form declares a single effect:

```fe
pub struct Storage {
    pub data: u256,
}

fn read_data() -> u256 uses (storage: Storage) {
    storage.data
}

fn write_data(value: u256) uses (mut storage: Storage) {
    storage.data = value
}
```

## Named Effects

Give an effect a local name for clearer code:

```fe
//<hide>
pub struct Storage {
    pub data: u256,
}
//</hide>

fn process() uses (store: Storage) {
    // Access via the name 'store'
    let value = store.data
    //<hide>
    let _ = value
    //</hide>
}

fn update() uses (mut store: Storage) {
    store.data = 100
}
```

Named effects are especially useful when:
- The effect type name is long
- You want more descriptive names in your function body
- You have multiple effects of similar types

## Multiple Effects

Declare multiple effects using parentheses:

```fe
//<hide>
pub struct Storage { pub data: u256 }
pub struct Logger { pub data: u256 }
pub struct Config { pub data: u256 }
//</hide>

fn complex_operation() uses (storage: Storage, logger: Logger, config: Config) {
    // Has access to all three effects
    //<hide>
    let _ = (storage, logger, config)
    //</hide>
}
```

Combine with names and mutability:

```fe
//<hide>
pub struct Balances { pub data: u256 }
pub struct Config { pub data: u256 }
pub struct Logger { pub data: u256 }
//</hide>

fn transfer() uses (mut balances: Balances, config: Config, mut log: Logger) {
    // balances and log are mutable
    // config is read-only
    //<hide>
    let _ = (balances, config, log)
    //</hide>
}
```

## Effects on Contracts

Contracts can declare effects in their definition:

```fe
//<hide>
pub struct Context { pub data: u256 }
pub struct TokenStorage { pub data: u256 }
//</hide>

contract Token uses (mut ctx: Context) {
    store: TokenStorage,
}
```

The contract's effects are available within its recv blocks. Helper functions called from recv blocks receive effects explicitly:

```fe
//<hide>
use _boilerplate::Map
//</hide>

pub struct TokenStorage {
    pub balances: Map<u256, u256>,
}

// Helper function with explicit effects
fn do_transfer(from: u256, to: u256, amount: u256) uses (mut store: TokenStorage) {
    let from_balance = store.balances.get(from)
    let to_balance = store.balances.get(to)

    store.balances.set(from, from_balance - amount)
    store.balances.set(to, to_balance + amount)
}
```

## Effect Types

Effects can be any type or trait:

### Struct Effects

```fe
pub struct AppConfig {
    pub max_value: u256,
    pub enabled: bool,
}

fn check_config() -> bool uses (config: AppConfig) {
    config.enabled
}
```

### Generic Effects

```fe
pub struct Cache<T> {
    pub value: T,
}

fn get_cached<T>() -> T uses (cache: Cache<T>) {
    cache.value
}
```

## Syntax Summary

| Form | Example |
|------|---------|
| Single effect | `uses (name: Effect)` |
| Mutable effect | `uses (mut name: Effect)` |
| Multiple effects | `uses (a: A, b: B, c: C)` |
| Mixed mutability | `uses (mut a: A, b: B)` |
| With return type | `fn foo() -> T uses (e: E)` |
| On contract | `contract C uses (e: Effect) { }` |

## Common Patterns

### Read-Only Helper

```fe
//<hide>
pub struct Balances {}
impl Balances {
    pub fn get(self, account: u256) -> u256 { todo() }
}
//</hide>

fn get_balance(account: u256) -> u256 uses (balances: Balances) {
    balances.get(account)
}
```

### Mutable Operation

```fe
//<hide>
pub struct Balances {}
impl Balances {
    pub fn set(mut self, account: u256, amount: u256) { todo() }
}
//</hide>

fn set_balance(account: u256, amount: u256) uses (mut balances: Balances) {
    balances.set(account, amount)
}
```

### Multiple Concerns

```fe
//<hide>
pub struct Balances {}
impl Balances {
    pub fn transfer(mut self, from: u256, to: u256, amount: u256) { todo() }
}
pub struct TransferLog {}
impl TransferLog {
    pub fn record(mut self, from: u256, to: u256, amount: u256) { todo() }
}
//</hide>

fn logged_transfer(from: u256, to: u256, amount: u256)
    uses (mut balances: Balances, mut log: TransferLog)
{
    balances.transfer(from, to, amount)
    log.record(from, to, amount)
}
```
