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
let mut p = Point { x: 10, y: 20 }
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
let p = Point { x: 10, y: 20 }

// Destructure into variables
let Point { x, y } = p
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
