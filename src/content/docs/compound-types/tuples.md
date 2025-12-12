---
title: Tuples
description: Fixed-size collections of values with different types
---

Tuples group multiple values of different types into a single compound value. They have a fixed length determined at compile time.

## Tuple Types

Declare a tuple type by listing element types in parentheses:

```fe
//<hide>
fn example() {
//</hide>
let point: (i32, i32) = (10, 20)
let mixed: (u256, bool, String<5>) = (100, true, "hello")
//<hide>
let _ = (point, mixed)
}
//</hide>
```

## Creating Tuples

Create tuples by listing values in parentheses:

```fe
//<hide>
fn example() {
let address: u256 = 0x1234
let balance: u256 = 1000
let is_active = true
//</hide>
let coordinates: (u256, u256) = (100, 200)
let user_data = (address, balance, is_active)
//<hide>
let _ = (coordinates, user_data)
}
//</hide>
```

### Single-Element Tuples

A single-element tuple requires a trailing comma to distinguish it from a parenthesized expression:

```fe
//<hide>
fn example() {
//</hide>
let single: (u256,) = (42,)  // This is a tuple
let not_tuple: u256 = (42)   // This is just 42
//<hide>
let _ = (single, not_tuple)
}
//</hide>
```

### Empty Tuples

The empty tuple `()` is called the "unit" type. It represents the absence of a value:

```fe
//<hide>
fn example() {
//</hide>
let nothing: () = ()
//<hide>
let _ = nothing
}
//</hide>
```

Functions that don't return a value implicitly return `()`.

## Accessing Elements

Access tuple elements by index using dot notation:

```fe
//<hide>
fn example() {
//</hide>
let point: (i32, i32, i32) = (10, 20, 30)

let x = point.0  // 10
let y = point.1  // 20
let z = point.2  // 30
//<hide>
let _ = (x, y, z)
}
//</hide>
```

Indices start at 0 and must be literal integers. You cannot use a variable as an index.

## Destructuring

Extract all tuple elements at once with pattern matching:

```fe
//<hide>
fn example() {
//</hide>
let point: (u256, u256) = (100, 200)
let (x, y) = point

// x is 100, y is 200
//<hide>
let _ = (x, y)
}
//</hide>
```

Use `_` to ignore elements you don't need:

```fe
//<hide>
fn example() {
let address: u256 = 0x1234
let amount: u256 = 500
let timestamp: u256 = 1234567890
//</hide>
let data = (address, amount, timestamp)
let (_, amount, _) = data  // Only extract amount
//<hide>
let _ = amount
}
//</hide>
```

### Destructuring in Function Parameters

Accept a tuple parameter and destructure it in the function body:

```fe
fn process_point(point: (i32, i32)) -> i32 {
    let (x, y) = point
    x + y
}
```

## Tuples in Functions

### Returning Multiple Values

Tuples are commonly used to return multiple values from a function:

```fe
fn get_bounds() -> (u256, u256) {
    (0, 1000)
}

//<hide>
fn example() {
//</hide>
let (min, max) = get_bounds()
//<hide>
let _ = (min, max)
}
//</hide>
```

### Tuple Parameters

Pass tuples as function arguments:

```fe
fn calculate_distance(start: (i32, i32), end: (i32, i32)) -> i32 {
    let (x1, y1) = start
    let (x2, y2) = end
    //<hide>
    let _ = (x1, y1, x2, y2)
    //</hide>
    // ... distance calculation
    //<hide>
    0
    //</hide>
}
```

## Nested Tuples

Tuples can contain other tuples:

```fe
//<hide>
fn example() {
//</hide>
let nested: ((i32, i32), (i32, i32)) = ((0, 0), (100, 100))

let start = nested.0      // (0, 0)
let start_x = nested.0.0  // 0
//<hide>
let _ = (start, start_x)
}
//</hide>
```

## Tuples in Match Expressions

Match on tuple patterns:

```fe
//<hide>
fn example() {
//</hide>
let point: (u256, u256) = (0, 5)

let location = match point {
    (0, 0) => "origin"
    (0, _) => "on y-axis"
    (_, 0) => "on x-axis"
    (_, _) => "somewhere else"
}
//<hide>
let _ = location
}
//</hide>
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
