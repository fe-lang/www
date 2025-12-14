---
title: Trait Definition
description: Defining shared behavior across types
---

Traits define shared behavior that types can implement. They're Fe's way of expressing interfaces and enabling polymorphism—similar to traits in Rust or interfaces in other languages.

## Basic Syntax

Define a trait with the `trait` keyword:

```fe ignore
trait Drawable {
    fn draw(self)
}
```

This defines a trait called `Drawable` with one required method `draw`.

## Required Methods

Traits declare methods that implementing types must provide:

```fe ignore
trait Summary {
    fn summarize(self) -> String
}

trait Comparable {
    fn compare(self, other: Self) -> i32
}

trait Container {
    fn len(self) -> u256
    fn is_empty(self) -> bool
}
```

Each method signature specifies:
- The method name
- Parameters (including `self`)
- Return type

## The Self Type

In trait definitions, `Self` refers to the implementing type:

```fe ignore
trait Cloneable {
    fn clone(self) -> Self  // Returns the same type that implements this trait
}

trait Addable {
    fn add(self, other: Self) -> Self  // Works with two values of the same type
}
```

## Traits with Multiple Methods

Traits can require multiple methods:

```fe ignore
trait Token {
    fn balance_of(self, account: u256) -> u256
    fn transfer(mut self, to: u256, amount: u256) -> bool
    fn total_supply(self) -> u256
}

trait Owned {
    fn owner(self) -> u256
    fn transfer_ownership(mut self, new_owner: u256)
    fn renounce_ownership(mut self)
}
```

## Trait Visibility

Make traits public with `pub`:

```fe ignore
pub trait Serializable {
    fn serialize(self) -> Array<u8>
    fn deserialize(data: Array<u8>) -> Self
}
```

Public traits can be implemented by types in other modules.

## Method Parameters

Trait methods can have various parameter types:

```fe ignore
trait Calculator {
    // Only self
    fn value(self) -> u256

    // Self and primitives
    fn add(mut self, amount: u256)

    // Self and custom types
    fn apply(mut self, config: Config)

    // Mutable self
    fn reset(mut self)
}
```

## Designing Good Traits

### Single Responsibility

Each trait should represent one capability:

```fe ignore
// Good: focused traits
trait Readable {
    fn read(self) -> u256
}

trait Writable {
    fn write(mut self, value: u256)
}

// Less ideal: combined responsibilities
trait ReadWritable {
    fn read(self) -> u256
    fn write(mut self, value: u256)
}
```

### Composable Traits

Design traits that can be combined:

```fe ignore
trait Identifiable {
    fn id(self) -> u256
}

trait Nameable {
    fn name(self) -> String
}

trait Timestamped {
    fn created_at(self) -> u256
    fn updated_at(self) -> u256
}

// A type can implement all three
```

## Trait Use Cases

### Defining Interfaces

```fe ignore
trait ERC20 {
    fn total_supply(self) -> u256
    fn balance_of(self, account: u256) -> u256
    fn transfer(mut self, to: u256, amount: u256) -> bool
    fn allowance(self, owner: u256, spender: u256) -> u256
    fn approve(mut self, spender: u256, amount: u256) -> bool
    fn transfer_from(mut self, from: u256, to: u256, amount: u256) -> bool
}
```

### Enabling Polymorphism

```fe ignore
trait Validator {
    fn is_valid(self) -> bool
}

// Now generic functions can accept any Validator
fn process<T: Validator>(item: T) -> bool {
    item.is_valid()
}
```

### Standardizing Behavior

```fe ignore
trait Hashable {
    fn hash(self) -> u256
}

trait Comparable {
    fn equals(self, other: Self) -> bool
    fn less_than(self, other: Self) -> bool
}
```

## Summary

| Syntax | Description |
|--------|-------------|
| `trait Name { }` | Define a trait |
| `pub trait` | Public trait |
| `fn method(self)` | Required method |
| `fn method(mut self)` | Mutating method |
| `Self` | The implementing type |
| `-> Type` | Method return type |
