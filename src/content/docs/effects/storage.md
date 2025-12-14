---
title: Storage as Effects
description: Contract storage modeled through explicit effects
---

Contract storage in Fe is modeled through effects. This makes storage access explicit—you always know when a function reads or modifies state.

## Storage Structs as Effects

Define storage as a struct that serves as an effect:

```fe
pub struct TokenStorage {
    pub balances: StorageMap<u256, u256>,
    pub total_supply: u256,
}
```

Functions that need storage access declare it explicitly:

```fe
fn get_balance(account: u256) uses TokenStorage -> u256 {
    TokenStorage.balances.get(account)
}

fn get_total_supply() uses TokenStorage -> u256 {
    TokenStorage.total_supply
}
```

## Mutable vs Immutable Storage Access

Use `mut` when the function modifies storage:

```fe
// Read-only access
fn get_balance(account: u256) uses TokenStorage -> u256 {
    TokenStorage.balances.get(account)
}

// Mutable access
fn set_balance(account: u256, amount: u256) uses mut TokenStorage {
    TokenStorage.balances.set(account, amount)
}

fn mint(to: u256, amount: u256) uses mut TokenStorage {
    let current = TokenStorage.balances.get(to)
    TokenStorage.balances.set(to, current + amount)
    TokenStorage.total_supply = TokenStorage.total_supply + amount
}
```

## Storage in Contracts

Contracts declare storage fields and provide them as effects to recv blocks:

```fe
pub struct TokenStorage {
    pub balances: StorageMap<u256, u256>,
    pub total_supply: u256,
}

contract Token {
    store: TokenStorage,
}
```

Inside recv blocks, use `with` to provide the storage effect:

```fe
// Helper functions with explicit storage effects
fn do_transfer(from: u256, to: u256, amount: u256) uses mut TokenStorage {
    let from_balance = TokenStorage.balances.get(from)
    let to_balance = TokenStorage.balances.get(to)

    TokenStorage.balances.set(from, from_balance - amount)
    TokenStorage.balances.set(to, to_balance + amount)
}

fn get_balance(account: u256) uses TokenStorage -> u256 {
    TokenStorage.balances.get(account)
}
```

## Multiple Storage Effects

Separate different concerns into distinct storage effects:

```fe
pub struct Balances {
    pub data: StorageMap<u256, u256>,
}

pub struct Allowances {
    pub data: StorageMap<(u256, u256), u256>,
}

pub struct Metadata {
    pub name: String,
    pub symbol: String,
    pub decimals: u8,
}

// Only needs Balances
fn transfer(from: u256, to: u256, amount: u256) uses mut Balances {
    let from_balance = Balances.data.get(from)
    let to_balance = Balances.data.get(to)

    Balances.data.set(from, from_balance - amount)
    Balances.data.set(to, to_balance + amount)
}

// Only needs Allowances
fn approve(owner: u256, spender: u256, amount: u256) uses mut Allowances {
    Allowances.data.set((owner, spender), amount)
}

// Needs both (read-only for allowances)
fn transfer_from(owner: u256, spender: u256, to: u256, amount: u256)
    uses (mut Balances, Allowances)
{
    let allowed = Allowances.data.get((owner, spender))
    // Check allowance...

    transfer(owner, to, amount)
}

// Only needs Metadata (read-only)
fn get_name() uses Metadata -> String {
    Metadata.name
}
```

## Why Explicit Storage Effects?

Making storage access explicit provides:

### Clear Dependencies

```fe
// This signature tells you exactly what storage is accessed
fn do_transfer(from: u256, to: u256, amount: u256) uses mut Balances {
    // ...
}
```

### Enforced Separation

```fe
// This function cannot accidentally modify Allowances
fn transfer(from: u256, to: u256, amount: u256) uses mut Balances {
    // Compiler error if you try to access Allowances here
}
```

### Easy Testing

```fe
fn test_transfer() {
    let mut balances = Balances {
        data: mock_storage_map()
    }

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

You don't need to manage storage layout manually—just define your storage structs and the compiler handles the rest.

## Summary

| Pattern | Description |
|---------|-------------|
| `uses Storage` | Read-only storage access |
| `uses mut Storage` | Mutable storage access |
| Storage struct | Group related storage fields |
| Multiple effects | Separate storage by concern |
| `with (Storage = ...)` | Provide storage effect in scope |
