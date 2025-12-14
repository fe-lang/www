---
title: Helper Structs
description: Utility structs for organizing logic
---

Helper structs are regular (non-storage) structs used to organize data and logic. They're useful for grouping related values, returning multiple values, and creating reusable components.

## Data Grouping

Group related values into a struct:

```fe ignore
struct TransferParams {
    from: u256,
    to: u256,
    amount: u256,
}

fn execute_transfer(params: TransferParams) uses mut TokenStorage -> bool {
    // Use params.from, params.to, params.amount
    transfer(params.from, params.to, params.amount)
}
```

This is clearer than passing many individual parameters.

## Return Types

Use structs to return multiple values:

```fe ignore
struct BalanceInfo {
    balance: u256,
    frozen: bool,
    last_updated: u256,
}

fn get_account_info(account: u256) uses TokenStorage -> BalanceInfo {
    BalanceInfo {
        balance: TokenStorage.balances.get(account),
        frozen: TokenStorage.frozen.get(account),
        last_updated: TokenStorage.timestamps.get(account),
    }
}
```

## Configuration Structs

Encapsulate configuration:

```fe ignore
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

```fe ignore
struct ValidatedAmount {
    value: u256,
}

impl ValidatedAmount {
    fn new(value: u256, max: u256) -> ValidatedAmount {
        if value > max {
            revert
        }
        ValidatedAmount { value }
    }

    fn get(self) -> u256 {
        self.value
    }
}

fn safe_transfer(to: u256, amount: ValidatedAmount) uses mut TokenStorage -> bool {
    // amount is guaranteed to be valid
    transfer(caller(), to, amount.get())
}
```

## Result Types

Create structs for operation results:

```fe ignore
struct TransferResult {
    success: bool,
    new_sender_balance: u256,
    new_recipient_balance: u256,
}

fn transfer_with_result(
    from: u256,
    to: u256,
    amount: u256
) uses mut TokenStorage -> TransferResult {
    let from_bal = TokenStorage.balances.get(from)

    if from_bal < amount {
        return TransferResult {
            success: false,
            new_sender_balance: from_bal,
            new_recipient_balance: TokenStorage.balances.get(to),
        }
    }

    let new_from = from_bal - amount
    let new_to = TokenStorage.balances.get(to) + amount

    TokenStorage.balances.set(from, new_from)
    TokenStorage.balances.set(to, new_to)

    TransferResult {
        success: true,
        new_sender_balance: new_from,
        new_recipient_balance: new_to,
    }
}
```

## Computation Helpers

Structs with methods for calculations:

```fe ignore
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

// Usage
let fee_rate = Percentage::from_percent(3)  // 3%
let fee = fee_rate.apply(1000)  // 30
```

## Builder Pattern

Use helper structs for complex construction:

```fe ignore
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

let config = TokenConfig::new()
    .with_decimals(6)
    .with_supply(1000000)
    .mintable()
```

## Organizing Related Functions

Group related operations using impl blocks:

```fe ignore
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

// Usage
let clamped = MathUtils::clamp(value, 10, 100)
```

## Combining with Effects

Helper structs can work alongside effects:

```fe ignore
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

    fn execute(self) uses mut TokenStorage -> bool {
        transfer(self.from, self.to, self.amount)
    }

    fn validate(self) uses TokenStorage -> bool {
        let balance = TokenStorage.balances.get(self.from)
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
