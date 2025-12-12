---
title: Impl Blocks
description: Adding methods to structs
---

Impl blocks let you define methods on structs. Methods are functions associated with a type that can access the struct's data through `self`.

## Basic Syntax

Define methods in an `impl` block:

```fe
struct Counter {
    value: u256,
}

impl Counter {
    fn get(self) -> u256 {
        self.value
    }

    fn increment(mut self) {
        self.value += 1
    }
}
```

## The self Parameter

Methods take `self` as their first parameter, giving access to the struct instance:

```fe
struct Point {
    x: u256,
    y: u256,
}

impl Point {
    fn magnitude_squared(self) -> u256 {
        self.x * self.x + self.y * self.y
    }
}

//<hide>
fn example() {
//</hide>
let p = Point { x: 3, y: 4 }
let mag_sq = p.magnitude_squared()  // 25
//<hide>
let _ = mag_sq
}
//</hide>
```

### self vs mut self

Use `self` for read-only access, `mut self` when you need to modify:

```fe
//<hide>
struct Counter {
    value: u256,
}

//</hide>
impl Counter {
    // Read-only: uses self
    fn get(self) -> u256 {
        self.value
    }

    // Modifying: uses mut self
    fn set(mut self, new_value: u256) {
        self.value = new_value
    }

    // Modifying: uses mut self
    fn increment(mut self) {
        self.value += 1
    }
}
```

The compiler enforces this. You can't modify through a non-mut `self`:

```fe ignore
impl Counter {
    fn broken(self) {
        self.value = 10  // Error: cannot mutate through immutable self
    }
}
```

## Calling Methods

Call methods with dot notation:

```fe
//<hide>
struct Counter {
    value: u256,
}

impl Counter {
    fn get(self) -> u256 {
        self.value
    }

    fn set(mut self, new_value: u256) {
        self.value = new_value
    }

    fn increment(mut self) {
        self.value += 1
    }
}

fn example() {
//</hide>
let mut counter = Counter { value: 0 }

let v = counter.get()      // 0
counter.increment()
let v2 = counter.get()     // 1
counter.set(100)
let v3 = counter.get()     // 100
//<hide>
let _ = (v, v2, v3)
}
//</hide>
```

## Method Chaining

Methods returning `self` enable chaining:

```fe
struct Builder {
    width: u256,
    height: u256,
    depth: u256,
}

impl Builder {
    fn with_width(mut self, w: u256) -> Builder {
        self.width = w
        self
    }

    fn with_height(mut self, h: u256) -> Builder {
        self.height = h
        self
    }

    fn with_depth(mut self, d: u256) -> Builder {
        self.depth = d
        self
    }
}

//<hide>
fn example() {
//</hide>
let b = Builder { width: 0, height: 0, depth: 0 }
    .with_width(10)
    .with_height(20)
    .with_depth(30)
//<hide>
let _ = b
}
//</hide>
```

## Multiple Impl Blocks

You can split methods across multiple impl blocks:

```fe
struct Token {
    balance: u256,
    frozen: bool,
}

// Core functionality
impl Token {
    fn get_balance(self) -> u256 {
        self.balance
    }

    fn set_balance(mut self, amount: u256) {
        self.balance = amount
    }
}

// Freeze functionality
impl Token {
    fn is_frozen(self) -> bool {
        self.frozen
    }

    fn freeze(mut self) {
        self.frozen = true
    }

    fn unfreeze(mut self) {
        self.frozen = false
    }
}
```

## Methods with Additional Parameters

Methods can take parameters beyond `self`:

```fe
struct Wallet {
    balance: u256,
}

impl Wallet {
    fn deposit(mut self, amount: u256) {
        self.balance += amount
    }

    fn withdraw(mut self, amount: u256) -> bool {
        if self.balance < amount {
            return false
        }
        self.balance -= amount
        true
    }

    fn transfer_to(mut self, other: Wallet, amount: u256) -> bool {
        if self.balance < amount {
            return false
        }
        self.balance -= amount
        // Note: other would need to be mut to receive
        //<hide>
        let _ = other
        //</hide>
        true
    }
}
```

## Visibility

Methods can be public or private:

```fe
//<hide>
struct Counter {
    value: u256,
}

//</hide>
impl Counter {
    // Public method
    pub fn get(self) -> u256 {
        self.value
    }

    // Private helper
    fn validate(self) -> bool {
        self.value < 1000000
    }
}
```

## Important: Structs vs Contracts

Only structs can have impl blocks. Contracts cannot:

```fe ignore
// ✓ This works - struct with impl
struct Helper {
    data: u256,
}

impl Helper {
    fn process(self) -> u256 {
        self.data * 2
    }
}

// ✗ This does NOT work - contracts cannot have impl blocks
contract Token {
    store: TokenStorage,
}

impl Token {  // Error: cannot implement methods on contracts
    fn get_balance(self) -> u256 { ... }
}
```

For contracts, use standalone functions with effects instead:

```fe
//<hide>
use _boilerplate::Map
pub struct TokenStorage { pub balances: Map<u256, u256> }
//</hide>
fn get_balance(account: u256) -> u256 uses (store: TokenStorage) {
    store.balances.get(account)
}
```

## Summary

| Syntax | Description |
|--------|-------------|
| `impl Type { }` | Define methods for a type |
| `fn method(self)` | Read-only method |
| `fn method(mut self)` | Mutating method |
| `instance.method()` | Call a method |
| `pub fn` | Public method |
