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

// 2. Define methods on the storage struct
impl TokenStore {
    fn get_supply(self) -> u256 {
        self.total_supply
    }

    fn do_mint(mut self, to: Address, amount: u256) uses (ctx: Ctx) {
        assert(ctx.caller() == self.owner)
        self.total_supply += amount
    }
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
            store.get_supply()
        }

        Mint { to, amount } uses (mut store, ctx) {
            store.do_mint(to, amount)
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
2. **`impl TokenStore`** defines methods with `self` / `mut self` (and optionally additional effects via `uses`)
3. **`mut store: TokenStore`** in the contract provides the effect
4. **`recv` handlers** bind the field with `uses (store)` or `uses (mut store)` and call methods on it
5. The compiler ensures effects match at every level

## Mutable vs Immutable Access

The `mut` keyword on `self` controls whether a method can modify storage:

```fe
pub struct TokenStorage {
    pub balances: StorageMap<u256, u256>,
    pub total_supply: u256,
}

impl TokenStorage {
    // Read-only — cannot modify storage
    fn get_balance(self, account: u256) -> u256 {
        self.balances.get(account)
    }

    // Mutable — can read and write
    fn mint(mut self, to: u256, amount: u256) {
        let current = self.balances.get(to)
        self.balances.set(to, current + amount)
        self.total_supply = self.total_supply + amount
    }
}
```

A method with `mut self` can call methods that only need `self`, but not vice versa.

## Multiple Storage Effects

Separate different concerns into distinct storage structs. Each struct's impl block only touches its own data:

```fe
pub struct Balances {
    pub data: StorageMap<u256, u256>,
}

impl Balances {
    fn transfer(mut self, from: u256, to: u256, amount: u256) {
        let from_balance = self.data.get(from)
        let to_balance = self.data.get(to)

        self.data.set(from, from_balance - amount)
        self.data.set(to, to_balance + amount)
    }
}

pub struct Metadata {
    pub name: u256,
    pub symbol: u256,
    pub decimals: u8,
}

impl Metadata {
    fn get_decimals(self) -> u8 {
        self.decimals
    }
}
```

This enforces separation of concerns at the compiler level. A bug in `get_decimals` cannot corrupt balances because `Metadata` has no access to them.

When a function needs multiple storage structs, it stays standalone and declares all effects explicitly:

```fe
//<hide>
pub struct Balances { pub data: StorageMap<u256, u256> }
impl Balances {
    fn transfer(mut self, from: u256, to: u256, amount: u256) {
        let _ = (from, to, amount)
    }
}
pub struct AuditLog { pub count: u256 }
//</hide>

// Composes multiple storage structs — standalone function
fn audited_transfer(from: u256, to: u256, amount: u256)
    uses (balances: mut Balances, audit: mut AuditLog)
{
    balances.transfer(from, to, amount)
    audit.count = audit.count + 1
}
```

## Combining Storage with Standard Library Effects

Storage struct methods can declare additional effects via `uses` for standard library effects (`Ctx`, `Log`):

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
//</hide>

struct TokenStore {
    total_supply: u256,
    owner: Address,
}

impl TokenStore {
    fn mint(mut self, to: Address, amount: u256) uses (ctx: Ctx, log: mut Log) {
        assert(ctx.caller() == self.owner)
        self.total_supply += amount

        log.emit(Transfer {
            from: Address { inner: 0 },
            to,
            value: amount,
        })
    }
}
```

The method signature makes all dependencies visible: storage access through `mut self`, execution context (`Ctx`), and event emission (`mut Log`).

## Storage Layout

The Fe compiler automatically maps storage structs to EVM storage slots. You define your structs and the compiler handles slot assignment, map key hashing (`keccak256`), and packing of small types.

## Summary

| Pattern | Description |
|---------|-------------|
| `fn method(self)` | Read-only storage access via impl |
| `fn method(mut self)` | Mutable storage access via impl |
| `fn method(mut self) uses (log: mut Log)` | Storage method with additional effects |
| Multiple storage structs | Separate storage by concern |
| `mut store: T` in contract | Contract field provides the effect |
| `uses (store)` in recv | Handler binds the contract field |
