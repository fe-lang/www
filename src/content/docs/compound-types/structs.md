---
title: Structs
description: Custom data types with named fields
---

Structs are custom data types that group related values under named fields. They're fundamental for organizing data in Fe programs.

## Defining Structs

Define a struct with the `struct` keyword:

```fe ignore
struct Point {
    x: i32,
    y: i32,
}
```

Each field has a name and a type. Fields are separated by commas.

## Field Visibility

By default, struct fields are private. Use `pub` to make them publicly accessible:

```fe ignore
pub struct User {
    pub name: String,
    pub balance: u256,
    internal_id: u256,  // Private field
}
```

The struct itself can also be public or private:

```fe ignore
pub struct PublicStruct {
    pub field: u256,
}

struct PrivateStruct {
    field: u256,
}
```

## Creating Instances

Create a struct instance by specifying values for all fields:

```fe ignore
struct Point {
    x: i32,
    y: i32,
}

let origin = Point { x: 0, y: 0 }
let point = Point { x: 10, y: 20 }
```

All fields must be initialized—there are no default values.

### Field Init Shorthand

When a variable has the same name as a field, use shorthand syntax:

```fe ignore
let x = 10
let y = 20

let point = Point { x, y }  // Same as Point { x: x, y: y }
```

## Accessing Fields

Access struct fields with dot notation:

```fe ignore
let point = Point { x: 10, y: 20 }

let x_value = point.x  // 10
let y_value = point.y  // 20
```

### Updating Fields

For mutable struct instances, update fields directly:

```fe ignore
let mut point = Point { x: 0, y: 0 }

point.x = 10
point.y = 20
```

## Generic Structs

Structs can have generic type parameters:

```fe ignore
struct Pair<T> {
    first: T,
    second: T,
}

let int_pair = Pair { first: 1, second: 2 }
let bool_pair = Pair { first: true, second: false }
```

### Multiple Type Parameters

Use multiple generic parameters for different field types:

```fe ignore
struct KeyValue<K, V> {
    key: K,
    value: V,
}

let entry = KeyValue { key: "name", value: 42 }
```

### Trait Bounds

Constrain generic types with trait bounds:

```fe ignore
struct Container<T: Default> {
    item: T,
}
```

## Nested Structs

Structs can contain other structs:

```fe ignore
struct Point {
    x: i32,
    y: i32,
}

struct Rectangle {
    top_left: Point,
    bottom_right: Point,
}

let rect = Rectangle {
    top_left: Point { x: 0, y: 10 },
    bottom_right: Point { x: 10, y: 0 },
}

let x = rect.top_left.x  // 0
```

## Struct Patterns

Destructure structs in patterns:

```fe ignore
let point = Point { x: 10, y: 20 }

let Point { x, y } = point
// x is 10, y is 20
```

Use `..` to ignore remaining fields:

```fe ignore
struct User {
    name: String,
    balance: u256,
    created_at: u256,
}

let User { name, .. } = user  // Only extract name
```

### Patterns in Match

Match on struct patterns:

```fe ignore
match point {
    Point { x: 0, y: 0 } => "origin"
    Point { x: 0, y } => "on y-axis"
    Point { x, y: 0 } => "on x-axis"
    Point { x, y } => "somewhere else"
}
```

## Structs with Tuples

Combine structs and tuples:

```fe ignore
struct Line {
    start: (i32, i32),
    end: (i32, i32),
}

let line = Line {
    start: (0, 0),
    end: (100, 100),
}

let start_x = line.start.0
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
