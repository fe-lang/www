---
title: Supply Management
description: Maintaining supply invariants when minting and burning
---

A fungible token's total supply must equal the sum of its balances. Transfers preserve that sum; minting and burning change it.

## Minting

A mint operation should check authorization and reject a zero recipient, increase total supply and the recipient's balance by the same amount, then emit `Transfer` from the zero address. If there is a cap, enforce it before changing balances.

This helper calculates the next total supply for a capped token:

```fe
fn supply_after_mint(supply: u256, amount: u256, cap: u256) -> u256 {
    assert!(supply <= cap, "supply exceeds cap")
    assert!(amount <= cap - supply, "mint exceeds cap")
    supply + amount
}

#[test]
fn mints_up_to_cap() {
    assert!(supply_after_mint(supply: 90, amount: 10, cap: 100) == 100)
}

#[test(should_revert)]
fn rejects_above_cap() {
    let _ = supply_after_mint(supply: 90, amount: 11, cap: 100)
}
```

Checking against `cap - supply` avoids overflowing an addition while testing the cap. Fe's ordinary integer arithmetic is also checked for overflow by default, but an ingot can opt out with `arithmetic = "unchecked"` in its `fe.toml` (under `[ingot]` or a `[profiles.<name>]` table). The explicit cap check keeps the rule independent of that setting.

## Burning

A burn operation checks that the source balance covers the amount, decreases both balance and total supply, and emits `Transfer` to the zero address. A caller may burn its own tokens; burning someone else's tokens needs an explicit policy, such as consuming an allowance.

## Keeping the Ledger Consistent

Put these updates in shared helpers so that constructors and message handlers follow the same rules. Do not expose a setter that changes total supply independently of balances. See [CoolCoin](/examples/erc20/) for storage-backed mint and burn helpers.

Test zero amounts, exact-balance burns, minting at the cap, rejected unauthorized mints, and delegated burns with insufficient allowance. After successful transfers, check that total supply is unchanged.
