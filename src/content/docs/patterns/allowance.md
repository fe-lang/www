---
title: Allowance & Approval
description: Delegated spending with approve and transferFrom
---

An allowance grants a spender permission to debit an owner's tokens up to a limit. Store it under `(owner, spender)`, never under the recipient: the spender and recipient can be different addresses.

## Approval and Spending

`approve(spender, amount)` replaces the caller's allowance for that spender and emits `Approval`. It does not move tokens. `transferFrom(from, to, amount)` uses the transaction caller as spender, consumes that allowance, and transfers from the owner's balance.

The arithmetic can be isolated and tested:

```fe
fn remaining_allowance(current: u256, amount: u256) -> u256 {
    assert!(current >= amount, "insufficient allowance")
    current - amount
}

#[test]
fn spends_allowance() {
    assert!(remaining_allowance(current: 100, amount: 40) == 60)
    assert!(remaining_allowance(current: 100, amount: 100) == 0)
    assert!(remaining_allowance(current: 0, amount: 0) == 0)
}

#[test(should_revert)]
fn rejects_overspending() {
    let _ = remaining_allowance(current: 10, amount: 11)
}
```

[CoolCoin's `spend_allowance` helper](/examples/erc20/) reads the map, applies this check, and writes the reduced allowance. If the subsequent transfer reverts, the allowance update rolls back too. CoolCoin always decreases allowances; an unlimited-allowance sentinel is an optional policy, not an ERC20 requirement.

## Changing an Existing Approval

Replacing a nonzero approval with another nonzero value can race with spending: a spender may consume the old allowance before the replacement is mined, then spend the new allowance too. Clients commonly first set the allowance to zero and wait for confirmation before setting the replacement. An application should account for spending already confirmed during that process.

Increase/decrease helpers can express a change relative to the current allowance. They still need overflow/underflow checks and do not revoke spending that already happened. Keep the policy consistent between `transferFrom` and any delegated burn operation.
