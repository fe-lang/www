---
title: Effect Mocking
description: Providing test effects with the with expression
---

Because effects are explicit in Fe, testing functions that use effects is straightforward: provide the effect with a `with` expression.

## Mocking with `with`

Any function that declares `uses (effect: Type)` can be tested by providing a value of that type:

```fe
struct Config {
    max_transfer: u256,
    fee_rate: u256,
}

fn calculate_fee(amount: u256) -> u256 uses (config: Config) {
    amount * config.fee_rate / 10000
}

fn is_within_limit(amount: u256) -> bool uses (config: Config) {
    amount <= config.max_transfer
}

#[test]
fn test_fee_calculation() {
    let config = Config { max_transfer: 1000, fee_rate: 250 }

    let fee = with (config) {
        calculate_fee(400)
    }
    assert(fee == 10)  // 400 * 250 / 10000 = 10
}

#[test]
fn test_transfer_limit() {
    let config = Config { max_transfer: 1000, fee_rate: 250 }

    let ok = with (config) { is_within_limit(500) }
    assert(ok == true)

    let too_much = with (config) { is_within_limit(2000) }
    assert(too_much == false)
}
```

No mocking framework needed. The effect is just a struct — you create it with whatever values your test needs.

## Testing with Different Configurations

Test the same function under different conditions by providing different effect values:

```fe
//<hide>
struct Config {
    max_transfer: u256,
    fee_rate: u256,
}

fn calculate_fee(amount: u256) -> u256 uses (config: Config) {
    amount * config.fee_rate / 10000
}
//</hide>

#[test]
fn test_fee_rates() {
    // No fee
    let zero_fee = Config { max_transfer: 1000, fee_rate: 0 }
    let fee = with (zero_fee) { calculate_fee(1000) }
    assert(fee == 0)

    // 1% fee
    let low_fee = Config { max_transfer: 1000, fee_rate: 100 }
    let fee = with (low_fee) { calculate_fee(1000) }
    assert(fee == 10)

    // 5% fee
    let high_fee = Config { max_transfer: 1000, fee_rate: 500 }
    let fee = with (high_fee) { calculate_fee(1000) }
    assert(fee == 50)
}
```

## Testing Mutable Effects

For functions that modify effects, use `mut` bindings:

```fe
struct Counter {
    value: u256,
    limit: u256,
}

fn increment() -> bool uses (counter: mut Counter) {
    if counter.value >= counter.limit {
        return false
    }
    counter.value += 1
    true
}

#[test]
fn test_increment_with_limit() {
    let mut counter = Counter { value: 0, limit: 2 }

    let ok = with (mut counter) { increment() }
    assert(ok == true)
    assert(counter.value == 1)

    let ok = with (mut counter) { increment() }
    assert(ok == true)
    assert(counter.value == 2)

    // At limit — should return false
    let ok = with (mut counter) { increment() }
    assert(ok == false)
    assert(counter.value == 2)
}
```

## Why This Works

In languages without explicit effects, mocking requires frameworks, dependency injection containers, or monkey-patching. In Fe, effects are already explicit in the function signature — so "mocking" is just providing a value. There is no hidden state to intercept.
