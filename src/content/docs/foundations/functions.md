---
title: Functions
description: Function declaration, labeled parameters, return types, and visibility
---

Functions are the building blocks of Fe programs. They encapsulate reusable logic and provide structure to your code.

## Function Declaration

Declare a function using the `fn` keyword:

```fe
fn greet() {
    // function body
}
```

A function with parameters and a return type:

```fe
fn add(a: u256, b: u256) -> u256 {
    a + b
}
```

## Parameters

### Basic Parameters

Parameters are declared with a name and type:

```fe
fn process(value: u256, flag: bool) {
    // use value and flag
    //<hide>
    let _ = (value, flag)
    //</hide>
}
```

### Labeled Parameters

Fe supports **labeled parameters** for improved call-site clarity. A label is the name used when calling the function, while the parameter name is used inside the function body:

```fe
fn transfer(from sender: u256, to recipient: u256, amount: u256) {
    // Inside the function, use: sender, recipient, amount
    //<hide>
    let _ = (sender, recipient, amount)
    //</hide>
}

//<hide>
fn example_transfer() {
    let alice: u256 = 1
    let bob: u256 = 2
//</hide>
// At the call site, use the labels:
transfer(from: alice, to: bob, amount: 100)
//<hide>
}
```

This makes function calls self-documenting and reduces errors when functions have multiple parameters of the same type.

### Unlabeled Parameters with `_`

Use `_` as the label when you don't want to require a label at the call site:

```fe
fn square(_ x: u256) -> u256 {
    x * x
}

//<hide>
fn example_square() {
//</hide>
// Call without a label:
let result = square(5)
//<hide>
    let _ = result
}
```

You can mix labeled and unlabeled parameters:

```fe
//<hide>
struct Point {
    x: u256,
    y: u256,
    named: bool,
}
//</hide>

fn create_point(_ x: u256, _ y: u256, named: bool) -> Point {
    // x and y are positional, named requires a label
    //<hide>
    Point { x, y, named }
    //</hide>
}

//<hide>
fn example_create_point() {
//</hide>
// Call:
create_point(10, 20, named: true)
//<hide>
    let _ = create_point(10, 20, named: true)
}
```

### Mutable Parameters

Use `mut` to declare a parameter that can be modified within the function:

```fe
fn increment(mut value: u256) -> u256 {
    value = value + 1
    value
}
```

Note that this creates a mutable local copy; it doesn't modify the caller's variable.

## The `self` Receiver

Functions that operate on a type instance use `self` as their first parameter, making them **methods**:

```fe
struct Counter {
    value: u256,
}

impl Counter {
    // Method with immutable self - can read but not modify
    fn get(self) -> u256 {
        self.value
    }

    // Method with mutable self - can read and modify
    fn increment(mut self) -> Self {
        self.value = self.value + 1
        self
    }
}
```

Methods are called using dot notation:

```fe
//<hide>
struct Counter {
    value: u256,
}

impl Counter {
    fn get(self) -> u256 {
        self.value
    }

    fn increment(mut self) -> Self {
        self.value = self.value + 1
        self
    }
}

fn use_counter() {
//</hide>
let mut counter = Counter { value: 0 }
counter = counter.increment()
let current = counter.get()
//<hide>
    let _ = current
}
//</hide>
```

### Self Variations

| Receiver | Description |
|----------|-------------|
| `self` | Immutable access to the instance |
| `mut self` | Mutable access to the instance |

## Return Types

Specify a return type with `->` after the parameters:

```fe
fn calculate(x: u256) -> u256 {
    x * 2
}
```

### Implicit Returns

The last expression in a function is implicitly returned (without a semicolon):

```fe
fn double(x: u256) -> u256 {
    x * 2  // implicitly returned
}
```

### Explicit Returns

Use `return` for early returns or explicit clarity:

```fe
fn abs(x: i256) -> i256 {
    if x < 0 {
        return -x
    }
    x
}
```

### Functions Without Return Values

Functions without `->` return the unit type (similar to `void` in other languages):

```fe
fn log_value(value: u256) {
    // no return value
    //<hide>
    let _ = value
    //</hide>
}
```

## Visibility

Functions are **private by default**, accessible only within their module.

### Public Functions

Use `pub` to make a function accessible from other modules:

```fe
pub fn public_function() {
    // accessible from other modules
}

fn private_function() {
    // only accessible within this module
}
```

### Functions and Contracts

In Fe, contracts cannot contain regular functions. Contracts only have:
- **Storage fields** for state
- An **`init` block** for initialization
- **`recv` blocks** for handling incoming messages

Functions are defined separately, either as free-floating functions or as methods on structs. Code inside `recv` blocks can call these external functions:

```fe
// Free-floating helper function
fn calculate_fee(amount: u256) -> u256 {
    amount / 100
}

// Helper struct with methods
struct TokenLogic {}

impl TokenLogic {
    pub fn validate_transfer(self, amount: u256) -> bool {
        amount > 0
    }
}

//<hide>
pub struct Storage { pub balance: u256 }

msg TransferMsg {
    #[selector = 0xa9059cbb]
    Transfer { to: u256, amount: u256 } -> bool,
}
//</hide>
contract MyToken {
    mut store: Storage,

    recv TransferMsg {
        Transfer { to, amount } -> bool uses (mut store) {
            // Call free-floating function
            let fee = calculate_fee(amount)

            // Recv block handles the message
            //<hide>
            let _ = (to, fee, store)
            //</hide>
            true
        }
    }
}
```

This separation keeps contracts focused on state and message handling, while logic lives in reusable functions and structs.

## Generic Functions

Functions can be generic over types using angle brackets:

```fe
fn identity<T>(value: T) -> T {
    value
}
```

With trait bounds:

```fe
//<hide>
trait Display {}
//</hide>

fn print_value<T: Display>(value: T) {
    // T must implement Display
    //<hide>
    let _ = value
    //</hide>
}
```

For comprehensive coverage of generics and trait bounds, see the [Traits & Generics](/traits/definition/) section.

## Functions with Effects

Fe uses an effect system to track side effects. Functions declare their effects with the `uses` clause:

```fe
//<hide>
use _boilerplate::Storage
//</hide>
fn read_storage() uses (storage: Storage) {
    // can read from storage
    //<hide>
    let _ = storage
    //</hide>
}

fn write_storage() uses (mut storage: Storage) {
    // can read and write to storage
    //<hide>
    let _ = storage
    //</hide>
}
```

For comprehensive coverage of effects, see the [Effects](/effects/what-are-effects/) section.

## Summary

| Feature | Syntax | Example |
|---------|--------|---------|
| Basic function | `fn name() { }` | `fn greet() { }` |
| With parameters | `fn name(a: T) { }` | `fn add(x: u256) { }` |
| With return type | `fn name() -> T { }` | `fn get() -> u256 { }` |
| Labeled parameter | `label name: T` | `from sender: u256` |
| Unlabeled parameter | `_ name: T` | `_ x: u256` |
| Mutable parameter | `mut name: T` | `mut count: u256` |
| Method (immutable) | `fn name(self)` | `fn get(self) -> u256` |
| Method (mutable) | `fn name(mut self)` | `fn set(mut self, v: u256)` |
| Public function | `pub fn name()` | `pub fn api() { }` |
| Generic function | `fn name<T>()` | `fn id<T>(x: T) -> T` |
| With effects | `fn name() uses E` | `fn read() uses Storage` |
