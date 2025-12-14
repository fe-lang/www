---
title: Associated Functions
description: Static functions on types
---

Associated functions are functions defined in an impl block that don't take `self`. They're called on the type itself, not on an instance—similar to static methods in other languages.

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
let p = Point::origin()  // Creates Point { x: 0, y: 0 }
```

Compare with method calls that use `.`:

```fe
let p = Point::origin()           // Associated function: Type::function()
let d = p.distance_from_origin()  // Method: instance.method()
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

let counter = Counter::new(100)
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

let c1 = Config::new()
let c2 = Config::with_threshold(50)
let c3 = Config::create(100, true, 0x123)
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

let rect = Rectangle::new(10, 20)
let sq = Rectangle::square(15)
let unit = Rectangle::unit()
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

let p = Percentage::from_percent(50)  // 50%
let valid = Percentage::is_valid_basis_points(5000)  // true
let result = p.apply(1000)  // 500
```

## Combining with Methods

A typical struct has both associated functions and methods:

```fe
struct TokenAmount {
    value: u256,
    decimals: u8,
}

impl TokenAmount {
    // Associated functions - constructors and utilities
    fn new(value: u256, decimals: u8) -> TokenAmount {
        TokenAmount { value, decimals }
    }

    fn zero(decimals: u8) -> TokenAmount {
        TokenAmount { value: 0, decimals }
    }

    fn max_decimals() -> u8 {
        18
    }

    // Methods - operate on instances
    fn is_zero(self) -> bool {
        self.value == 0
    }

    fn add(self, other: TokenAmount) -> TokenAmount {
        // Assumes same decimals
        TokenAmount {
            value: self.value + other.value,
            decimals: self.decimals,
        }
    }

    fn scale_to(self, new_decimals: u8) -> TokenAmount {
        // Scale value to new decimal places
        if new_decimals > self.decimals {
            let factor = 10 ** (new_decimals - self.decimals)
            TokenAmount {
                value: self.value * factor,
                decimals: new_decimals,
            }
        } else {
            let factor = 10 ** (self.decimals - new_decimals)
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
