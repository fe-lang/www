---
title: Why Effects Matter
description: Security, testability, and reasoning benefits
---

Effects provide significant benefits for smart contract development. They make code safer, more testable, and easier to reason about.

## Security Benefits

### Explicit Capabilities

Every function declares exactly what it can access:

```fe
//<hide>
pub struct Balances {}
//</hide>

fn transfer(from: u256, to: u256, amount: u256) uses (mut balances: Balances) {
    // Can ONLY modify Balances
    // Cannot access Allowances, Config, or anything else
    //<hide>
    let _ = (from, to, amount, balances)
    //</hide>
}
```

This makes security audits easier. You know a function's blast radius just by reading its signature.

### Principle of Least Privilege

Functions only get the capabilities they need:

```fe
//<hide>
use _boilerplate::Map
pub struct Balances { pub data: Map<u256, u256> }
//</hide>

// This function can only read
fn get_balance(account: u256) -> u256 uses (balances: Balances) {
    balances.data.get(account)
}

// This function can read AND write
fn set_balance(account: u256, amount: u256) uses (mut balances: Balances) {
    balances.data.set(account, amount)
}
```

A bug in `get_balance` cannot corrupt state because it lacks mutation capability.

### No Hidden State Access

Unlike languages where any function might access global state, Fe functions can only access what they declare:

```fe
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

```fe
//<hide>
extern {
    fn assert(_: bool, _: String<64>)
}
//</hide>

pub struct Config { pub fee_rate: u256 }
pub struct Balances { pub credited: u256 }
pub struct Logger { pub count: u256 }

impl Balances {
    pub fn new() -> Self { Balances { credited: 0 } }
    pub fn credit(mut self, amount: u256) { self.credited = amount }
}

impl Logger {
    pub fn new() -> Self { Logger { count: 0 } }
    pub fn log_payment(mut self, amount: u256, fee: u256) {
        let _ = (amount, fee)
        self.count += 1
    }
}

fn process_payment(amount: u256) uses (config: Config, mut balances: Balances, mut logger: Logger) {
    let fee = amount * config.fee_rate / 10000

    balances.credit(amount - fee)
    logger.log_payment(amount, fee)
}

// In tests, provide mock effects:
fn test_payment() {
    let config = Config { fee_rate: 100 }  // 1% fee
    let mut balances = Balances::new()
    let mut logger = Logger::new()

    with (Config = config, Balances = balances, Logger = logger) {
        process_payment(1000)
    }

    // Assert on mock state
    assert(balances.credited == 990, "credited check")
    assert(logger.count == 1, "log count check")
}
```

### Isolated Unit Tests

Test functions in isolation by providing only the effects they need:

```fe
//<hide>
extern {
    fn assert(_: bool, _: String<64>)
}
//</hide>

pub struct Balances { pub balance: u256 }

impl Balances {
    pub fn get(self, account: u256) -> u256 {
        let _ = account
        self.balance
    }
}

fn validate_transfer(from: u256, amount: u256) -> bool uses (balances: Balances) {
    balances.get(from) >= amount
}

fn test_validate_transfer() {
    let balances = Balances { balance: 100 }

    with (Balances = balances) {
        assert(validate_transfer(1, 50) == true, "should allow 50")
        assert(validate_transfer(1, 150) == false, "should reject 150")
    }
}
```

### No Test Fixtures Needed

Pure functions (no effects) need no setup at all:

```fe
fn calculate_shares(amount: u256, total: u256, supply: u256) -> u256 {
    if total == 0 {
        amount
    } else {
        amount * supply / total
    }
}
```

Tests can call pure functions directly without any setup:

```fe
//<hide>
extern {
    fn assert(_: bool, _: String<64>)
}

fn calculate_shares(amount: u256, total: u256, supply: u256) -> u256 {
    if total == 0 { amount } else { amount * supply / total }
}
//</hide>

fn test_calculate_shares() {
    // No setup needed, just call the function
    assert(calculate_shares(100, 1000, 500) == 50, "shares calc 1")
    assert(calculate_shares(100, 0, 0) == 100, "shares calc 2")
}
```

## Reasoning About Code

### Function Signatures Tell the Story

```fe
//<hide>
pub struct Ctx {}
pub struct TokenStore {}
pub struct Balances {}
pub struct EventLog {}
//</hide>

// Just by reading this signature, you know:
// - It needs caller context
// - It reads token store
// - It modifies balances
// - It writes to event log
fn transfer(to: u256, amount: u256)
    uses (ctx: Ctx, tokens: TokenStore, mut balances: Balances, mut log: EventLog)
{
    //<hide>
    let _ = (to, amount, ctx, tokens, balances, log)
    //</hide>
}
```

### Dependency Graphs

Effects create explicit dependency graphs:

```fe
//<hide>
pub struct A {}
pub struct B {}
//</hide>

fn inner1() uses (a: A) {
    //<hide>
    let _ = a
    //</hide>
}

fn inner2() uses (b: B) {
    //<hide>
    let _ = b
    //</hide>
}

fn outer() uses (a: A, b: B) {
    inner1()  // Uses effect A
    inner2()  // Uses effect B
}
```

You can trace exactly how effects flow through your code.

### Refactoring Safety

When refactoring, the compiler catches missing effects:

```fe
pub struct Config { pub multiplier: u256 }

// Before: function was pure
fn calculate_v1(x: u256) -> u256 {
    x * 2
}

// After: now needs Config
fn calculate_v2(x: u256) -> u256 uses (config: Config) {
    x * config.multiplier
}

// Compiler catches any call site that doesn't provide Config
```

## Compile-Time Guarantees

### Effect Checking Is Static

All effect checking happens at compile time:

- No runtime overhead for effect tracking
- Missing effects are caught before deployment
- Effect mismatches are compilation errors

### No Runtime Surprises

```fe
//<hide>
pub struct CriticalState {}
//</hide>

fn risky_operation() uses (mut state: CriticalState) {
    //<hide>
    let _ = state
    //</hide>
}

// This would cause a compiler error:
// fn caller() {
//     risky_operation()  // Error: CriticalState not available
// }

// Must declare the effect to call risky_operation
fn valid_caller() uses (mut state: CriticalState) {
    risky_operation()
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
