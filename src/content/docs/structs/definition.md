---
title: Struct Definition
description: Defining custom types with fields
---

Structs are custom data types that group related values together. They're one of Fe's primary tools for organizing data and behavior.

## Basic Syntax

Define a struct with the `struct` keyword:

```fe ignore
struct Point {
    x: u256,
    y: u256,
}
```

Each field has a name and a type, separated by a colon.

## Field Visibility

By default, struct fields are private. Use `pub` to make them publicly accessible:

```fe ignore
struct Token {
    pub name: String,       // Public - accessible from outside
    pub symbol: String,     // Public
    pub decimals: u8,       // Public
    internal_id: u256,      // Private - only accessible within the module
}
```

## Public Structs

Make the entire struct public with `pub struct`:

```fe ignore
pub struct TokenInfo {
    pub name: String,
    pub total_supply: u256,
}
```

A `pub struct` can be used by other modules, but its fields still need individual `pub` modifiers to be accessible.

## Creating Instances

Create struct instances using struct literal syntax:

```fe ignore
let point = Point { x: 10, y: 20 }
```

All fields must be provided:

```fe ignore
struct Rectangle {
    width: u256,
    height: u256,
}

let rect = Rectangle {
    width: 100,
    height: 50,
}
```

## Accessing Fields

Access fields with dot notation:

```fe ignore
let p = Point { x: 10, y: 20 }
let x_value = p.x  // 10
let y_value = p.y  // 20
```

## Updating Structs

Structs are immutable by default. To modify, use `mut`:

```fe ignore
let mut p = Point { x: 10, y: 20 }
p.x = 30  // Now p is { x: 30, y: 20 }
```

## Nested Structs

Structs can contain other structs:

```fe ignore
struct Bounds {
    min: Point,
    max: Point,
}

let bounds = Bounds {
    min: Point { x: 0, y: 0 },
    max: Point { x: 100, y: 100 },
}

let min_x = bounds.min.x  // 0
```

## Structs with Complex Types

Structs can hold any Fe type:

```fe ignore
struct GameState {
    score: u256,
    position: (u256, u256),       // Tuple
    active: bool,
}

struct Registry {
    entries: StorageMap<u256, u256>,  // For storage structs
    count: u256,
}
```

## Destructuring

Extract fields with pattern matching:

```fe ignore
let p = Point { x: 10, y: 20 }

// Destructure into variables
let Point { x, y } = p
// x is 10, y is 20

// Rename during destructuring
let Point { x: horizontal, y: vertical } = p
// horizontal is 10, vertical is 20

// Partial destructuring
let Point { x, .. } = p
// Only extract x, ignore other fields
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
