---
title: Storage as Effects
description: Contract storage modeled through explicit effects
---

Contract storage in Fe is modeled through effects. This makes storage access explicit: you always know when a function reads or modifies state.

## Storage Structs as Effects

Define storage as a struct that serves as an effect:

```fe
//<hide>
use _boilerplate::Map
//</hide>

pub struct TokenStorage {
    pub balances: Map<u256, u256>,
    pub total_supply: u256,
}
```

Functions that need storage access declare it explicitly:

```fe
//<hide>
use _boilerplate::Map
pub struct TokenStorage {
    pub balances: Map<u256, u256>,
    pub total_supply: u256,
}
//</hide>

fn get_balance(account: u256) -> u256 uses (store: TokenStorage) {
    store.balances.get(account)
}

fn get_total_supply() -> u256 uses (store: TokenStorage) {
    store.total_supply
}
```

## Mutable vs Immutable Storage Access

Use `mut` when the function modifies storage:

```fe
//<hide>
use _boilerplate::Map
pub struct TokenStorage {
    pub balances: Map<u256, u256>,
    pub total_supply: u256,
}
//</hide>

// Read-only access
fn get_balance(account: u256) -> u256 uses (store: TokenStorage) {
    store.balances.get(account)
}

// Mutable access
fn set_balance(account: u256, amount: u256) uses (mut store: TokenStorage) {
    store.balances.set(account, amount)
}

fn mint(to: u256, amount: u256) uses (mut store: TokenStorage) {
    let current = store.balances.get(to)
    store.balances.set(to, current + amount)
    store.total_supply = store.total_supply + amount
}
```

## Storage in Contracts

Contracts declare storage fields and provide them as effects to recv blocks:

```fe
//<hide>
use _boilerplate::Map
//</hide>

pub struct TokenStorage {
    pub balances: Map<u256, u256>,
    pub total_supply: u256,
}

contract Token {
    store: TokenStorage,
}
```

Inside recv blocks, use `with` to provide the storage effect:

```fe
//<hide>
use _boilerplate::Map
pub struct TokenStorage {
    pub balances: Map<u256, u256>,
    pub total_supply: u256,
}
//</hide>

// Helper functions with explicit storage effects
fn do_transfer(from: u256, to: u256, amount: u256) uses (mut store: TokenStorage) {
    let from_balance = store.balances.get(from)
    let to_balance = store.balances.get(to)

    store.balances.set(from, from_balance - amount)
    store.balances.set(to, to_balance + amount)
}

fn get_balance(account: u256) -> u256 uses (store: TokenStorage) {
    store.balances.get(account)
}
```

## Multiple Storage Effects

Separate different concerns into distinct storage effects:

```fe
//<hide>
use _boilerplate::Map
//</hide>

pub struct Balances {
    pub data: Map<u256, u256>,
}

pub struct Metadata {
    pub name: u256,  // Simplified for example
    pub symbol: u256,
    pub decimals: u8,
}

// Only needs Balances
fn transfer(from: u256, to: u256, amount: u256) uses (mut balances: Balances) {
    let from_balance = balances.data.get(from)
    let to_balance = balances.data.get(to)

    balances.data.set(from, from_balance - amount)
    balances.data.set(to, to_balance + amount)
}

// Only needs Metadata (read-only)
fn get_decimals() -> u8 uses (meta: Metadata) {
    meta.decimals
}
```

## Why Explicit Storage Effects?

Making storage access explicit provides:

### Clear Dependencies

```fe
//<hide>
pub struct Balances { pub data: u256 }
//</hide>

// This signature tells you exactly what storage is accessed
fn do_transfer(from: u256, to: u256, amount: u256) uses (mut balances: Balances) {
    // ...
    //<hide>
    let _ = (from, to, amount, balances)
    //</hide>
}
```

### Enforced Separation

```fe
//<hide>
pub struct Balances { pub data: u256 }
//</hide>

// This function cannot accidentally modify Allowances
fn transfer(from: u256, to: u256, amount: u256) uses (mut balances: Balances) {
    // Compiler error if you try to access Allowances here
    //<hide>
    let _ = (from, to, amount, balances)
    //</hide>
}
```

### Easy Testing

```fe
//<hide>
pub struct Balances { pub data: u256 }
fn transfer(from: u256, to: u256, amount: u256) uses (mut balances: Balances) {
    let _ = (from, to, amount, balances)
}
//</hide>

fn test_transfer() {
    let mut balances = Balances { data: 0 }

    with (Balances = balances) {
        transfer(1, 2, 100)
        // Assert on balances state
    }
}
```

## Storage Layout

Storage effects map to EVM storage slots. The Fe compiler handles:

- Slot assignment for primitive types
- Storage map slot calculation (keccak256 hashing)
- Efficient packing of small types

You don't need to manage storage layout manually. Just define your storage structs and the compiler handles the rest.

## Summary

| Pattern | Description |
|---------|-------------|
| `uses (s: Storage)` | Read-only storage access |
| `uses (mut s: Storage)` | Mutable storage access |
| Storage struct | Group related storage fields |
| Multiple effects | Separate storage by concern |
| `with (Storage = ...)` | Provide storage effect in scope |
