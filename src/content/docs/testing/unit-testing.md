---
title: Unit Testing
description: Testing pure functions and struct methods
---

Fe has a built-in test framework. Mark any function with `#[test]` and run it with `fe test`.

## Your First Test

```fe
fn max(a: u256, b: u256) -> u256 {
    if a > b { a } else { b }
}

#[test]
fn test_max() {
    assert!(max(a: 3, b: 7) == 7)
    assert!(max(a: 10, b: 2) == 10)
    assert!(max(a: 5, b: 5) == 5)
}
```

Run it:

```bash
fe test my_file.fe
```

Output:

```
PASS  [0.0003s] test_max

test result: ok. 1 passed; 0 failed
```

## Testing Struct Methods

Test struct methods the same way — create an instance, call methods, assert results:

```fe
struct Point {
    x: u256,
    y: u256,
}

impl Point {
    fn distance_squared(self, other: Point) -> u256 {
        let dx = if self.x > other.x { self.x - other.x } else { other.x - self.x }
        let dy = if self.y > other.y { self.y - other.y } else { other.y - self.y }
        dx * dx + dy * dy
    }
}

#[test]
fn test_distance() {
    let a = Point { x: 0, y: 0 }
    let b = Point { x: 3, y: 4 }
    assert!(a.distance_squared(other: b) == 25)
}
```

## Testing Expected Reverts

Use `#[test(should_revert)]` to verify that code reverts when it should. The test passes if execution reverts, and fails if it succeeds:

```fe
#[test(should_revert)]
fn test_overflow_reverts() {
    let x: u8 = 255
    let _ = x + 1  // arithmetic overflow → revert
}

#[test(should_revert)]
fn test_division_by_zero_reverts() {
    let x: u256 = 1
    let _ = x / 0
}

#[test(should_revert)]
fn test_assert_false_reverts() {
    assert!(false)
}
```

This is useful for verifying that safety checks (overflow, access control, assertions) actually trigger.

### Checking the Revert Reason

A plain `should_revert` accepts any revert. To also check *why* the code reverted, add one of these arguments:

- `selector = 0x…`: the revert data must start with this 4-byte selector (for example a custom error's selector, or `0x08c379a0` for `Error(string)`).
- `panic = 0x…`: the revert must be a Solidity `Panic(uint256)` with this code, such as `0x01` (assertion), `0x11` (arithmetic overflow), or `0x12` (division by zero).

Both require `should_revert`, and a test cannot combine `selector` and `panic`.

`assert!(condition)` without a message reverts with `Panic(0x01)`. `assert!(condition, "message")` reverts with a Solidity `Error(string)`, whose selector is `0x08c379a0`:

```fe
#[error]
pub struct InsufficientBalance {
    pub balance: u256,
    pub required: u256,
}

fn withdraw(balance: u256, amount: u256) -> u256 {
    if amount > balance {
        revert_error(InsufficientBalance { balance, required: amount })
    }
    balance - amount
}

// Bare assert! reverts with Panic(0x01)
#[test(should_revert, panic = 0x01)]
fn test_bare_assert_panics() {
    assert!(false)
}

// assert! with a message reverts with Error(string)
#[test(should_revert, selector = 0x08c379a0)]
fn test_assert_message_is_error_string() {
    assert!(false, "not owner")
}

// Checked arithmetic overflow reverts with Panic(0x11)
#[test(should_revert, panic = 0x11)]
fn test_overflow_panics() {
    let x: u8 = 255
    let _ = x + 1
}

// Custom errors revert with their selector:
// bytes4(keccak256("InsufficientBalance(uint256,uint256)")) = 0xcf479181
#[test(should_revert, selector = 0xcf479181)]
fn test_withdraw_too_much() {
    let _ = withdraw(balance: 100, amount: 200)
}
```

See [Reverting](/errors/revert/#custom-errors) for defining custom errors with `#[error]` and reverting with `revert_error`.

## Assertions

`assert!(condition)` reverts the test if the condition is false. The condition is a `bool`; an optional second string argument describes the failure. Use comparison expressions:

```fe
//<hide>
fn add(a: u256, b: u256) -> u256 { a + b }
//</hide>

#[test]
fn test_assertions() {
    // Equality
    assert!(add(a: 2, b: 3) == 5)

    // Comparison
    let a: u256 = 10
    assert!(a > 5)
    let b: u256 = 3
    assert!(b <= 3)

    // Boolean logic
    assert!(true && true)
    assert!(!false)
}
```

## What to Test

Pure functions and struct methods are the easiest to test because they have no side effects:

- **Arithmetic helpers** — fee calculations, rounding, clamping
- **Data structure operations** — encoding, decoding, validation
- **Business logic** — access control checks, state transitions
- **Edge cases** — zero values, max values, boundary conditions

For testing contracts with storage and message handling, see [Integration Testing](/testing/integration/).
