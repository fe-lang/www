---
title: Helper Structs
description: Utility structs for organizing logic
---

Helper structs are regular (non-storage) structs used to organize data and logic. They're useful for grouping related values, returning multiple values, and creating reusable components.

## Data Grouping

Group related values into a struct:

```fe
//<hide>
pub struct TokenStorage {}
fn transfer(from: u256, to: u256, amount: u256) -> bool uses (mut store: TokenStorage) {
    let _ = (from, to, amount, store)
    true
}
//</hide>

struct TransferParams {
    from: u256,
    to: u256,
    amount: u256,
}

fn execute_transfer(params: TransferParams) -> bool uses (mut store: TokenStorage) {
    // Use params.from, params.to, params.amount
    transfer(params.from, params.to, params.amount)
}
```

This is clearer than passing many individual parameters.

## Return Types

Use structs to return multiple values:

```fe
//<hide>
use _boilerplate::Map
pub struct TokenStorage {
    pub balances: Map<u256, u256>,
    pub frozen: Map<u256, bool>,
    pub timestamps: Map<u256, u256>,
}
//</hide>

struct BalanceInfo {
    balance: u256,
    frozen: bool,
    last_updated: u256,
}

fn get_account_info(account: u256) -> BalanceInfo uses (store: TokenStorage) {
    BalanceInfo {
        balance: store.balances.get(account),
        frozen: store.frozen.get(account),
        last_updated: store.timestamps.get(account),
    }
}
```

## Configuration Structs

Encapsulate configuration:

```fe
struct FeeConfig {
    base_fee: u256,
    percentage_fee: u256,  // In basis points
    max_fee: u256,
}

impl FeeConfig {
    fn calculate(self, amount: u256) -> u256 {
        let percentage = amount * self.percentage_fee / 10000
        let total = self.base_fee + percentage

        if total > self.max_fee {
            self.max_fee
        } else {
            total
        }
    }
}

fn process_with_fee(amount: u256, config: FeeConfig) -> u256 {
    let fee = config.calculate(amount)
    amount - fee
}
```

## Validation Helpers

Create structs for validated data:

```fe
//<hide>
use core::revert
use _boilerplate::{Map, caller}

pub struct TokenStorage { pub balances: Map<u256, u256> }

fn transfer(from: u256, to: u256, amount: u256) -> bool uses (mut store: TokenStorage) {
    let _ = (from, to, amount, store)
    true
}
//</hide>
struct ValidatedAmount {
    pub value: u256,
}

impl ValidatedAmount {
    pub fn new(value: u256, max: u256) -> ValidatedAmount {
        if value > max {
            revert(0, 0)
        }
        ValidatedAmount { value }
    }

    pub fn get(self) -> u256 {
        self.value
    }
}

fn safe_transfer(to: u256, amount: ValidatedAmount) -> bool uses (mut store: TokenStorage) {
    // amount is guaranteed to be valid
    transfer(caller(), to, amount.get())
}
```

## Result Types

Create structs for operation results:

```fe
//<hide>
use _boilerplate::Map
pub struct TokenStorage { pub balances: Map<u256, u256> }
//</hide>

struct TransferResult {
    success: bool,
    new_sender_balance: u256,
    new_recipient_balance: u256,
}

fn transfer_with_result(
    from: u256,
    to: u256,
    amount: u256
) -> TransferResult uses (mut store: TokenStorage) {
    let from_bal = store.balances.get(from)

    if from_bal < amount {
        return TransferResult {
            success: false,
            new_sender_balance: from_bal,
            new_recipient_balance: store.balances.get(to),
        }
    }

    let new_from = from_bal - amount
    let new_to = store.balances.get(to) + amount

    store.balances.set(from, new_from)
    store.balances.set(to, new_to)

    TransferResult {
        success: true,
        new_sender_balance: new_from,
        new_recipient_balance: new_to,
    }
}
```

## Computation Helpers

Structs with methods for calculations:

```fe
struct Percentage {
    basis_points: u256,
}

impl Percentage {
    fn new(bp: u256) -> Percentage {
        Percentage { basis_points: bp }
    }

    fn from_percent(pct: u256) -> Percentage {
        Percentage { basis_points: pct * 100 }
    }

    fn apply(self, value: u256) -> u256 {
        value * self.basis_points / 10000
    }

    fn apply_inverse(self, value: u256) -> u256 {
        value * 10000 / (10000 - self.basis_points)
    }
}

//<hide>
fn example() {
//</hide>
// Usage
let fee_rate = Percentage::from_percent(3)  // 3%
let fee = fee_rate.apply(1000)  // 30
//<hide>
let _ = fee
}
//</hide>
```

## Builder Pattern

Use helper structs for complex construction:

```fe
struct TokenConfig {
    name_hash: u256,
    symbol_hash: u256,
    decimals: u8,
    initial_supply: u256,
    mintable: bool,
    burnable: bool,
}

impl TokenConfig {
    fn new() -> TokenConfig {
        TokenConfig {
            name_hash: 0,
            symbol_hash: 0,
            decimals: 18,
            initial_supply: 0,
            mintable: false,
            burnable: false,
        }
    }

    fn with_decimals(mut self, d: u8) -> TokenConfig {
        self.decimals = d
        self
    }

    fn with_supply(mut self, supply: u256) -> TokenConfig {
        self.initial_supply = supply
        self
    }

    fn mintable(mut self) -> TokenConfig {
        self.mintable = true
        self
    }

    fn burnable(mut self) -> TokenConfig {
        self.burnable = true
        self
    }
}

//<hide>
fn example() {
//</hide>
let config = TokenConfig::new()
    .with_decimals(6)
    .with_supply(1000000)
    .mintable()
//<hide>
let _ = config
}
//</hide>
```

## Organizing Related Functions

Group related operations using impl blocks:

```fe
struct MathUtils {
    // Empty struct - just a namespace for functions
}

impl MathUtils {
    fn min(a: u256, b: u256) -> u256 {
        if a < b { a } else { b }
    }

    fn max(a: u256, b: u256) -> u256 {
        if a > b { a } else { b }
    }

    fn clamp(value: u256, min_val: u256, max_val: u256) -> u256 {
        MathUtils::max(min_val, MathUtils::min(value, max_val))
    }

    fn abs_diff(a: u256, b: u256) -> u256 {
        if a > b { a - b } else { b - a }
    }
}

//<hide>
fn example() {
let value: u256 = 50
//</hide>
// Usage
let clamped = MathUtils::clamp(value, 10, 100)
//<hide>
let _ = clamped
}
//</hide>
```

## Combining with Effects

Helper structs can work alongside effects:

```fe
//<hide>
use _boilerplate::{Map, caller}
pub struct TokenStorage { pub balances: Map<u256, u256> }
fn transfer(from: u256, to: u256, amount: u256) -> bool uses (mut store: TokenStorage) {
    let _ = (from, to, amount, store)
    true
}
//</hide>

struct TransferRequest {
    from: u256,
    to: u256,
    amount: u256,
}

impl TransferRequest {
    fn new(to: u256, amount: u256) -> TransferRequest {
        TransferRequest {
            from: caller(),
            to,
            amount,
        }
    }

    fn execute(self) -> bool uses (mut store: TokenStorage) {
        transfer(self.from, self.to, self.amount)
    }

    fn validate(self) -> bool uses (store: TokenStorage) {
        let balance = store.balances.get(self.from)
        balance >= self.amount && self.to != 0
    }
}
```

## Summary

| Pattern | Use Case |
|---------|----------|
| Data grouping | Combine related parameters |
| Return types | Return multiple values |
| Configuration | Encapsulate settings |
| Validation | Ensure data correctness |
| Results | Rich operation outcomes |
| Computation | Reusable calculations |
| Builder | Complex object construction |
| Namespace | Group related functions |
