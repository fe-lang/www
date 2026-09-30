---
title: Reverting
description: Reverting execution and returning structured errors
---

A revert ends the current EVM call unsuccessfully. Its state changes and logs are discarded. Gas already spent is not refunded. A caller using a low-level call may inspect failure and continue; typed calls normally propagate the callee's revert.

## Custom Errors

Use `#[error]` on a struct and pass a value to `revert_error`. The compiler generates the selector and ABI encoding from the error name and field types:

```fe
#[error]
struct InsufficientBalance {
    available: u256,
    required: u256,
}

fn checked_withdraw(balance: u256, amount: u256) -> u256 {
    if amount > balance {
        revert_error(InsufficientBalance { available: balance, required: amount })
    }
    balance - amount
}

#[test]
fn valid_withdrawal() {
    assert!(checked_withdraw(balance: 10, amount: 4) == 6)
}

#[test(should_revert)]
fn insufficient_balance() {
    let _ = checked_withdraw(balance: 10, amount: 11)
}
```

This encodes the Solidity-compatible `InsufficientBalance(uint256,uint256)` selector followed by the two arguments. `revert_error` is in the standard prelude.

## Raw ABI Payloads

`revert(value)` also terminates execution, but ABI-encodes the value **without a custom-error selector**:

```fe
fn reject() -> ! {
    let code: u256 = 42
    revert(code)
}

#[test(should_revert)]
fn rejects_with_payload() {
    reject()
}
```

The `!` return type means the function never returns normally. In particular, `revert("reason")` is not the same wire format as Solidity's `Error(string)`. Use `assert!(condition, "reason")` for a string-bearing assertion or `revert_error` for a typed error.

## Place Checks Before Effects

Check permissions, balances, and bounds before writing state. Before an external call, bring your own state into a consistent condition: the recipient may call back into your contract. A revert provides rollback, but does not replace access control or reentrancy protection.
