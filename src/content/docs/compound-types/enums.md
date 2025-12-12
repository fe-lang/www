---
title: Enums
description: Types with multiple distinct variants
---

Enums (enumerations) define a type that can be one of several distinct variants. Each variant can optionally hold data.

## Defining Enums

Define an enum with the `enum` keyword:

```fe
enum Direction {
    North,
    South,
    East,
    West,
}
```

Use `pub` for public visibility:

```fe
pub enum Status {
    Active,
    Inactive,
    Pending,
}
```

## Variant Types

Fe supports three kinds of enum variants:

### Unit Variants

Variants with no associated data:

```fe
enum Color {
    Red,
    Green,
    Blue,
}

//<hide>
fn example() {
//</hide>
let color = Color::Red
//<hide>
let _ = color
}
//</hide>
```

### Tuple Variants

Variants with unnamed fields:

```fe
enum Message {
    Quit,
    Move(i32, i32),
    Write(String<20>),
}

//<hide>
fn example() {
//</hide>
let message = Message::Move(10, 20)
let text = Message::Write("hello")
//<hide>
let _ = (message, text)
}
//</hide>
```

Access tuple variant data through pattern matching.

### Struct Variants

Variants with named fields:

```fe
enum Event {
    Click { x: i32, y: i32 },
    KeyPress { code: u32, shift: bool },
    Resize { width: u32, height: u32 },
}

//<hide>
fn example() {
//</hide>
let event = Event::Click { x: 100, y: 200 }
//<hide>
let _ = event
}
//</hide>
```

## Using Enums

### Constructing Variants

Use the `EnumName::VariantName` syntax:

```fe
enum Option<T> {
    Some(T),
    None,
}

//<hide>
fn example() {
//</hide>
let present: Option<u256> = Option::Some(42)
let absent: Option<u256> = Option::None
//<hide>
let _ = (present, absent)
}
//</hide>
```

### Pattern Matching

Match expressions extract data from enum variants:

```fe
enum Result<T, E> {
    Ok(T),
    Err(E),
}

fn handle_result(result: Result<u256, String<20>>) {
    match result {
        Result::Ok(value) => {
            // Use value
            //<hide>
            let _ = value
            //</hide>
        }
        Result::Err(error) => {
            // Handle error
            //<hide>
            let _ = error
            //</hide>
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

```fe
//<hide>
enum Status {
    Active,
    Inactive,
    Pending,
}

fn example() {
let status = Status::Inactive
//</hide>
let description = match status {
    Status::Active => "running"
    _ => "not running"  // Matches Inactive and Pending
}
//<hide>
let _ = description
}
//</hide>
```

## Pattern Matching Details

### Binding Values

Bind variant data to variables:

```fe
enum Message {
    Text(String<20>),
    Number(u256),
}

//<hide>
fn example() {
let message = Message::Number(42)
//</hide>
match message {
    Message::Text(s) => {
        // s is the String
        //<hide>
        let _ = s
        //</hide>
    }
    Message::Number(n) => {
        // n is the u256
        //<hide>
        let _ = n
        //</hide>
    }
}
//<hide>
}
//</hide>
```

### Struct Variant Patterns

Match on struct variant fields:

```fe
enum Event {
    Click { x: i32, y: i32 },
}

//<hide>
fn example() {
let event = Event::Click { x: 10, y: 20 }
//</hide>
match event {
    Event::Click { x, y } => {
        // x and y are available
        //<hide>
        let _ = (x, y)
        //</hide>
    }
}
//<hide>
}
//</hide>
```

Use `..` to ignore some fields:

```fe
//<hide>
enum Event {
    Click { x: i32, y: i32 },
}

fn example() {
let event = Event::Click { x: 10, y: 20 }
//</hide>
match event {
    Event::Click { x, .. } => {
        // Only use x, ignore y
        //<hide>
        let _ = x
        //</hide>
    }
}
//<hide>
}
//</hide>
```

### Nested Patterns

Match nested structures:

```fe
//<hide>
enum Option<T> {
    Some(T),
    None,
}

//</hide>
enum Outer {
    Inner(Option<u256>),
}

//<hide>
fn example() {
let outer = Outer::Inner(Option::Some(42))
//</hide>
match outer {
    Outer::Inner(Option::Some(value)) => {
        // Matched nested Some
        //<hide>
        let _ = value
        //</hide>
    }
    Outer::Inner(Option::None) => {
        // Matched nested None
    }
}
//<hide>
}
//</hide>
```

## Generic Enums

Enums can have type parameters:

```fe
enum Option<T> {
    Some(T),
    None,
}

enum Result<T, E> {
    Ok(T),
    Err(E),
}
```

### Using Generic Enums

```fe
//<hide>
enum Option<T> {
    Some(T),
    None,
}

enum Result<T, E> {
    Ok(T),
    Err(E),
}

struct User { pub id: u256 }
fn load_user(id: u256) -> User { User { id } }
//</hide>
fn find_user(id: u256) -> Option<User> {
    if id == 0 {
        return Option::None
    }
    Option::Some(load_user(id))
}

fn divide(a: u256, b: u256) -> Result<u256, String<20>> {
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

```fe
//<hide>
enum Status {
    Active,
    Inactive,
    Pending,
}

fn example() {
let status = Status::Active
//</hide>
let description = match status {
    Status::Active => "System is running"
    Status::Inactive => "System is stopped"
    Status::Pending => "System is starting"
}
//<hide>
let _ = description
}
//</hide>
```

All match arms must return the same type.

## Common Patterns

### Option Type

Represent optional values:

```fe
enum Option<T> {
    Some(T),
    None,
}

//<hide>
fn account_exists(id: u256) -> bool { id != 0 }
fn load_balance(id: u256) -> u256 { id * 100 }
//</hide>
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
