---
title: Standard Library Effects
description: Ctx, Log, and Evm — the effect traits provided by Fe's standard library
---

Fe's standard library provides effect traits for common EVM operations. These are available via the prelude — no imports needed.

## `Ctx` — Execution Context

The `Ctx` trait provides read-only access to the EVM execution environment:

```fe
fn get_caller() -> Address uses (ctx: Ctx) {
    ctx.caller()
}

fn get_block() -> u256 uses (ctx: Ctx) {
    ctx.block_number()
}
```

Available methods on `Ctx`:

| Method | Returns | Description |
|--------|---------|-------------|
| `caller()` | `Address` | Message sender |
| `address()` | `Address` | Contract's own address |
| `value()` | `u256` | Ether sent with the call |
| `timestamp()` | `u256` | Current block timestamp |
| `block_number()` | `u256` | Current block number |

## `Log` — Event Emission

The `Log` trait allows emitting EVM log events. It requires `mut` because emitting is a side effect:

```fe
#[event]
struct Transfer {
    #[indexed]
    from: Address,
    #[indexed]
    to: Address,
    value: u256,
}

fn emit_transfer(from: Address, to: Address, value: u256) uses (log: mut Log) {
    log.emit(Transfer { from, to, value })
}
```

The `emit()` method works with any struct marked `#[event]`.

## `Evm` — The Root Effect

Under the hood, `Ctx` and `Log` are traits. The struct that implements them all is `Evm`. When you write `uses (ctx: Ctx)`, the contract's `Evm` instance satisfies that requirement.

`Evm` implements: `Ctx`, `Log`, `RawMem`, `RawStorage`, `RawOps`, `Create`, `Call`.

In tests, you interact with `Evm` directly:

```fe
//<hide>
use std::abi::sol
msg Msg {
    #[selector = sol("getCaller()")]
    GetCaller -> Address,
}
pub contract Example uses (ctx: Ctx) {
    init() {}
    recv Msg {
        GetCaller -> Address uses (ctx) { ctx.caller() }
    }
}
//</hide>

#[test]
fn test_with_evm() uses (evm: mut Evm) {
    let addr = evm.create2<Example>(value: 0, args: (), salt: 0)
    assert(addr.inner != 0)
}
```

## Custom Effects

Any type — struct, trait, or enum — can serve as an effect. The standard library effects are not special; they follow the same rules as user-defined effects. See [Storage as Effects](/effects/storage/) for the most common pattern: using your own structs as effects in contracts.

Here is a non-storage example — injecting validation logic as an effect:

```fe
pub struct RangeValidator {
    pub min: u256,
    pub max: u256,
}

impl RangeValidator {
    pub fn is_valid(self, value: u256) -> bool {
        value >= self.min && value <= self.max
    }
}

fn validate(value: u256) -> bool uses (v: RangeValidator) {
    v.is_valid(value)
}

#[test]
fn test_custom_effect() {
    let validator = RangeValidator { min: 10, max: 100 }
    let result = with (validator) {
        validate(value: 50)
    }
    assert(result == true)

    let result2 = with (validator) {
        validate(value: 5)
    }
    assert(result2 == false)
}
```

## Summary

| Effect | Type | Purpose |
|--------|------|---------|
| `Ctx` | Trait (std) | Execution environment (caller, block info) |
| `Log` | Trait (std) | Event emission |
| `Evm` | Struct (std) | Root effect implementing all EVM traits |
| Custom | Any type | Whatever capability your code needs |
