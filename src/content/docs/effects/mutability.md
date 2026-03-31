---
title: Mutability in Effects
description: Read-only vs mutable effect access
---

Effects distinguish between read-only and mutable access. This distinction is enforced at compile time, preventing accidental mutations.

## Read-Only Effects

By default, effects are read-only:

```fe
//<hide>
pub struct Config { pub value: u256 }
//</hide>

fn get_value() -> u256 uses (config: Config) {
    config.value  // Can read
}
```

Read-only effects:
- Allow reading data from the effect
- Prevent any modification
- Are the default when `mut` is not specified

Attempting to modify a read-only effect is a compile error:

```fe ignore
// This would be a compile error:
fn try_modify() uses (config: Config) {
    config.value = 100  // Error: cannot modify immutable effect
}
```

## Mutable Effects

Add `mut` to allow modification:

```fe
//<hide>
pub struct Config { pub value: u256 }
//</hide>

fn set_value(new_value: u256) uses (config: mut Config) {
    config.value = new_value  // Can modify
}
```

Mutable effects:
- Allow both reading and writing
- Must be explicitly declared with `mut`
- Require a mutable binding when provided

## Mutability Matching Rules

When calling a function that requires an effect, the caller must provide a compatible effect:

### Rule 1: Mutable Satisfies Immutable

A mutable effect can satisfy an immutable requirement:

```fe
//<hide>
pub struct Data { pub value: u256 }
//</hide>

fn read_only() uses (data: Data) {
    // reads Data
    //<hide>
    let _ = data
    //</hide>
}

fn outer() uses (data: mut Data) {
    read_only()  // OK: mut Data satisfies Data
    //<hide>
    let _ = data
    //</hide>
}
```

### Rule 2: Immutable Cannot Satisfy Mutable

An immutable effect cannot satisfy a mutable requirement:

```fe ignore
// This would be a compile error:
fn needs_mut() uses (data: mut Data) {
    // modifies Data
}

fn outer() uses (data: Data) {
    needs_mut()  // Error: Data cannot satisfy mut Data
}
```

### Rule 3: Binding Mutability

When providing an effect with `with`, the binding's mutability determines the effect's mutability:

```fe
pub struct Counter { pub value: u256 }

fn needs_mut() uses (counter: mut Counter) {
    counter.value = counter.value + 1
}

fn example() {
    // Immutable binding - would error if we tried to call needs_mut()
    let counter = Counter { value: 0 }
    //<hide>
    let _ = counter
    //</hide>

    // Mutable binding - can satisfy mut effect
    let mut counter2 = Counter { value: 0 }

    with (Counter = counter2) {
        needs_mut()  // OK: counter2 is mutable
    }
}
```

## When to Use Each

### Use Read-Only When

- The function only reads data
- You want to prevent accidental modification
- You're implementing a getter or query

```fe
//<hide>
pub struct TokenStore { pub supply: u256 }
pub struct Config { pub max_amount: u256 }
//</hide>

fn total_supply() -> u256 uses (store: TokenStore) {
    store.supply
}

fn is_valid(amount: u256) -> bool uses (config: Config) {
    amount <= config.max_amount
}
```

### Use Mutable When

- The function modifies data
- You're implementing a setter or state change
- The operation has side effects

```fe
//<hide>
pub struct TokenStore { pub supply: u256 }
pub struct Config { pub max_amount: u256 }
//</hide>

fn mint(amount: u256) uses (store: mut TokenStore) {
    store.supply = store.supply + amount
}

fn update_config(new_max: u256) uses (config: mut Config) {
    config.max_amount = new_max
}
```

## Named Effects and Mutability

Named effects follow the same rules:

```fe
//<hide>
pub struct Data { pub value: u256 }
pub struct Cache {}
impl Cache {
    pub fn store(mut self, value: u256) { let _ = value }
}
//</hide>

fn process() uses (data: Data, cache: mut Cache) {
    // data is read-only
    // cache is mutable

    let value = data.value      // OK: reading
    cache.store(value)          // OK: mutable operation

    // data.value = 100         // Would error: data is not mutable
}
```

## Mutability in Practice

A common pattern separates read and write operations:

```fe
pub struct Balances {
    pub data: StorageMap<u256, u256>,
}

// Read-only: safe to call anywhere
fn get_balance(account: u256) -> u256 uses (balances: Balances) {
    balances.data.get(key: account)
}

// Mutable: changes state
fn set_balance(account: u256, amount: u256) uses (balances: mut Balances) {
    balances.data.set(key: account, value: amount)
}

// Mutable: combines read and write
fn transfer(from: u256, to: u256, amount: u256) uses (balances: mut Balances) {
    let from_balance = get_balance(account: from)  // Calls read-only function
    let to_balance = get_balance(account: to)

    set_balance(account: from, amount: from_balance - amount)
    set_balance(account: to, amount: to_balance + amount)
}
```

## Summary

| Declaration | Can Read | Can Modify |
|------------|----------|------------|
| `uses (e: Effect)` | Yes | No |
| `uses (e: mut Effect)` | Yes | Yes |

| Caller Has | Callee Needs | Result |
|------------|--------------|--------|
| `(e: Effect)` | `(e: Effect)` | OK |
| `(mut e: Effect)` | `(e: Effect)` | OK |
| `(e: Effect)` | `(mut e: Effect)` | Error |
| `(mut e: Effect)` | `(mut e: Effect)` | OK |
