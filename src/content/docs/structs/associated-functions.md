---
title: Associated Functions
description: Static functions on types
---

Associated functions are functions defined in an impl block that don't take `self`. They're called on the type itself, not on an instance, similar to static methods in other languages.

## Basic Syntax

Define an associated function by omitting `self`:

```fe
struct Point {
    x: u256,
    y: u256,
}

impl Point {
    // Associated function - no self parameter
    fn origin() -> Point {
        Point { x: 0, y: 0 }
    }

    // Method - has self parameter
    fn distance_from_origin(self) -> u256 {
        self.x + self.y  // Simplified
    }
}
```

## Calling Associated Functions

Use `::` syntax to call associated functions on the type:

```fe
//<hide>
struct Point {
    x: u256,
    y: u256,
}

impl Point {
    fn origin() -> Point {
        Point { x: 0, y: 0 }
    }

    fn distance_from_origin(self) -> u256 {
        self.x + self.y
    }
}

fn example() {
//</hide>
let p = Point::origin()  // Creates Point { x: 0, y: 0 }
//<hide>
let _ = p
}
//</hide>
```

Compare with method calls that use `.`:

```fe
//<hide>
struct Point {
    x: u256,
    y: u256,
}

impl Point {
    fn origin() -> Point {
        Point { x: 0, y: 0 }
    }

    fn distance_from_origin(self) -> u256 {
        self.x + self.y
    }
}

fn example() {
//</hide>
let p = Point::origin()           // Associated function: Type::function()
let d = p.distance_from_origin()  // Method: instance.method()
//<hide>
let _ = d
}
//</hide>
```

## The new() Constructor Pattern

The most common associated function is `new()`, a constructor:

```fe
struct Counter {
    value: u256,
    max: u256,
}

impl Counter {
    fn new(max: u256) -> Counter {
        Counter { value: 0, max }
    }
}

//<hide>
fn example() {
//</hide>
let counter = Counter::new(100)
//<hide>
let _ = counter
}
//</hide>
```

### Constructor Variations

```fe
struct Config {
    threshold: u256,
    enabled: bool,
    owner: u256,
}

impl Config {
    // Default constructor
    fn new() -> Config {
        Config {
            threshold: 0,
            enabled: false,
            owner: 0,
        }
    }

    // Parameterized constructor
    fn with_threshold(threshold: u256) -> Config {
        Config {
            threshold,
            enabled: true,
            owner: 0,
        }
    }

    // Full constructor
    fn create(threshold: u256, enabled: bool, owner: u256) -> Config {
        Config { threshold, enabled, owner }
    }
}

//<hide>
fn example() {
//</hide>
let c1 = Config::new()
let c2 = Config::with_threshold(50)
let c3 = Config::create(100, true, 0x123)
//<hide>
let _ = (c1, c2, c3)
}
//</hide>
```

## Factory Functions

Associated functions can create different configurations:

```fe
struct Rectangle {
    width: u256,
    height: u256,
}

impl Rectangle {
    fn new(width: u256, height: u256) -> Rectangle {
        Rectangle { width, height }
    }

    fn square(size: u256) -> Rectangle {
        Rectangle { width: size, height: size }
    }

    fn unit() -> Rectangle {
        Rectangle { width: 1, height: 1 }
    }
}

//<hide>
fn example() {
//</hide>
let rect = Rectangle::new(10, 20)
let sq = Rectangle::square(15)
let unit = Rectangle::unit()
//<hide>
let _ = (rect, sq, unit)
}
//</hide>
```

## Utility Functions

Associated functions can provide utilities related to the type:

```fe
struct Percentage {
    value: u256,  // Stored as basis points (0-10000)
}

impl Percentage {
    fn new(basis_points: u256) -> Percentage {
        Percentage { value: basis_points }
    }

    fn from_percent(percent: u256) -> Percentage {
        Percentage { value: percent * 100 }
    }

    // Utility: maximum valid percentage
    fn max() -> Percentage {
        Percentage { value: 10000 }
    }

    // Utility: check if a value is valid
    fn is_valid_basis_points(bp: u256) -> bool {
        bp <= 10000
    }

    // Method to apply percentage
    fn apply(self, amount: u256) -> u256 {
        amount * self.value / 10000
    }
}

//<hide>
fn example() {
//</hide>
let p = Percentage::from_percent(50)  // 50%
let valid = Percentage::is_valid_basis_points(5000)  // true
let result = p.apply(1000)  // 500
//<hide>
let _ = (valid, result)
}
//</hide>
```

## Combining with Methods

A typical struct has both associated functions and methods:

```fe
struct TokenAmount {
    pub value: u256,
    pub decimals: u256,
}

impl TokenAmount {
    // Associated functions - constructors and utilities
    pub fn new(value: u256, decimals: u256) -> TokenAmount {
        TokenAmount { value, decimals }
    }

    pub fn zero(decimals: u256) -> TokenAmount {
        TokenAmount { value: 0, decimals }
    }

    pub fn max_decimals() -> u256 {
        18
    }

    // Methods - operate on instances
    pub fn is_zero(self) -> bool {
        self.value == 0
    }

    pub fn add(self, other: TokenAmount) -> TokenAmount {
        // Assumes same decimals
        TokenAmount {
            value: self.value + other.value,
            decimals: self.decimals,
        }
    }

    pub fn scale_to(self, new_decimals: u256) -> TokenAmount {
        // Scale value to new decimal places
        if new_decimals > self.decimals {
            let factor: u256 = 10 ** (new_decimals - self.decimals)
            TokenAmount {
                value: self.value * factor,
                decimals: new_decimals,
            }
        } else {
            let factor: u256 = 10 ** (self.decimals - new_decimals)
            TokenAmount {
                value: self.value / factor,
                decimals: new_decimals,
            }
        }
    }
}
```

## Visibility

Associated functions follow the same visibility rules as methods:

```fe
//<hide>
struct Config {
    threshold: u256,
    enabled: bool,
    owner: u256,
}

//</hide>
impl Config {
    // Public - callable from outside
    pub fn new() -> Config {
        Config::default_config()
    }

    // Private - only callable within this module
    fn default_config() -> Config {
        Config {
            threshold: 100,
            enabled: true,
            owner: 0,
        }
    }
}
```

## Summary

| Syntax | Description |
|--------|-------------|
| `fn func() -> T` | Associated function (no self) |
| `Type::func()` | Call associated function |
| `fn new() -> Self` | Constructor pattern |
| `fn method(self)` | Method (has self) |
| `instance.method()` | Call method |
