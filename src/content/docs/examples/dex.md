---
title: Simple DEX Pricing
description: Constant-product quotes and slippage checks
---

A constant-product pool prices swaps from two reserves. This example implements and tests the pricing step for an exact-input swap with a 0.3% fee. It does not custody tokens or execute swaps; those require additional accounting and external-call handling.

## Pricing Function

For input reserve `x`, output reserve `y`, and input `a`, calculate:

`amount_out = (a × 997 × y) / (x × 1000 + a × 997)`

Integer division rounds down, leaving the fractional remainder in the pool. The input must be the amount actually credited to the pool.

```fe
use core::num::mul_div

fn quote(amount_in: u256, reserve_in: u256, reserve_out: u256, min_out: u256) -> u256 {
    assert!(amount_in > 0, "zero input")
    assert!(reserve_in > 0 && reserve_out > 0, "empty pool")
    let input_with_fee = amount_in * 997
    let amount_out = mul_div(input_with_fee, reserve_out, reserve_in * 1000 + input_with_fee)
    assert!(amount_out > 0, "output rounds to zero")
    assert!(amount_out >= min_out, "slippage limit")
    amount_out
}

#[test]
fn quotes_swap() {
    let amount = quote(amount_in: 100, reserve_in: 1000, reserve_out: 1000, min_out: 90)
    assert!(amount == 90)
    // The input fee remains in the pool, so the product does not decrease.
    assert!((1000 + 100) * (1000 - amount) >= 1000 * 1000)
}

#[test(should_revert)]
fn rejects_slippage() {
    let _ = quote(amount_in: 100, reserve_in: 1000, reserve_out: 1000, min_out: 91)
}

#[test(should_revert)]
fn rejects_empty_pool() {
    let _ = quote(amount_in: 100, reserve_in: 0, reserve_out: 1000, min_out: 1)
}
```

`mul_div` keeps the numerator's product at full precision. The fee scaling and denominator still use checked `u256` arithmetic, so a real pool must enforce reserve/input bounds. The rounding direction remains down.

## From a Quote to a Swap

A swap contract needs to validate a deadline and minimum output, collect the input token, measure the actual balance change, update reserves, transfer output, and emit a swap event. Use the [ERC20 call helpers](/patterns/tokens/) to accommodate empty return data, but still account for fee-on-transfer behavior and reentrancy.

Liquidity deposits and withdrawals also need ownership accounting, initial-liquidity rules, rounding policies, and invariant tests. The quote function is useful as an independently tested building block, not a deployable exchange.
