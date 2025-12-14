---
title: Generic Functions
description: Writing type-polymorphic code
---

Generic functions work with multiple types using type parameters. Instead of writing separate functions for each type, you write one function that works for any type meeting certain requirements.

## Basic Syntax

Define a generic function with type parameters in angle brackets:

```fe
fn identity<T>(value: T) -> T {
    value
}
```

`T` is a type parameter—a placeholder for any concrete type. When called, the compiler substitutes the actual type:

```fe
let x = identity(42)        // T is u256
let y = identity(true)      // T is bool
```

## Multiple Type Parameters

Functions can have multiple type parameters:

```fe
fn pair<A, B>(first: A, second: B) -> (A, B) {
    (first, second)
}

let p = pair(1, true)  // (u256, bool)
```

## Type Parameters with Bounds

Usually, you need to constrain what types are allowed. Use trait bounds:

```fe
trait Printable {
    fn to_string(self) -> String
}

fn print_value<T: Printable>(value: T) -> String {
    value.to_string()
}
```

Now `print_value` only accepts types that implement `Printable`:

```fe
struct Message {
    text: String,
}

impl Printable for Message {
    fn to_string(self) -> String {
        self.text
    }
}

let msg = Message { text: "Hello" }
print_value(msg)  // Works: Message implements Printable
```

## Generic Structs

Structs can also be generic:

```fe
struct Wrapper<T> {
    value: T,
}

impl<T> Wrapper<T> {
    fn new(value: T) -> Wrapper<T> {
        Wrapper { value }
    }

    fn get(self) -> T {
        self.value
    }
}

let w = Wrapper::new(42)
let v = w.get()  // 42
```

## Generic Methods

Methods can introduce their own type parameters:

```fe
struct Container<T> {
    item: T,
}

impl<T> Container<T> {
    fn get(self) -> T {
        self.item
    }

    // Method with its own type parameter
    fn map<U>(self, f: fn(T) -> U) -> Container<U> {
        Container { item: f(self.item) }
    }
}
```

## Why Generics?

### Code Reuse

Write once, use with many types:

```fe
// Without generics: separate functions for each type
fn max_u256(a: u256, b: u256) -> u256 {
    if a > b { a } else { b }
}

fn max_i256(a: i256, b: i256) -> i256 {
    if a > b { a } else { b }
}

// With generics: one function
fn max<T: Comparable>(a: T, b: T) -> T {
    if a.greater_than(b) { a } else { b }
}
```

### Type Safety

Generics preserve type information:

```fe
fn first<T>(items: Array<T>) -> T {
    items[0]
}

let numbers: Array<u256> = [1, 2, 3]
let n = first(numbers)  // n is u256, not a generic "any" type
```

## Calling Generic Functions

### Type Inference

Usually the compiler infers types:

```fe
let x = identity(42)  // Compiler infers T = u256
```

### Explicit Type Arguments

Sometimes you need to specify types explicitly:

```fe
let x = identity::<u256>(42)
```

## Common Patterns

### Swap Function

```fe
fn swap<T>(a: T, b: T) -> (T, T) {
    (b, a)
}

let (x, y) = swap(1, 2)  // (2, 1)
```

### Optional/Default Pattern

```fe
fn or_default<T: Default>(value: Option<T>) -> T {
    match value {
        Option::Some(v) => v,
        Option::None => T::default(),
    }
}
```

### Transform Pattern

```fe
trait Transform {
    fn transform(self) -> Self
}

fn apply_twice<T: Transform>(value: T) -> T {
    value.transform().transform()
}
```

## Constraints

### Single Bound

```fe
fn process<T: Hashable>(item: T) -> u256 {
    item.hash()
}
```

### Multiple Bounds

```fe
fn process<T: Hashable + Printable>(item: T) -> String {
    let hash = item.hash()
    item.to_string()
}
```

See [Trait Bounds](/traits/bounds/) for more on constraining generics.

## Generics vs Effects

Generics and effects serve different purposes:

| Generics | Effects |
|----------|---------|
| Type polymorphism | Capability tracking |
| Compile-time resolution | Runtime behavior |
| `fn foo<T>(x: T)` | `fn foo() uses Storage` |

They can be combined:

```fe
fn get_value<T: Readable>(key: u256) uses Storage -> T {
    // Generic return type with storage effect
    Storage.get(key)
}
```

## Summary

| Syntax | Description |
|--------|-------------|
| `fn foo<T>()` | Generic function with type parameter |
| `fn foo<T: Trait>()` | Bounded type parameter |
| `fn foo<A, B>()` | Multiple type parameters |
| `foo::<Type>()` | Explicit type argument |
| `struct Foo<T>` | Generic struct |
| `impl<T> Foo<T>` | Generic implementation |
