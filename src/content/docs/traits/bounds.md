---
title: Trait Bounds
description: Constraining generic types
---

Trait bounds specify what capabilities a generic type must have. They let you write generic code that uses specific methods or behaviors, with the compiler ensuring only valid types are used.

## Basic Bound Syntax

Add a bound with `: Trait` after the type parameter:

```fe
//<hide>
trait Hashable {
    fn hash(self) -> u256
}
//</hide>

fn process<T: Hashable>(value: T) -> u256 {
    value.hash()  // Safe: T must implement Hashable
}
```

Without the bound, you couldn't call `hash()`:

```fe ignore
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
//<hide>
struct String {}
//</hide>
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
// log(Secret { data: 42 })  // Compile error
```

## Multiple Bounds

Require multiple traits with `+`:

```fe
//<hide>
struct String {}
//</hide>

trait Hashable {
    fn hash(self) -> u256
}

trait Printable {
    fn to_string(self) -> String
}

fn describe<T: Hashable + Printable>(value: T) -> String {
    let _hash = value.hash()
    value.to_string()
}
```

The type must implement all specified traits:

```fe
//<hide>
use _boilerplate::{Hashable, Printable}

fn describe<T: Hashable + Printable>(value: T) -> String<31> {
    let _hash = value.hash()
    value.to_string()
}
//</hide>
struct Token {
    id: u256,
}

impl Hashable for Token {
    fn hash(self) -> u256 {
        self.id
    }
}

impl Printable for Token {
    fn to_string(self) -> String<31> {
        "Token"
    }
}

//<hide>
fn __example_describe() {
//</hide>
describe(value: Token { id: 1 })  // Works: Token implements both
//<hide>
}
//</hide>
```

## Bounds on Multiple Parameters

Each type parameter can have its own bounds:

```fe
//<hide>
use _boilerplate::{Hashable, Printable, Readable, Writable}
//</hide>
fn combine<A: Hashable, B: Printable>(a: A, b: B) -> String<31> {
    let hash = a.hash()
    //<hide>
    let _ = hash
    //</hide>
    b.to_string()
}

fn transform<T: Readable, U: Writable>(input: T, var output: own U) {
    let value = input.read()
    output.write(value)
}
```

## Bounds in Struct Definitions

Generic structs can have bounds:

```fe ignore
trait Hashable {
    fn hash(self) -> u256
}

struct Cache<T: Hashable> {
    item: T,
    hash: u256,
}

impl<T: Hashable> Cache<T> {
    fn new(item: own T) -> Cache<T> {
        let hash = item.hash()
        Cache { item, hash }
    }
}
```

## Bounds in Impl Blocks

Impl blocks can add their own bounds:

```fe
//<hide>
struct String {}

trait Printable {
    fn to_string(self) -> String
}

trait Hashable {
    fn hash(self) -> u256
}
//</hide>

struct Wrapper<T> {
    value: T,
}

// Basic methods, no bounds needed
impl<T> Wrapper<T> {
    fn get(own self) -> T {
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

fn min<T: Comparable>(a: own T, b: own T) -> T {
    if a.less_than(other: b) { a } else { b }
}

fn find<T: Comparable>(items: [T; 8], target: T) -> bool {
    for ref item in items {
        if item.equals(other: target) {
            return true
        }
    }
    false
}
```

### Default Values

```fe
fn or_default<T: Default>(value: own Option<T>) -> T {
    match value {
        Option::Some(v) => v,
        Option::None => T::default(),
    }
}
```

### Cloneable Types

```fe
fn duplicate<T: Clone>(value: own T) -> (T, T) {
    (value.clone(), value)
}
```

## Bounds and Effects

Bounds and effects work together:

```fe
trait Storable {
    fn key(self) -> u256
}

struct Registry {
    count: u256,
}
impl Registry {
    fn record(mut self, key: u256) {
        self.count += 1
        let _ = key
    }
    fn total(self) -> u256 {
        self.count
    }
}

// A single bound (Storable) combined with a mutable effect.
fn save<T: Storable>(item: T) uses (reg: mut Registry) {
    reg.record(key: item.key())
}

// Multiple bounds (Storable + Default) with a read-only effect.
fn count_for<T: Storable + Default>() -> u256 uses (reg: Registry) {
    let _ = T::default()
    reg.total()
}
```

## Callable Bounds

A generic parameter can be bounded by a callable shape such as `F: Fn(u256) -> bool`, so the function accepts closures and named functions. See [Closures](/traits/closures/).

## Const Predicates

A `where` clause can also state a boolean condition on const generic parameters. The condition is checked wherever the item is used with concrete values:

```fe
pub struct Ring<const N: usize> where N > 0 {
    items: [u256; N],
}

const fn fits(_ bits: usize) -> bool {
    bits > 0 && bits < 256
}

fn mask<const BITS: usize>() -> u256 where fits(BITS) {
    (1 << (BITS as u256)) - 1
}

#[test]
fn const_predicates() {
    let r = Ring<4> { items: [1, 2, 3, 4] }
    assert!(r.items[0] == 1)
    assert!(mask<8>() == 255)
    // `Ring<0>` or `mask<256>()` would be a compile error:
    // "const requirement is not satisfied"
}
```

A condition can call any `const fn`, and a condition that needs several lines can be written as a block, `where { ... }`. A generic caller satisfies a predicate only by stating the same condition itself. Const predicates are not yet supported on traits, generic trait impls or generic `impl` blocks.

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

// process(NoHash { data: 1 })
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
| `F: Fn(A) -> R` | Callable bound |
| `where N > 0` | Const predicate on const generics |
