---
title: Assertions
description: Checking conditions with assert!
---

Use `assert!(condition)` to stop execution when a condition is false. In a contract call, a revert rolls back state changes and logs made by that call, including its successful subcalls.

## Checking Preconditions

Assertions can validate inputs before changing state. An optional string explains the failure:

```fe
fn withdraw(balance: u256, amount: u256) -> u256 {
    assert!(amount > 0, "amount must be positive")
    assert!(amount <= balance, "insufficient balance")
    balance - amount
}

#[test]
fn withdrawal_succeeds() {
    assert!(withdraw(balance: 100, amount: 40) == 60)
}

#[test(should_revert, selector = 0x08c379a0)]
fn withdrawal_rejects_insufficient_balance() {
    let _ = withdraw(balance: 10, amount: 11)
}
```

The condition must be a `bool`. The message must be a string literal, not a `const` or other `String` value, and not a Rust-style formatting argument list. Both forms are available without an import.

The two forms revert with different payloads:

| Form | Revert payload |
|------|----------------|
| `assert!(condition)` | Solidity `Panic(uint256)` with code `0x01` |
| `assert!(condition, "message")` | Solidity `Error(string)` (selector `0x08c379a0`) with the message |

## Choosing an Error Form

Use a short assertion for an invariant or a simple precondition. When callers need structured failure information, define a [custom error](/errors/revert/) and use `revert_error`. For an operation whose failure the caller should handle locally, return [Result](/errors/option-result/).

Assertions are also the basis of [unit tests](/testing/unit-testing/). A bare `#[test(should_revert)]` accepts any revert. Add `selector = ...` to require a particular error selector, or `panic = ...` to require a particular `Panic` code; see [Checking the revert reason](/testing/unit-testing/#checking-the-revert-reason):

```fe
#[test(should_revert, panic = 0x01)]
fn bare_assert_panics() {
    let amount: u256 = 0
    assert!(amount > 0)
}

#[test(should_revert, selector = 0x08c379a0)]
fn message_assert_reverts_with_error_string() {
    let amount: u256 = 0
    assert!(amount > 0, "amount must be positive")
}
```

Neither form checks the message text or which assertion failed, so keep negative tests focused on one invalid input and give them otherwise valid setup.

## Explicit Panic Codes

`core::panic_code(code)` reverts on the EVM with the Solidity `Panic(uint256)` payload. The `core::panics::PANIC_*` constants provide standard codes; native targets trap instead. Bounds-checked `core::ptr` access reports `Panic(0x32)` for an invalid index.

```fe
#[test(should_revert)]
fn explicit_panic() {
    core::panic_code(0x32)
}
```
