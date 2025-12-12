---
title: Effect Propagation
description: How effects flow through function calls
---

Effects propagate through the call chain. When you call a function that requires effects, those effects must be available in your current scope.

## How Propagation Works

When function A calls function B, and B requires an effect, A must either:
1. Have that effect in its own `uses` clause
2. Provide the effect using a `with` expression

```fe
//<hide>
pub struct Storage { pub data: u256 }
//</hide>

fn inner() uses (storage: Storage) {
    // Uses Storage
    //<hide>
    let _ = storage
    //</hide>
}

fn outer() uses (storage: Storage) {
    inner()  // OK: Storage is available from outer's uses clause
    //<hide>
    let _ = storage
    //</hide>
}
```

If an effect is missing, the compiler reports an error:

```fe ignore
// This would be a compile error:
fn inner() uses (storage: Storage) {
    // Uses Storage
}

fn outer() {
    inner()  // Error: missing effect Storage
}
```

## The with Expression

The `with` expression provides effects to a scope:

```fe
pub struct Storage { pub data: u256 }

fn needs_storage() uses (storage: Storage) {
    // ...
    //<hide>
    let _ = storage
    //</hide>
}

fn main() {
    let storage = Storage { data: 0 }

    with (Storage = storage) {
        needs_storage()  // OK: Storage is provided
    }
}
```

### Syntax

```fe
//<hide>
pub struct EffectType { pub data: u256 }
pub struct Effect1 { pub data: u256 }
pub struct Effect2 { pub data: u256 }
fn example() {
//</hide>
let value = EffectType { data: 0 }
with (EffectType = value) {
    // Effect is available here
}

// Multiple effects
let val1 = Effect1 { data: 0 }
let val2 = Effect2 { data: 0 }
with (Effect1 = val1, Effect2 = val2) {
    // Both effects available
}
//<hide>
}
//</hide>
```

### Scoping

Effects from `with` are only available inside the block:

```fe ignore
// This would be a compile error:
fn example() {
    let data = Data { value: 0 }

    with (Data = data) {
        use_data()  // OK: Data is available
    }

    use_data()  // Error: Data is not available here
}
```

## Propagation Chain

Effects propagate through any depth of calls:

```fe
pub struct Config { pub max: u256 }

fn level3() uses (config: Config) {
    // Uses Config
    //<hide>
    let _ = config
    //</hide>
}

fn level2() uses (config: Config) {
    level3()  // Config propagates
    //<hide>
    let _ = config
    //</hide>
}

fn level1() uses (config: Config) {
    level2()  // Config propagates
    //<hide>
    let _ = config
    //</hide>
}

fn entry() {
    let config = Config { max: 100 }

    with (Config = config) {
        level1()  // Provides Config for entire chain
    }
}
```

## Nested with Expressions

`with` expressions can be nested, creating layered scopes:

```fe
pub struct A { pub data: u256 }
pub struct B { pub data: u256 }

fn needs_both() uses (a: A, b: B) {
    // ...
    //<hide>
    let _ = (a, b)
    //</hide>
}

fn example() {
    let a = A { data: 0 }
    let b = B { data: 0 }

    with (A = a) {
        // A is available

        with (B = b) {
            // Both A and B are available
            needs_both()
        }

        // Only A is available here
    }
}
```

Or provide multiple effects at once:

```fe
//<hide>
pub struct A { pub data: u256 }
pub struct B { pub data: u256 }
fn needs_both() uses (a: A, b: B) { let _ = (a, b) }
fn example() {
let a = A { data: 0 }
let b = B { data: 0 }
//</hide>
with (A = a, B = b) {
    needs_both()
}
//<hide>
}
//</hide>
```

## Effect Shadowing

Inner scopes can shadow outer effects:

```fe
pub struct Data { pub value: u256 }

fn read_value() -> u256 uses (data: Data) {
    data.value
}

fn example() {
    let outer = Data { value: 10 }
    let inner = Data { value: 20 }

    with (Data = outer) {
        let v1 = read_value()  // Returns 10

        with (Data = inner) {
            let v2 = read_value()  // Returns 20 (shadowed)
            //<hide>
            let _ = v2
            //</hide>
        }

        let v3 = read_value()  // Returns 10 (back to outer)
        //<hide>
        let _ = (v1, v3)
        //</hide>
    }
}
```

## Combining uses and with

Functions can have their own effects and also provide additional effects:

```fe
//<hide>
pub struct Config { pub data: u256 }
pub struct Logger { pub data: u256 }
//</hide>

fn helper() uses (config: Config, mut logger: Logger) {
    // Needs both effects
    //<hide>
    let _ = (config, logger)
    //</hide>
}

fn outer() uses (config: Config) {
    let mut logger = Logger { data: 0 }

    // Config comes from uses clause
    // Logger is provided by with
    with (Logger = logger) {
        helper()
    }
    //<hide>
    let _ = config
    //</hide>
}
```

## Error Messages

The compiler provides clear error messages for effect issues:

### Missing Effect

```fe ignore
// This would be a compile error:
fn needs_data() uses (data: Data) { }

fn caller() {
    needs_data()
    // Error: function `needs_data` requires effect `Data`
    // which is not available in this scope
}
```

### Mutability Mismatch

```fe ignore
// This would be a compile error:
fn needs_mut() uses (mut data: Data) { }

fn caller() uses (data: Data) {
    needs_mut()
    // Error: function `needs_mut` requires mutable effect `Data`
    // but only immutable `Data` is available
}
```

## Summary

| Concept | Description |
|---------|-------------|
| Propagation | Effects flow from caller to callee |
| `with` | Provides effects to a scope |
| Scoping | Effects only available inside their scope |
| Nesting | `with` can be nested for layered effects |
| Shadowing | Inner effects shadow outer ones |
