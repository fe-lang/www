---
title: Enums
description: Types with multiple distinct variants
---

Enums (enumerations) define a type that can be one of several distinct variants. Each variant can optionally hold data.

## Defining Enums

Define an enum with the `enum` keyword:

```fe ignore
enum Direction {
    North
    South
    East
    West
}
```

Use `pub` for public visibility:

```fe ignore
pub enum Status {
    Active
    Inactive
    Pending
}
```

## Variant Types

Fe supports three kinds of enum variants:

### Unit Variants

Variants with no associated data:

```fe ignore
enum Color {
    Red
    Green
    Blue
}

let color = Color::Red
```

### Tuple Variants

Variants with unnamed fields:

```fe ignore
enum Message {
    Quit
    Move(i32, i32)
    Write(String)
}

let msg = Message::Move(10, 20)
let text = Message::Write("hello")
```

Access tuple variant data through pattern matching.

### Struct Variants

Variants with named fields:

```fe ignore
enum Event {
    Click { x: i32, y: i32 }
    KeyPress { code: u32, shift: bool }
    Resize { width: u32, height: u32 }
}

let event = Event::Click { x: 100, y: 200 }
```

## Using Enums

### Constructing Variants

Use the `EnumName::VariantName` syntax:

```fe ignore
enum Option<T> {
    Some(T)
    None
}

let present = Option::Some(42)
let absent = Option::None
```

### Pattern Matching

Match expressions extract data from enum variants:

```fe ignore
enum Result<T, E> {
    Ok(T)
    Err(E)
}

fn handle_result(result: Result<u256, String>) {
    match result {
        Result::Ok(value) => {
            // Use value
        }
        Result::Err(error) => {
            // Handle error
        }
    }
}
```

### Exhaustive Matching

Match expressions must handle all variants. The compiler enforces this:

```fe ignore
enum Status {
    Active
    Inactive
    Pending
}

match status {
    Status::Active => "running"
    Status::Inactive => "stopped"
    // Error: missing Status::Pending
}
```

Use the wildcard `_` to match remaining variants:

```fe ignore
match status {
    Status::Active => "running"
    _ => "not running"  // Matches Inactive and Pending
}
```

## Pattern Matching Details

### Binding Values

Bind variant data to variables:

```fe ignore
enum Message {
    Text(String)
    Number(u256)
}

match message {
    Message::Text(s) => {
        // s is the String
    }
    Message::Number(n) => {
        // n is the u256
    }
}
```

### Struct Variant Patterns

Match on struct variant fields:

```fe ignore
enum Event {
    Click { x: i32, y: i32 }
}

match event {
    Event::Click { x, y } => {
        // x and y are available
    }
}
```

Use `..` to ignore some fields:

```fe ignore
match event {
    Event::Click { x, .. } => {
        // Only use x, ignore y
    }
}
```

### Nested Patterns

Match nested structures:

```fe ignore
enum Outer {
    Inner(Option<u256>)
}

match outer {
    Outer::Inner(Option::Some(value)) => {
        // Matched nested Some
    }
    Outer::Inner(Option::None) => {
        // Matched nested None
    }
}
```

## Generic Enums

Enums can have type parameters:

```fe ignore
enum Option<T> {
    Some(T)
    None
}

enum Result<T, E> {
    Ok(T)
    Err(E)
}
```

### Using Generic Enums

```fe ignore
fn find_user(id: u256) -> Option<User> {
    if id == 0 {
        return Option::None
    }
    Option::Some(load_user(id))
}

fn divide(a: u256, b: u256) -> Result<u256, String> {
    if b == 0 {
        return Result::Err("division by zero")
    }
    Result::Ok(a / b)
}
```

### Trait Bounds

Constrain generic types:

```fe ignore
enum Container<T: Clone> {
    Single(T)
    Pair(T, T)
}
```

## Enums as Expressions

Match is an expression that returns a value:

```fe ignore
let description = match status {
    Status::Active => "System is running"
    Status::Inactive => "System is stopped"
    Status::Pending => "System is starting"
}
```

All match arms must return the same type.

## Common Patterns

### Option Type

Represent optional values:

```fe ignore
enum Option<T> {
    Some(T)
    None
}

fn get_balance(account_id: u256) -> Option<u256> {
    if account_exists(account_id) {
        Option::Some(load_balance(account_id))
    } else {
        Option::None
    }
}
```

### Result Type

Represent success or failure:

```fe ignore
enum Result<T, E> {
    Ok(T)
    Err(E)
}

fn parse_amount(input: String) -> Result<u256, String> {
    // Returns Ok(amount) or Err(message)
}
```

## Summary

| Syntax | Description |
|--------|-------------|
| `enum Name { }` | Define an enum |
| `Variant` | Unit variant (no data) |
| `Variant(T1, T2)` | Tuple variant |
| `Variant { field: T }` | Struct variant |
| `Enum::Variant` | Construct a variant |
| `match val { }` | Pattern match on enum |
| `Variant(x)` | Bind tuple variant data |
| `Variant { field }` | Bind struct variant data |
| `Variant { .. }` | Ignore struct variant fields |
| `_` | Wildcard pattern |
