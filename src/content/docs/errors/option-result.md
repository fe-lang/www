---
title: Option & Result
description: Handling optional and fallible operations
---

`Option<T>` and `Result<E, T>` are available from the prelude, along with `Some`, `None`, `Ok`, and `Err`. They represent ordinary values that can be matched and returned without reverting.

## Option: A Value May Be Absent

```fe
fn divide(numerator: u256, denominator: u256) -> Option<u256> {
    if denominator == 0 {
        None
    } else {
        Some(numerator / denominator)
    }
}

#[test]
fn optional_division() {
    let quotient = match divide(numerator: 12, denominator: 3) {
        Some(value) => value
        None => 0
    }
    assert!(quotient == 4)
    assert!(divide(numerator: 12, denominator: 0).is_none())
}
```

`is_some()` and `is_none()` inspect the variant. `unwrap_or(default: value)` supplies a fallback, while `unwrap()` reverts on `None`. Use `match` when absence needs its own logic.

## Result: Preserve the Reason for Failure

Fe puts the **error type first**: `Result<E, T>`, unlike Rust's `Result<T, E>`.

```fe
enum AmountError {
    Zero,
    AboveLimit,
}

fn validate(amount: u256, limit: u256) -> Result<AmountError, u256> {
    if amount == 0 {
        Err(AmountError::Zero)
    } else if amount > limit {
        Err(AmountError::AboveLimit)
    } else {
        Ok(amount)
    }
}

#[test]
fn result_handling() {
    let accepted = match validate(amount: 5, limit: 10) {
        Ok(value) => value
        Err(_) => 0
    }
    assert!(accepted == 5)
    assert!(validate(amount: 0, limit: 10).is_err())
    assert!(validate(amount: 11, limit: 10).is_err())
}
```

`Result::unwrap()` reverts on `Err`; for EVM code generation its error payload must support the required ABI encoding. Use `match` for an application enum that has no ABI implementation.

`Result` is marked `must_use`: handle the result rather than silently discarding a possible error. `is_ok()`, `is_err()`, `map`, `map_err`, and `and_then` support common transformations. `Option::ok_or(error)` converts absence into an error.

## Values Versus Reverts

Returning `Err` does not undo earlier writes. A helper should validate before changing state, or its caller must decide how to handle failure. To reject a contract call, match the result and use an [assertion](/errors/assertions/) or [custom error](/errors/revert/). Returning a result from an internal helper and reverting at the contract boundary keeps validation reusable.
