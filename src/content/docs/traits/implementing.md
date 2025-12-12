---
title: Implementing Traits
description: Adding trait behavior to types
---

Once a trait is defined, types can implement it to provide the required behavior. This is done with the `impl Trait for Type` syntax.

## Basic Implementation

Implement a trait for a struct:

```fe
//<hide>
struct String {}
//</hide>

trait Greetable {
    fn greet(self) -> String
}

struct Person {
    name: String,
}

impl Greetable for Person {
    fn greet(self) -> String {
        self.name
    }
}
```

Now `Person` has the `greet` method:

```fe
//<hide>
struct String {}


trait Greetable {
    fn greet(self) -> String
}

struct Person {
    name: String,
}

impl Greetable for Person {
    fn greet(self) -> String {
        self.name
    }
}

fn show_greeting() {
//</hide>
let person = Person { name: String {} }
let greeting: String = person.greet()  // "Alice"
//<hide>
    let _ = greeting
}
```

## Implementing All Methods

You must implement every method declared in the trait:

```fe
trait Shape {
    fn area(self) -> u256
    fn perimeter(self) -> u256
}

struct Rectangle {
    width: u256,
    height: u256,
}

impl Shape for Rectangle {
    fn area(self) -> u256 {
        self.width * self.height
    }

    fn perimeter(self) -> u256 {
        2 * (self.width + self.height)
    }
}
```

Missing any method causes a compile error:

```fe ignore
impl Shape for Rectangle {
    fn area(self) -> u256 {
        self.width * self.height
    }
    // Error: missing implementation for `perimeter`
}
```

## Multiple Types, Same Trait

Different types can implement the same trait:

```fe
trait Area {
    fn area(self) -> u256
}

struct Rectangle {
    width: u256,
    height: u256,
}

struct Circle {
    radius: u256,
}

struct Triangle {
    base: u256,
    height: u256,
}

impl Area for Rectangle {
    fn area(self) -> u256 {
        self.width * self.height
    }
}

impl Area for Circle {
    fn area(self) -> u256 {
        // Simplified: using 3 * radius^2 as approximation
        3 * self.radius * self.radius
    }
}

impl Area for Triangle {
    fn area(self) -> u256 {
        self.base * self.height / 2
    }
}
```

## Multiple Traits, Same Type

A type can implement multiple traits:

```fe
//<hide>
struct String {}
//</hide>

trait Printable {
    fn to_string(self) -> String
}

trait Hashable {
    fn hash(self) -> u256
}

trait Comparable {
    fn equals(self, other: Self) -> bool
}

struct Token {
    id: u256,
    value: u256,
}

impl Printable for Token {
    fn to_string(self) -> String {
        String {}
    }
}

impl Hashable for Token {
    fn hash(self) -> u256 {
        self.id
    }
}

impl Comparable for Token {
    fn equals(self, other: Self) -> bool {
        self.id == other.id && self.value == other.value
    }
}
```

## Implementing Mutable Methods

For methods with `mut self`, the implementation can modify the struct:

```fe
trait Counter {
    fn count(self) -> u256
    fn increment(mut self)
    fn reset(mut self)
}

struct SimpleCounter {
    value: u256,
}

impl Counter for SimpleCounter {
    fn count(self) -> u256 {
        self.value
    }

    fn increment(mut self) {
        self.value += 1
    }

    fn reset(mut self) {
        self.value = 0
    }
}
```

## Using Self in Implementations

`Self` in the implementation refers to the concrete type:

```fe
trait Duplicatable {
    fn duplicate(self) -> Self
}

struct Point {
    x: u256,
    y: u256,
}

impl Duplicatable for Point {
    fn duplicate(self) -> Self {  // Self is Point here
        Point {
            x: self.x,
            y: self.y,
        }
    }
}
```

## Trait Methods vs Regular Methods

A type can have both trait methods and regular methods:

```fe
//<hide>
struct String {}
//</hide>

struct Wallet {
    balance: u256,
}

// Regular impl block with methods
impl Wallet {
    fn new(initial: u256) -> Wallet {
        Wallet { balance: initial }
    }

    fn deposit(mut self, amount: u256) -> Self {
        self.balance += amount
        self
    }
}

// Trait implementation
trait Printable {
    fn to_string(self) -> String
}

impl Printable for Wallet {
    fn to_string(self) -> String {
        String {}
    }
}
```

Both are available on the type:

```fe
//<hide>
struct String {}


struct Wallet {
    balance: u256,
}

impl Wallet {
    fn new(initial: u256) -> Wallet {
        Wallet { balance: initial }
    }

    fn deposit(mut self, amount: u256) -> Self {
        self.balance += amount
        self
    }
}

trait Printable {
    fn to_string(self) -> String
}

impl Printable for Wallet {
    fn to_string(self) -> String {
        String {}
    }
}

fn use_wallet() {
//</hide>
let wallet = Wallet::new(100)  // Associated function
let wallet = wallet.deposit(50)                  // Regular method
let s = wallet.to_string()          // Trait method
//<hide>
    let _ = (wallet, s)
}
```

## Implementation Visibility

Trait implementations follow the trait's visibility:

```fe
// Public trait
pub trait Serializable {
    fn serialize(self) -> u256
}

// Implementation is also effectively public
struct MyType {
    value: u256,
}

impl Serializable for MyType {
    fn serialize(self) -> u256 {
        self.value
    }
}
```

## Summary

| Syntax | Description |
|--------|-------------|
| `impl Trait for Type { }` | Implement trait for type |
| All methods required | Must implement every trait method |
| `Self` | Refers to the implementing type |
| Multiple traits | A type can implement many traits |
| Multiple types | Many types can implement same trait |
