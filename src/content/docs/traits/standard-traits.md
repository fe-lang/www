---
title: Standard Traits
description: Fe's built-in traits
---

Fe provides several built-in traits that enable core language functionality. Understanding these helps you work effectively with Fe's type system.

## MsgVariant

The `MsgVariant` trait is automatically implemented for message variants. It provides the selector and return type information needed for ABI compatibility.

The standard trait is `core::message::MsgVariant<A: Abi>`. Its `SELECTOR` has type `A::Selector`, and its associated `Return` type supports ABI decoding. For Solidity messages, the ABI provider is `std::abi::Sol`.

When you define a message:

```fe
//<hide>
use std::abi::sol
//</hide>
msg TokenMsg {
    #[selector = sol("transfer(address,uint256)")]
    Transfer { to: Address, amount: u256 } -> bool,
}
```

Access the generated selector as `TokenMsg::Transfer::SELECTOR`; its value is `0xa9059cbb` for this signature.

This trait enables:
- Type-safe message routing
- Compile-time selector verification
- Generic code over message types

## Numeric Traits

Fe provides traits for numeric operations:

### Arithmetic

Operator traits live in `core::ops`. They allow a right-hand operand type and an associated output type. Use bounds on the real traits rather than redeclaring a trait named `Add`:

```fe
use core::ops::Add

fn add_values<T: Add<T, Output = T>>(a: own T, b: own T) -> T {
    a + b
}
```

The corresponding traits include `Sub`, `Mul`, and `Div`. Primitive numeric types implement them with checked arithmetic.

### Comparison

`core::ops::Eq` provides equality and inequality; `Ord` provides ordering comparisons. Fe supports equality for fixed-size arrays and tuples of up to six elements when the element types implement `Eq`.

## Common Trait Patterns

`Default` and `Clone` are supplied by the prelude. Implement those traits directly:

### Default

Provides a default value:

```fe
struct Counter {
    value: u256,
}

impl Default for Counter {
    fn default() -> Self {
        Counter { value: 0 }
    }
}

//<hide>
fn example() {
//</hide>
let c = Counter::default()
//<hide>
let _ = c
}
//</hide>
```

### Clone

Creates a copy of a value:

```fe
struct Point {
    x: u256,
    y: u256,
}

impl Clone for Point {
    fn clone(self) -> Self {
        Point { x: self.x, y: self.y }
    }
}
```

### Explicit Conversions

`core::convert::Into` is not available. Use the conversion APIs provided by the type, such as integer casts and checked numeric conversion methods, or define an associated constructor for your own type:

```fe
struct Percentage {
    basis_points: u256,
}

impl Percentage {
    fn from_basis_points(value: u256) -> Self {
        assert!(value <= 10000, "percentage exceeds 100%")
        Percentage { basis_points: value }
    }
}
```

## Defining Your Own Standard Traits

For your projects, define common traits that types should implement:

### Identifiable

```fe
trait Identifiable {
    fn id(self) -> u256
}

struct User {
    user_id: u256,
    name: String<31>,
}

impl Identifiable for User {
    fn id(self) -> u256 {
        self.user_id
    }
}

struct Token {
    token_id: u256,
    value: u256,
}

impl Identifiable for Token {
    fn id(self) -> u256 {
        self.token_id
    }
}

// Generic function works with any Identifiable
fn get_id<T: Identifiable>(item: T) -> u256 {
    item.id()
}
```

### Validatable

```fe
trait Validatable {
    fn is_valid(self) -> bool
}

struct Transfer {
    from: Address,
    to: Address,
    amount: u256,
}

impl Validatable for Transfer {
    fn is_valid(self) -> bool {
        self.from != Address::zero() && self.to != Address::zero() && self.amount > 0
    }
}

fn process<T: Validatable>(item: T) -> bool {
    if !item.is_valid() {
        return false
    }
    // ... process valid item
    true
}
```

### Hashable

```fe
trait Hashable {
    fn hash(self) -> u256
}

struct Order {
    id: u256,
    price: u256,
    quantity: u256,
}

impl Hashable for Order {
    fn hash(self) -> u256 {
        // Simple hash combining fields
        self.id ^ self.price ^ self.quantity
    }
}
```

## Using Traits for Interfaces

Define trait "interfaces" for your contract patterns:

### ERC-Style Traits

```fe
trait ERC20 {
    fn total_supply(self) -> u256
    fn balance_of(self, account: Address) -> u256
    fn transfer(mut self, to: Address, amount: u256) -> bool
}

trait ERC721 {
    fn owner_of(self, token_id: u256) -> u256
    fn transfer_from(mut self, from: Address, to: Address, token_id: u256)
}

trait Ownable {
    fn owner(self) -> u256
    fn transfer_ownership(mut self, new_owner: Address)
}

trait Pausable {
    fn paused(self) -> bool
    fn pause(mut self)
    fn unpause(mut self)
}
```

## Trait Composition

Build complex behaviors from simple traits:

```fe
trait Readable {
    fn read(self) -> u256
}

trait Writable {
    fn write(mut self, value: u256)
}

// Require both for read-write access
fn update<T: Readable + Writable>(storage: mut T, delta: u256) {
    let current = storage.read()
    storage.write(value: current + delta)
}
```

## Summary

| Trait | Purpose |
|-------|---------|
| `MsgVariant` | Message variant metadata (selector, return type) |
| `Add`, `Sub`, `Mul`, `Div` | Arithmetic operations |
| `Eq`, `Ord` | Comparison operations |
| `Default` | Default value construction |
| `Clone` | Value duplication |

Standard traits provide the foundation for generic, reusable code. Define your own traits to create consistent interfaces across your codebase.
