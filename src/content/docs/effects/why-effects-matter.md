---
title: Why Effects Matter
description: Security, testability, and reasoning benefits
---

Effects provide significant benefits for smart contract development. They make code safer, more testable, and easier to reason about.

## Security Benefits

### Explicit Capabilities

Every function declares exactly what it can access:

```fe ignore
fn transfer(from: u256, to: u256, amount: u256) uses mut Balances {
    // Can ONLY modify Balances
    // Cannot access Allowances, Config, or anything else
}
```

This makes security audits easier—you know a function's blast radius just by reading its signature.

### Principle of Least Privilege

Functions only get the capabilities they need:

```fe ignore
// This function can only read
fn get_balance(account: u256) uses Balances -> u256 {
    Balances.get(account)
}

// This function can read AND write
fn set_balance(account: u256, amount: u256) uses mut Balances {
    Balances.set(account, amount)
}
```

A bug in `get_balance` cannot corrupt state because it lacks mutation capability.

### No Hidden State Access

Unlike languages where any function might access global state, Fe functions can only access what they declare:

```fe ignore
// In Fe, this function signature guarantees
// it cannot access any external state
fn calculate_fee(amount: u256, rate: u256) -> u256 {
    amount * rate / 10000
}
```

If a function has no `uses` clause, it's a pure computation.

## Testability

### Easy Mocking

Effects make mocking straightforward:

```fe ignore
fn process_payment(amount: u256) uses (Config, mut Balances, mut Logger) {
    let fee = amount * Config.fee_rate / 10000

    Balances.credit(amount - fee)
    Logger.log_payment(amount, fee)
}

// In tests, provide mock effects:
fn test_payment() {
    let config = Config { fee_rate: 100 }  // 1% fee
    let mut balances = MockBalances::new()
    let mut logger = MockLogger::new()

    with (Config = config, Balances = balances, Logger = logger) {
        process_payment(1000)
    }

    // Assert on mock state
    assert(balances.credited == 990)
    assert(logger.entries.len() == 1)
}
```

### Isolated Unit Tests

Test functions in isolation by providing only the effects they need:

```fe ignore
fn validate_transfer(from: u256, amount: u256) uses Balances -> bool {
    Balances.get(from) >= amount
}

fn test_validate_transfer() {
    let balances = Balances {
        data: mock_map_with([(1, 100)])
    }

    with (Balances = balances) {
        assert(validate_transfer(1, 50) == true)
        assert(validate_transfer(1, 150) == false)
    }
}
```

### No Test Fixtures Needed

Pure functions (no effects) need no setup at all:

```fe ignore
fn calculate_shares(amount: u256, total: u256, supply: u256) -> u256 {
    if total == 0 {
        amount
    } else {
        amount * supply / total
    }
}

fn test_calculate_shares() {
    // No setup needed—just call the function
    assert(calculate_shares(100, 1000, 500) == 50)
    assert(calculate_shares(100, 0, 0) == 100)
}
```

## Reasoning About Code

### Function Signatures Tell the Story

```fe ignore
// Just by reading this signature, you know:
// - It needs caller context
// - It reads token store
// - It modifies balances
// - It writes to event log
fn transfer(to: u256, amount: u256)
    uses (Ctx, TokenStore, mut Balances, mut EventLog)
```

### Dependency Graphs

Effects create explicit dependency graphs:

```fe ignore
fn outer() uses (A, B) {
    inner1()  // Must provide effects A needs
    inner2()  // Must provide effects B needs
}

fn inner1() uses A { }
fn inner2() uses B { }
```

You can trace exactly how effects flow through your code.

### Refactoring Safety

When refactoring, the compiler catches missing effects:

```fe ignore
// Before: function was pure
fn calculate(x: u256) -> u256 {
    x * 2
}

// After: now needs Config
fn calculate(x: u256) uses Config -> u256 {
    x * Config.multiplier
}

// Compiler error at every call site that doesn't provide Config
```

## Compile-Time Guarantees

### Effect Checking Is Static

All effect checking happens at compile time:

- No runtime overhead for effect tracking
- Missing effects are caught before deployment
- Effect mismatches are compilation errors

### No Runtime Surprises

```fe ignore
fn risky_operation() uses mut CriticalState {
    // ...
}

fn caller() {
    risky_operation()
    // Compiler error: CriticalState not available
}
```

This error appears at compile time, not when the contract is deployed or called.

## Comparison

| Aspect | Without Effects | With Effects |
|--------|-----------------|--------------|
| Dependencies | Hidden in implementation | Visible in signature |
| Security audit | Must read all code | Check signatures first |
| Testing | Complex mocking | Simple effect injection |
| Refactoring | Runtime errors | Compile-time errors |
| Principle of least privilege | Manual discipline | Compiler enforced |

## Summary

Effects transform implicit dependencies into explicit, compiler-checked declarations:

1. **Security**: Limit what each function can access
2. **Testability**: Mock effects easily for isolated tests
3. **Reasoning**: Understand code from signatures alone
4. **Safety**: Catch errors at compile time, not runtime

For smart contracts where security is critical and bugs are costly, effects provide essential guarantees that make your code safer and more maintainable.
