---
title: Mutability in Effects
description: Read-only vs mutable effect access
---

Effects distinguish between read-only and mutable access. This distinction is enforced at compile time, preventing accidental mutations.

## Read-Only Effects

By default, effects are read-only:

```fe ignore
fn get_value() uses Config -> u256 {
    Config.value  // Can read
}
```

Read-only effects:
- Allow reading data from the effect
- Prevent any modification
- Are the default when `mut` is not specified

Attempting to modify a read-only effect is a compile error:

```fe ignore
fn try_modify() uses Config {
    Config.value = 100  // Error: cannot modify immutable effect
}
```

## Mutable Effects

Add `mut` to allow modification:

```fe ignore
fn set_value(new_value: u256) uses mut Config {
    Config.value = new_value  // Can modify
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

```fe ignore
fn read_only() uses Data {
    // reads Data
}

fn caller() uses mut Data {
    read_only()  // OK: mut Data satisfies Data
}
```

### Rule 2: Immutable Cannot Satisfy Mutable

An immutable effect cannot satisfy a mutable requirement:

```fe ignore
fn needs_mut() uses mut Data {
    // modifies Data
}

fn caller() uses Data {
    needs_mut()  // Error: Data cannot satisfy mut Data
}
```

### Rule 3: Binding Mutability

When providing an effect with `with`, the binding's mutability determines the effect's mutability:

```fe ignore
fn needs_mut() uses mut Counter {
    Counter.value = Counter.value + 1
}

fn example() {
    let counter = Counter { value: 0 }

    with (Counter = counter) {
        needs_mut()  // Error: counter is not mutable
    }

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

```fe ignore
fn total_supply() uses TokenStore -> u256 {
    TokenStore.supply
}

fn is_valid(amount: u256) uses Config -> bool {
    amount <= Config.max_amount
}
```

### Use Mutable When

- The function modifies data
- You're implementing a setter or state change
- The operation has side effects

```fe ignore
fn mint(amount: u256) uses mut TokenStore {
    TokenStore.supply = TokenStore.supply + amount
}

fn update_config(new_max: u256) uses mut Config {
    Config.max_amount = new_max
}
```

## Named Effects and Mutability

Named effects follow the same rules:

```fe ignore
fn process() uses (data: Data, mut cache: Cache) {
    // data is read-only
    // cache is mutable

    let value = data.value      // OK: reading
    cache.store(value)          // OK: mutable operation

    data.value = 100            // Error: data is not mutable
}
```

## Mutability in Practice

A common pattern separates read and write operations:

```fe ignore
pub struct Balances {
    pub data: StorageMap<u256, u256>,
}

// Read-only: safe to call anywhere
fn get_balance(account: u256) uses Balances -> u256 {
    Balances.data.get(account)
}

// Mutable: changes state
fn set_balance(account: u256, amount: u256) uses mut Balances {
    Balances.data.set(account, amount)
}

// Mutable: combines read and write
fn transfer(from: u256, to: u256, amount: u256) uses mut Balances {
    let from_balance = get_balance(from)  // Calls read-only function
    let to_balance = get_balance(to)

    set_balance(from, from_balance - amount)
    set_balance(to, to_balance + amount)
}
```

## Summary

| Declaration | Can Read | Can Modify |
|------------|----------|------------|
| `uses Effect` | Yes | No |
| `uses mut Effect` | Yes | Yes |

| Caller Has | Callee Needs | Result |
|------------|--------------|--------|
| `Effect` | `Effect` | OK |
| `mut Effect` | `Effect` | OK |
| `Effect` | `mut Effect` | Error |
| `mut Effect` | `mut Effect` | OK |
