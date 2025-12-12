---
title: Maps
description: Key-value storage for smart contracts
---

Maps provide key-value storage for smart contracts. In Fe, maps are implemented as `StorageMap<K, V>` in the standard library, designed specifically for contract storage.

:::note[Temporary Implementation]
The current `StorageMap` is a minimal implementation that will be replaced with a more advanced `Map` type in the near future. The new implementation will offer additional features and a more ergonomic API. The concepts covered here will still apply, but the exact syntax may change.
:::

## StorageMap Basics

`StorageMap<K, V>` stores key-value pairs in contract storage:

```fe
use core::StorageMap

pub struct MyContract {
    balances: StorageMap<u256, u256>,
}
```

Unlike in-memory data structures, storage maps persist on the blockchain between transactions.

## Declaring Maps

Declare maps as fields in contract structs:

```fe
//<hide>
use core::StorageMap
//</hide>

pub struct Token {
    balances: StorageMap<u256, u256>,
    total_supply: u256,
}
```

Maps are always stored in contract storage. They cannot be created as local variables.

## Map Operations

### Reading Values

Use `get(key)` to read a value:

```fe
//<hide>
use core::StorageMap

pub struct Token {
    balances: StorageMap<u256, u256>,
}
//</hide>

impl Token {
    pub fn balance_of(self, account_id: u256) -> u256 {
        self.balances.get(key: account_id)
    }
}
```

If a key hasn't been set, `get` returns the default value for the value type (typically zero for numeric types).

### Writing Values

Use `set(key, value)` to store a value:

```fe
//<hide>
use core::StorageMap

pub struct Token {
    balances: StorageMap<u256, u256>,
}
//</hide>

impl Token {
    pub fn set_balance(mut self, account_id: u256, amount: u256) {
        self.balances.set(key: account_id, value: amount)
    }
}
```

Note that the `self` parameter must be `mut` to modify storage.

## Composite Keys

Use tuples as keys for multi-dimensional mappings:

```fe ignore
pub struct Token {
    // Maps (owner_id, spender_id) to allowance amount
    allowances: StorageMap<(u256, u256), u256>,
}

impl Token {
    pub fn allowance(self, owner_id: u256, spender_id: u256) -> u256 {
        self.allowances.get((owner_id, spender_id))
    }

    pub fn set_allowance(mut self, owner_id: u256, spender_id: u256, amount: u256) {
        self.allowances.set((owner_id, spender_id), amount)
    }
}
```

## Key Type Requirements

Map keys must implement the `StorageKey` trait. Common key types include:

- `u256`, `u128`, `u64`, etc. - Unsigned integers
- `i256`, `i128`, `i64`, etc. - Signed integers
- `bool` - Boolean values
- Tuples of the above types

## Value Type Requirements

Map values must implement `LoadableScalar` and `StorableScalar` traits. Common value types include:

- Numeric types (`u256`, `i256`, etc.)
- `bool`

## Storage Layout

StorageMap uses a Solidity-compatible storage layout. Each key-value pair is stored at a slot computed as:

```
slot = keccak256(key ++ base_slot)
```

This ensures:
- Different keys never collide
- Storage layout is deterministic
- Compatibility with Solidity contracts

## Common Patterns

### Token Balances

```fe
//<hide>
use core::StorageMap
//</hide>

pub struct Token {
    balances: StorageMap<u256, u256>,
}

impl Token {
    pub fn transfer(mut self, from_id: u256, to_id: u256, amount: u256) {
        let from_balance = self.balances.get(key: from_id)
        let to_balance = self.balances.get(key: to_id)

        self.balances.set(key: from_id, value: from_balance - amount)
        self.balances.set(key: to_id, value: to_balance + amount)
    }
}
```

### Allowance System

```fe ignore
pub struct Token {
    balances: StorageMap<u256, u256>,
    allowances: StorageMap<(u256, u256), u256>,
}

impl Token {
    pub fn approve(mut self, owner_id: u256, spender_id: u256, amount: u256) {
        self.allowances.set((owner_id, spender_id), amount)
    }

    pub fn transfer_from(
        mut self,
        owner_id: u256,
        spender_id: u256,
        to_id: u256,
        amount: u256
    ) {
        let allowed = self.allowances.get((owner_id, spender_id))
        // Check and update allowance
        self.allowances.set((owner_id, spender_id), allowed - amount)

        // Perform transfer
        let from_balance = self.balances.get(owner_id)
        let to_balance = self.balances.get(to_id)
        self.balances.set(owner_id, from_balance - amount)
        self.balances.set(to_id, to_balance + amount)
    }
}
```

### Role-Based Access

```fe ignore
pub struct AccessControl {
    // Maps (account_id, role_id) to whether role is granted
    roles: StorageMap<(u256, u256), bool>,
}

impl AccessControl {
    pub fn has_role(self, account_id: u256, role_id: u256) -> bool {
        self.roles.get((account_id, role_id))
    }

    pub fn grant_role(mut self, account_id: u256, role_id: u256) {
        self.roles.set((account_id, role_id), true)
    }

    pub fn revoke_role(mut self, account_id: u256, role_id: u256) {
        self.roles.set((account_id, role_id), false)
    }
}
```

## Limitations

- **No iteration**: You cannot iterate over all keys in a map. If you need iteration, maintain a separate list of keys.
- **No deletion**: There's no explicit delete operation. Set a value to its default (e.g., 0) to "remove" an entry.
- **Storage only**: Maps exist only in contract storage, not as local variables.

## Summary

| Operation | Syntax |
|-----------|--------|
| Declare map | `field: StorageMap<K, V>` |
| Read value | `map.get(key)` |
| Write value | `map.set(key, value)` |
| Tuple key | `StorageMap<(K1, K2), V>` |
| Access tuple key | `map.get((k1, k2))` |
