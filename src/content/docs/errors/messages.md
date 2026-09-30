---
title: Error Messages
description: Making contract failures understandable
---

Error data is part of the interface used by wallets, tests, and other contracts. Make it clear which condition failed and include the values needed to diagnose it.

## Short Assertion Messages

Prefer a specific condition such as `"amount exceeds limit"` over `"invalid"`. Keep terminology consistent with the message parameters:

```fe
fn validate_amount(amount: u256, limit: u256) {
    assert!(amount > 0, "amount must be positive")
    assert!(amount <= limit, "amount exceeds limit")
}

#[test]
fn accepts_limit() {
    validate_amount(amount: 10, limit: 10)
}

#[test(should_revert)]
fn rejects_above_limit() {
    validate_amount(amount: 11, limit: 10)
}
```

## Structured Errors

Use custom errors when the caller needs machine-readable details:

```fe
#[error]
struct Unauthorized {
    caller: Address,
}

fn require_owner(owner: Address) uses (ctx: Ctx) {
    let caller = ctx.caller()
    if caller != owner {
        revert_error(Unauthorized { caller })
    }
}
```

Changing an error's name or field types changes its selector. Treat that as an interface change for clients that decode it. See [Reverting](/errors/revert/) for the difference between `revert` and `revert_error`.

## Debugging Failures

Run a focused test with `fe test --filter test_name contract.fe`. Add `--call-trace` to see nested calls or `--trace-evm` to inspect execution. A bare `should_revert` test only checks that execution reverted; add `selector = ...` or `panic = ...` to check the kind of revert (see [Checking the revert reason](/testing/unit-testing/#checking-the-revert-reason)), and test successful neighboring cases too, so an unrelated setup failure cannot stand in for the intended validation.

A decoded error describes what the callee returned, not proof of who produced it: external contracts can fabricate the same selector and arguments.
