---
title: Trait Bounds
description: Constraining generic types
---

Trait bounds specify what capabilities a generic type must have. They let you write generic code that uses specific methods or behaviors, with the compiler ensuring only valid types are used.

## Basic Bound Syntax

Add a bound with `: Trait` after the type parameter:

```fe
fn process<T: Hashable>(value: T) -> u256 {
    value.hash()  // Safe: T must implement Hashable
}
```

Without the bound, you couldn't call `hash()`:

```fe
fn process<T>(value: T) -> u256 {
    value.hash()  // Error: T might not have hash()
}
```

## Why Bounds Matter

Bounds enable the compiler to:

1. **Verify method availability**: Ensure methods you call exist
2. **Catch errors early**: Fail at call site, not deep in implementation
3. **Document requirements**: Show what types are expected

```fe
trait Printable {
    fn to_string(self) -> String
}

// Clear: this function needs Printable types
fn log<T: Printable>(value: T) {
    let s = value.to_string()
    // ... log the string
}

struct Secret {
    data: u256,
}

// Error at call site: Secret doesn't implement Printable
log(Secret { data: 42 })  // Compile error
```

## Multiple Bounds

Require multiple traits with `+`:

```fe
trait Hashable {
    fn hash(self) -> u256
}

trait Printable {
    fn to_string(self) -> String
}

fn describe<T: Hashable + Printable>(value: T) -> String {
    let hash = value.hash()
    value.to_string()
}
```

The type must implement all specified traits:

```fe
struct Token {
    id: u256,
}

impl Hashable for Token {
    fn hash(self) -> u256 {
        self.id
    }
}

impl Printable for Token {
    fn to_string(self) -> String {
        "Token"
    }
}

describe(Token { id: 1 })  // Works: Token implements both
```

## Bounds on Multiple Parameters

Each type parameter can have its own bounds:

```fe
fn combine<A: Hashable, B: Printable>(a: A, b: B) -> String {
    let hash = a.hash()
    b.to_string()
}

fn transform<T: Readable, U: Writable>(input: T, output: U) {
    let value = input.read()
    output.write(value)
}
```

## Bounds in Struct Definitions

Generic structs can have bounds:

```fe
struct Cache<T: Hashable> {
    item: T,
    hash: u256,
}

impl<T: Hashable> Cache<T> {
    fn new(item: T) -> Cache<T> {
        let hash = item.hash()
        Cache { item, hash }
    }
}
```

## Bounds in Impl Blocks

Impl blocks can add their own bounds:

```fe
struct Wrapper<T> {
    value: T,
}

// Basic methods, no bounds needed
impl<T> Wrapper<T> {
    fn get(self) -> T {
        self.value
    }
}

// Methods that need Printable
impl<T: Printable> Wrapper<T> {
    fn print(self) -> String {
        self.value.to_string()
    }
}

// Methods that need both traits
impl<T: Hashable + Printable> Wrapper<T> {
    fn describe(self) -> String {
        let _hash = self.value.hash()
        self.value.to_string()
    }
}
```

This means:
- All `Wrapper<T>` have `get()`
- Only `Wrapper<T: Printable>` have `print()`
- Only `Wrapper<T: Hashable + Printable>` have `describe()`

## Common Bound Patterns

### Comparable Types

```fe
trait Comparable {
    fn less_than(self, other: Self) -> bool
    fn equals(self, other: Self) -> bool
}

fn min<T: Comparable>(a: T, b: T) -> T {
    if a.less_than(b) { a } else { b }
}

fn find<T: Comparable>(items: Array<T>, target: T) -> bool {
    for item in items {
        if item.equals(target) {
            return true
        }
    }
    false
}
```

### Default Values

```fe
trait Default {
    fn default() -> Self
}

fn or_default<T: Default>(value: Option<T>) -> T {
    match value {
        Option::Some(v) => v,
        Option::None => T::default(),
    }
}
```

### Cloneable Types

```fe
trait Clone {
    fn clone(self) -> Self
}

fn duplicate<T: Clone>(value: T) -> (T, T) {
    (value.clone(), value)
}
```

## Bounds and Effects

Bounds and effects work together:

```fe
trait Storable {
    fn key(self) -> u256
}

fn save<T: Storable>(item: T) uses mut Storage {
    let key = item.key()
    Storage.set(key, item)
}

fn load<T: Storable + Default>(key: u256) uses Storage -> T {
    Storage.get(key)
}
```

## Error Messages

When bounds aren't satisfied, you get clear errors:

```fe
trait Hashable {
    fn hash(self) -> u256
}

fn process<T: Hashable>(value: T) -> u256 {
    value.hash()
}

struct NoHash {
    data: u256,
}

process(NoHash { data: 1 })
// Error: NoHash does not implement Hashable
```

The error points to the call site, making it easy to understand what's missing.

## Summary

| Syntax | Description |
|--------|-------------|
| `T: Trait` | Single trait bound |
| `T: A + B` | Multiple trait bounds |
| `<T: Trait>` | Bound in function signature |
| `struct Foo<T: Trait>` | Bound in struct definition |
| `impl<T: Trait>` | Bound in impl block |
