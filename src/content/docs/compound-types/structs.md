---
title: Structs
description: Custom data types with named fields
---

Structs are custom data types that group related values under named fields. They're fundamental for organizing data in Fe programs.

## Defining Structs

Define a struct with the `struct` keyword:

```fe
struct Point {
    x: i32,
    y: i32,
}
```

Each field has a name and a type. Fields are separated by commas.

## Field Visibility

By default, struct fields are private. Use `pub` to make them publicly accessible:

```fe
pub struct User {
    pub name: String<20>,
    pub balance: u256,
    internal_id: u256,  // Private field
}
```

The struct itself can also be public or private:

```fe
pub struct PublicStruct {
    pub field: u256,
}

struct PrivateStruct {
    field: u256,
}
```

## Creating Instances

Create a struct instance by specifying values for all fields:

```fe
struct Point {
    x: i32,
    y: i32,
}

//<hide>
fn example() {
//</hide>
let origin = Point { x: 0, y: 0 }
let point = Point { x: 10, y: 20 }
//<hide>
let _ = (origin, point)
}
//</hide>
```

All fields must be initialized. There are no default values.

### Field Init Shorthand

When a variable has the same name as a field, use shorthand syntax:

```fe
//<hide>
struct Point {
    x: i32,
    y: i32,
}

fn example() {
//</hide>
let x: i32 = 10
let y: i32 = 20

let point = Point { x, y }  // Same as Point { x: x, y: y }
//<hide>
let _ = point
}
//</hide>
```

## Accessing Fields

Access struct fields with dot notation:

```fe
//<hide>
struct Point {
    x: i32,
    y: i32,
}

fn example() {
//</hide>
let point = Point { x: 10, y: 20 }

let x_value = point.x  // 10
let y_value = point.y  // 20
//<hide>
let _ = (x_value, y_value)
}
//</hide>
```

### Updating Fields

For mutable struct instances, update fields directly:

```fe
//<hide>
struct Point {
    x: i32,
    y: i32,
}

fn example() {
//</hide>
let mut point = Point { x: 0, y: 0 }

point.x = 10
point.y = 20
//<hide>
let _ = point
}
//</hide>
```

## Generic Structs

Structs can have generic type parameters:

```fe
struct Pair<T> {
    first: T,
    second: T,
}

//<hide>
fn example() {
//</hide>
let int_pair: Pair<u256> = Pair { first: 1, second: 2 }
let bool_pair = Pair { first: true, second: false }
//<hide>
let _ = (int_pair, bool_pair)
}
//</hide>
```

### Multiple Type Parameters

Use multiple generic parameters for different field types:

```fe
struct KeyValue<K, V> {
    key: K,
    value: V,
}

//<hide>
fn example() {
//</hide>
let entry: KeyValue<String<4>, u256> = KeyValue { key: "name", value: 42 }
//<hide>
let _ = entry
}
//</hide>
```

### Trait Bounds

Constrain generic types with trait bounds:

```fe
//<hide>
use _boilerplate::Default
//</hide>

struct Container<T: Default> {
    item: T,
}
```

## Nested Structs

Structs can contain other structs:

```fe
struct Point {
    x: i32,
    y: i32,
}

struct Rectangle {
    top_left: Point,
    bottom_right: Point,
}

//<hide>
fn example() {
//</hide>
let rect = Rectangle {
    top_left: Point { x: 0, y: 10 },
    bottom_right: Point { x: 10, y: 0 },
}

let x = rect.top_left.x  // 0
//<hide>
let _ = x
}
//</hide>
```

## Struct Patterns

Destructure structs in patterns:

```fe
//<hide>
struct Point {
    x: i32,
    y: i32,
}

fn example() {
//</hide>
let point = Point { x: 10, y: 20 }

let Point { x, y } = point
// x is 10, y is 20
//<hide>
let _ = (x, y)
}
//</hide>
```

Use `..` to ignore remaining fields:

```fe
struct User {
    name: u256,
    balance: u256,
    created_at: u256,
}

//<hide>
fn example() {
let user = User { name: 1, balance: 100, created_at: 500 }
//</hide>
let User { name, .. } = user  // Only extract name
//<hide>
let _ = name
}
//</hide>
```

### Patterns in Match

Match on struct patterns:

```fe
//<hide>
struct Point {
    x: i32,
    y: i32,
}

fn example() {
let point = Point { x: 5, y: 10 }
//</hide>
let location = match point {
    Point { x: 0, y: 0 } => "origin"
    Point { x: 0, y: _ } => "on y-axis"
    Point { x: _, y: 0 } => "on x-axis"
    Point { x: _, y: _ } => "somewhere else"
}
//<hide>
let _ = location
}
//</hide>
```

## Structs with Tuples

Combine structs and tuples:

```fe
struct Line {
    start: (i32, i32),
    end: (i32, i32),
}

//<hide>
fn example() {
//</hide>
let line = Line {
    start: (0, 0),
    end: (100, 100),
}

let start_x = line.start.0
//<hide>
let _ = start_x
}
//</hide>
```

## Summary

| Syntax | Description |
|--------|-------------|
| `struct Name { }` | Define a struct |
| `pub field: Type` | Public field |
| `Struct { field: value }` | Create instance |
| `Struct { field }` | Shorthand when variable matches field name |
| `instance.field` | Access field |
| `struct Name<T>` | Generic struct |
| `let Struct { field } = s` | Destructure struct |
| `let Struct { field, .. } = s` | Destructure, ignoring other fields |
