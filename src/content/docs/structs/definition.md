---
title: Struct Definition
description: Defining custom types with fields
---

Structs are custom data types that group related values together. They're one of Fe's primary tools for organizing data and behavior.

## Basic Syntax

Define a struct with the `struct` keyword:

```fe
struct Point {
    x: u256,
    y: u256,
}
```

Each field has a name and a type, separated by a colon.

## Field Visibility

By default, struct fields are private. Use `pub` to make them publicly accessible:

```fe
//<hide>
struct String {}
//</hide>

struct Token {
    pub name: String,       // Public - accessible from outside
    pub symbol: String,     // Public
    pub decimals: u8,       // Public
    internal_id: u256,      // Private - only accessible within the module
}
```

## Public Structs

Make the entire struct public with `pub struct`:

```fe
//<hide>
struct String {}
//</hide>

pub struct TokenInfo {
    pub name: String,
    pub total_supply: u256,
}
```

A `pub struct` can be used by other modules, but its fields still need individual `pub` modifiers to be accessible.

## Creating Instances

Create struct instances using struct literal syntax:

```fe
//<hide>
struct Point {
    x: u256,
    y: u256,
}
//</hide>

//<hide>
fn create_point() {
//</hide>
let point = Point { x: 10, y: 20 }
//<hide>
    let _ = point
}
```

All fields must be provided:

```fe
//<hide>
struct Rectangle {
    width: u256,
    height: u256,
}

fn create_rectangle() {
//</hide>
let rect = Rectangle {
    width: 100,
    height: 50,
}
//<hide>
    let _ = rect
}
```

## Accessing Fields

Access fields with dot notation:

```fe
//<hide>
struct Point {
    x: u256,
    y: u256,
}
//</hide>

//<hide>
fn access_fields() {
//</hide>
let p = Point { x: 10, y: 20 }
let x_value = p.x  // 10
let y_value = p.y  // 20
//<hide>
    let _ = (x_value, y_value)
}
```

## Updating Structs

Structs are immutable by default. To modify, use `mut`:

```fe
//<hide>
struct Point {
    x: u256,
    y: u256,
}
//</hide>

//<hide>
fn update_point() {
//</hide>
var p = Point { x: 10, y: 20 }
p.x = 30  // Now p is { x: 30, y: 20 }
//<hide>
    let _ = p
}
```

## Nested Structs

Structs can contain other structs:

```fe
//<hide>
struct Point {
    x: u256,
    y: u256,
}
//</hide>

struct Bounds {
    min: Point,
    max: Point,
}

//<hide>
fn nested_structs() {
//</hide>
let bounds = Bounds {
    min: Point { x: 0, y: 0 },
    max: Point { x: 100, y: 100 },
}

let min_x = bounds.min.x  // 0
//<hide>
    let _ = min_x
}
```

## Structs with Complex Types

Structs can hold any Fe type:

```fe
struct GameState {
    score: u256,
    position: (u256, u256),       // Tuple
    active: bool,
}

struct Registry {
    entries: StorageMap<u256, u256>,  // For storage structs
    count: u256,
}

//<hide>
struct StorageMap<K, V> {
    // placeholder storage map for example purposes
}
//</hide>
```

## Destructuring

Extract fields with pattern matching:

```fe
//<hide>
struct Point {
    x: u256,
    y: u256,
}
//</hide>

//<hide>
fn destructure_point() {
//</hide>
// Destructure into variables
let Point { x, y } = Point { x: 10, y: 20 }
//<hide>
    let _ = (x, y)
//</hide>

// Rename during destructuring
let Point { x: horizontal, y: vertical } = Point { x: 10, y: 20 }
//<hide>
    let _ = (horizontal, vertical)
//</hide>

// Partial destructuring
let Point { x, .. } = Point { x: 10, y: 20 }
//<hide>
    let _ = x
}
```

## Tuple Structs

A tuple struct has positional fields instead of named ones. It is a lightweight way to write a *newtype*, a distinct type that wraps another one:

```fe
pub struct Month(pub u8)

pub struct Pair<T>(pub T, pub T)

fn days_in(_ month: Month) -> u8 {
    match month {
        Month(2) => 28,
        Month(4) | Month(6) | Month(9) | Month(11) => 30,
        _ => 31,
    }
}

#[test]
fn tuple_structs() {
    var m = Month(10)
    m.0 = 11
    assert!(days_in(m) == 30)

    let Month(raw) = m
    assert!(raw == 11)

    let p = Pair<u256>(1, 2)
    assert!(p.0 + p.1 == 3)
}
```

Construct a tuple struct by calling its name like a function, access fields by position (`m.0`), and destructure it with a tuple pattern. Fields are private unless marked `pub`. Tuple structs can be generic and can be used as contract storage fields, but `#[event]`, `#[error]` and `#[abi]` require named fields.

## Structs vs Contracts

An important distinction in Fe:

| Feature | Structs | Contracts |
|---------|---------|-----------|
| Fields | ✓ | ✓ |
| Impl blocks | ✓ | ✗ |
| Methods | ✓ | ✗ |
| Init block | ✗ | ✓ |
| Recv blocks | ✗ | ✓ |

Structs are for data and behavior. Contracts are for on-chain state and message handling.

## Summary

| Syntax | Description |
|--------|-------------|
| `struct Name { }` | Define a struct |
| `pub struct` | Public struct |
| `pub field: Type` | Public field |
| `Name { field: value }` | Create instance |
| `instance.field` | Access field |
| `let Name { field } = instance` | Destructure |
| `struct Name(pub T)` | Tuple struct |
| `Name(value)`, `instance.0` | Create / access a tuple struct |
