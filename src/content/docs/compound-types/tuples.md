---
title: Tuples
description: Fixed-size collections of values with different types
---

Tuples group multiple values of different types into a single compound value. They have a fixed length determined at compile time.

## Tuple Types

Declare a tuple type by listing element types in parentheses:

```fe ignore
let point: (i32, i32) = (10, 20)
let mixed: (u256, bool, String) = (100, true, "hello")
```

## Creating Tuples

Create tuples by listing values in parentheses:

```fe ignore
let coordinates = (100, 200)
let user_data = (address, balance, is_active)
```

### Single-Element Tuples

A single-element tuple requires a trailing comma to distinguish it from a parenthesized expression:

```fe ignore
let single: (u256,) = (42,)  // This is a tuple
let not_tuple: u256 = (42)   // This is just 42
```

### Empty Tuples

The empty tuple `()` is called the "unit" type. It represents the absence of a value:

```fe ignore
let nothing: () = ()
```

Functions that don't return a value implicitly return `()`.

## Accessing Elements

Access tuple elements by index using dot notation:

```fe ignore
let point = (10, 20, 30)

let x = point.0  // 10
let y = point.1  // 20
let z = point.2  // 30
```

Indices start at 0 and must be literal integers—you cannot use a variable as an index.

## Destructuring

Extract all tuple elements at once with pattern matching:

```fe ignore
let point = (100, 200)
let (x, y) = point

// x is 100, y is 200
```

Use `_` to ignore elements you don't need:

```fe ignore
let data = (address, amount, timestamp)
let (_, amount, _) = data  // Only extract amount
```

### Destructuring in Function Parameters

Destructure tuples directly in function signatures:

```fe ignore
fn process_point((x, y): (i32, i32)) -> i32 {
    x + y
}
```

## Tuples in Functions

### Returning Multiple Values

Tuples are commonly used to return multiple values from a function:

```fe ignore
fn get_bounds() -> (u256, u256) {
    (0, 1000)
}

let (min, max) = get_bounds()
```

### Tuple Parameters

Pass tuples as function arguments:

```fe ignore
fn calculate_distance(start: (i32, i32), end: (i32, i32)) -> i32 {
    let (x1, y1) = start
    let (x2, y2) = end
    // ... distance calculation
}
```

## Nested Tuples

Tuples can contain other tuples:

```fe ignore
let nested: ((i32, i32), (i32, i32)) = ((0, 0), (100, 100))

let start = nested.0      // (0, 0)
let start_x = nested.0.0  // 0
```

## Tuples in Match Expressions

Match on tuple patterns:

```fe ignore
let point = (0, 5)

match point {
    (0, 0) => "origin"
    (0, y) => "on y-axis"
    (x, 0) => "on x-axis"
    (x, y) => "somewhere else"
}
```

## Summary

| Syntax | Description |
|--------|-------------|
| `(T1, T2, T3)` | Tuple type with three elements |
| `(a, b, c)` | Tuple expression |
| `(a,)` | Single-element tuple |
| `()` | Empty tuple (unit) |
| `tuple.0` | Access first element |
| `let (a, b) = tuple` | Destructure tuple |
| `let (_, b) = tuple` | Destructure, ignoring first |
