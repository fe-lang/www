---
title: Storage as Effects
description: Contract storage modeled through explicit effects
---

Contract storage in Fe is modeled through effects. This makes storage access explicit: every function that reads or modifies state declares it in its signature.

## A Complete Example

Here is a full contract showing how storage structs become effects:

```fe
use std::abi::sol

msg TokenMsg {
    #[selector = sol("totalSupply()")]
    GetSupply -> u256,

    #[selector = sol("mint(address,uint256)")]
    Mint { to: Address, amount: u256 },
}

// 1. Define a storage struct — this is the effect type
struct TokenStore {
    total_supply: u256,
    owner: Address,
}

// 2. Helper functions declare what storage they need
fn get_supply() -> u256 uses (store: TokenStore) {
    store.total_supply
}

fn do_mint(to: Address, amount: u256) uses (ctx: Ctx, store: mut TokenStore) {
    assert(ctx.caller() == store.owner)
    store.total_supply += amount
}

// 3. The contract field provides the effect
pub contract Token uses (ctx: Ctx) {
    mut store: TokenStore

    init(owner: Address) uses (mut store) {
        store.total_supply = 0
        store.owner = owner
    }

    recv TokenMsg {
        // recv handlers bind the contract field as an effect
        GetSupply -> u256 uses (store) {
            get_supply()
        }

        Mint { to, amount } uses (mut store, ctx) {
            do_mint(to, amount)
        }
    }
}

#[test]
fn test_token() uses (evm: mut Evm) {
    let owner = Address { inner: 1 }
    let addr = evm.create2<Token>(value: 0, args: (owner,), salt: 0)

    let supply: u256 = evm.call(
        addr: addr, gas: 100000, value: 0,
        message: TokenMsg::GetSupply {},
    )
    assert(supply == 0)
}
```

The flow is:
1. **`struct TokenStore`** defines the storage layout
2. **Helper functions** declare `uses (store: TokenStore)` or `uses (store: mut TokenStore)`
3. **`mut store: TokenStore`** in the contract provides the effect
4. **`recv` handlers** bind the field with `uses (store)` or `uses (mut store)`
5. The compiler ensures effects match at every level

## Mutable vs Immutable Access

The `mut` keyword controls whether a function can modify storage:

```fe
//<hide>
use _boilerplate::Map
pub struct TokenStorage {
    pub balances: Map<u256, u256>,
    pub total_supply: u256,
}
//</hide>

// Read-only — cannot modify storage
fn get_balance(account: u256) -> u256 uses (store: TokenStorage) {
    store.balances.get(account)
}

// Mutable — can read and write
fn mint(to: u256, amount: u256) uses (store: mut TokenStorage) {
    let current = store.balances.get(to)
    store.balances.set(to, current + amount)
    store.total_supply = store.total_supply + amount
}
```

A function with `mut` access can call functions that only need read-only access, but not vice versa.

## Multiple Storage Effects

Separate different concerns into distinct storage structs. Each function only declares the storage it actually needs:

```fe
//<hide>
use _boilerplate::Map
//</hide>

pub struct Balances {
    pub data: Map<u256, u256>,
}

pub struct Metadata {
    pub name: u256,
    pub symbol: u256,
    pub decimals: u8,
}

// Only needs Balances — cannot touch Metadata
fn transfer(from: u256, to: u256, amount: u256) uses (balances: mut Balances) {
    let from_balance = balances.data.get(from)
    let to_balance = balances.data.get(to)

    balances.data.set(from, from_balance - amount)
    balances.data.set(to, to_balance + amount)
}

// Only needs Metadata — cannot touch Balances
fn get_decimals() -> u8 uses (meta: Metadata) {
    meta.decimals
}
```

This enforces separation of concerns at the compiler level. A bug in `get_decimals` cannot corrupt balances because the function has no access to them.

## Combining Storage with Standard Library Effects

Storage effects work alongside the standard library effects (`Ctx`, `Log`):

```fe
//<hide>
#[event]
struct Transfer {
    #[indexed]
    from: Address,
    #[indexed]
    to: Address,
    value: u256,
}

struct TokenStore {
    total_supply: u256,
    owner: Address,
}
//</hide>

fn mint(to: Address, amount: u256) uses (ctx: Ctx, store: mut TokenStore, log: mut Log) {
    assert(ctx.caller() == store.owner)
    store.total_supply += amount

    log.emit(Transfer {
        from: Address { inner: 0 },
        to,
        value: amount,
    })
}
```

The signature makes all dependencies visible: execution context (`Ctx`), mutable storage (`mut TokenStore`), and event emission (`mut Log`).

## Storage Layout

The Fe compiler automatically maps storage structs to EVM storage slots. You define your structs and the compiler handles slot assignment, map key hashing (`keccak256`), and packing of small types.

## Summary

| Pattern | Description |
|---------|-------------|
| `uses (s: Storage)` | Read-only storage access |
| `uses (s: mut Storage)` | Mutable storage access |
| Multiple storage structs | Separate storage by concern |
| `mut store: T` in contract | Contract field provides the effect |
| `uses (store)` in recv | Handler binds the contract field |
