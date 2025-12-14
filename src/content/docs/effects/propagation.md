---
title: Effect Propagation
description: How effects flow through function calls
---

Effects propagate through the call chain. When you call a function that requires effects, those effects must be available in your current scope.

## How Propagation Works

When function A calls function B, and B requires an effect, A must either:
1. Have that effect in its own `uses` clause
2. Provide the effect using a `with` expression

```fe ignore
fn inner() uses Storage {
    // Uses Storage
}

fn outer() uses Storage {
    inner()  // OK: Storage is available from outer's uses clause
}
```

If an effect is missing, the compiler reports an error:

```fe ignore
fn inner() uses Storage {
    // Uses Storage
}

fn outer() {
    inner()  // Error: missing effect Storage
}
```

## The with Expression

The `with` expression provides effects to a scope:

```fe ignore
fn needs_storage() uses Storage {
    // ...
}

fn main() {
    let storage = Storage { data: 0 }

    with (Storage = storage) {
        needs_storage()  // OK: Storage is provided
    }
}
```

### Syntax

```fe ignore
with (EffectType = value) {
    // Effect is available here
}

// Multiple effects
with (Effect1 = val1, Effect2 = val2) {
    // Both effects available
}
```

### Scoping

Effects from `with` are only available inside the block:

```fe ignore
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

```fe ignore
fn level3() uses Config {
    // Uses Config
}

fn level2() uses Config {
    level3()  // Config propagates
}

fn level1() uses Config {
    level2()  // Config propagates
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

```fe ignore
fn needs_both() uses (A, B) {
    // ...
}

fn example() {
    let a = A { }
    let b = B { }

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

```fe ignore
with (A = a, B = b) {
    needs_both()
}
```

## Effect Shadowing

Inner scopes can shadow outer effects:

```fe ignore
fn read_value() uses Data -> u256 {
    Data.value
}

fn example() {
    let outer = Data { value: 10 }
    let inner = Data { value: 20 }

    with (Data = outer) {
        let v1 = read_value()  // Returns 10

        with (Data = inner) {
            let v2 = read_value()  // Returns 20 (shadowed)
        }

        let v3 = read_value()  // Returns 10 (back to outer)
    }
}
```

## Combining uses and with

Functions can have their own effects and also provide additional effects:

```fe ignore
fn helper() uses (Config, mut Logger) {
    // Needs both effects
}

fn caller() uses Config {
    let logger = Logger { }

    // Config comes from uses clause
    // Logger is provided by with
    with (Logger = logger) {
        helper()
    }
}
```

## Error Messages

The compiler provides clear error messages for effect issues:

### Missing Effect

```fe ignore
fn needs_data() uses Data { }

fn caller() {
    needs_data()
    // Error: function `needs_data` requires effect `Data`
    // which is not available in this scope
}
```

### Mutability Mismatch

```fe ignore
fn needs_mut() uses mut Data { }

fn caller() uses Data {
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
