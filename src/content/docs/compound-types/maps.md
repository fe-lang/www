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
pub struct MyContract {
    balances: StorageMap<u256, u256>,
}
```

Unlike in-memory data structures, storage maps persist on the blockchain between transactions.

## Declaring Maps

Declare maps as fields in contract structs:

```fe
pub struct Token {
    balances: StorageMap<u256, u256>,
    total_supply: u256,
}
```

Map entries live in contract storage. The map value is a handle carrying a layout salt, not an in-memory collection. Normally declare maps in contract fields so the compiler assigns their layout parameters.

## Map Operations

### Reading Values

Use `get(key)` to read a value:

```fe
//<hide>
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

```fe
pub struct Token {
    // Maps (owner_id, spender_id) to allowance amount
    allowances: StorageMap<(u256, u256), u256>,
}

impl Token {
    pub fn allowance(self, owner_id: u256, spender_id: u256) -> u256 {
        self.allowances.get(key: (owner_id, spender_id))
    }

    pub fn set_allowance(mut self, owner_id: u256, spender_id: u256, amount: u256) {
        self.allowances.set(key: (owner_id, spender_id), value: amount)
    }
}
```

## Key Type Requirements

Map keys must implement the `StorageKey` trait. Common key types include:

- `u256`, `u128`, `u64`, etc. - Unsigned integers
- `i256`, `i128`, `i64`, etc. - Signed integers
- `Address` - EVM account addresses
- `bool` - Boolean values
- Tuples of the above types

## Value Type Requirements

Map values must implement `std::evm::word::WordRepr`, representing one EVM word. Common value types include:

- Numeric types (`u256`, `i256`, etc.)
- `bool` and `Address`

## Storage Layout

StorageMap uses a Solidity-compatible storage layout. Each key-value pair is stored at a slot computed as:

```
slot = keccak256(key ++ base_slot)
```

For scalar keys, the key word followed by the salt matches Solidity's mapping-slot derivation. Tuple keys concatenate their components before the salt; this is not the same layout as nested Solidity mappings. Distinct inferred salts separate different fields. Explicitly choosing the same salt deliberately shares the location space.

## Common Patterns

### Token Balances

```fe
use std::abi::sol

pub struct Token {
    balances: StorageMap<u256, u256>,
}

impl Token {
    pub fn transfer(mut self, from_id: u256, to_id: u256, amount: u256) {
        let from_balance = self.balances.get(key: from_id)

        self.balances.set(key: from_id, value: from_balance - amount)
        let to_balance = self.balances.get(key: to_id)
        self.balances.set(key: to_id, value: to_balance + amount)
    }
}

msg LedgerMsg {
    #[selector = sol("transfer(uint256,uint256,uint256)")]
    Transfer { from_id: u256, to_id: u256, amount: u256 } -> u256,
}

pub contract Ledger {
    mut token: Token,
    init() uses (mut token) {
        token.balances.set(key: 1, value: 100)
    }
    recv LedgerMsg {
        Transfer { from_id, to_id, amount } -> u256 uses (mut token) {
            token.transfer(from_id, to_id, amount)
            token.balances.get(key: to_id)
        }
    }
}

#[test]
fn self_transfer_preserves_balance() uses (evm: mut Evm) {
    let addr = evm.create2<Ledger>(value: 0, args: (), salt: 0)
    let balance: u256 = evm.call(addr, gas: 200000, value: 0,
        message: LedgerMsg::Transfer { from_id: 1, to_id: 1, amount: 40 })
    assert!(balance == 100)
}

```

Read the recipient balance after debiting the sender so a transfer to the same account preserves its balance. The `Ledger` contract initializes account `1` with 100 and exposes `transfer` through a message so the test can call it. An application must additionally authorize the sender; the numeric IDs here only illustrate map operations.

### Allowance System

```fe
pub struct Token {
    balances: StorageMap<u256, u256>,
    allowances: StorageMap<(u256, u256), u256>,
}

impl Token {
    pub fn approve(mut self, owner_id: u256, spender_id: u256, amount: u256) {
        self.allowances.set(key: (owner_id, spender_id), value: amount)
    }

    pub fn transfer_from(
        mut self,
        owner_id: u256,
        spender_id: u256,
        to_id: u256,
        amount: u256
    ) {
        let allowed = self.allowances.get(key: (owner_id, spender_id))
        // Check and update allowance
        self.allowances.set(key: (owner_id, spender_id), value: allowed - amount)

        // Perform transfer
        let from_balance = self.balances.get(key: owner_id)
        self.balances.set(key: owner_id, value: from_balance - amount)
        let to_balance = self.balances.get(key: to_id)
        self.balances.set(key: to_id, value: to_balance + amount)
    }
}
```

### Role-Based Access

```fe
pub struct AccessControl {
    // Maps (account_id, role_id) to whether role is granted
    roles: StorageMap<(u256, u256), bool>,
}

impl AccessControl {
    pub fn has_role(self, account_id: u256, role_id: u256) -> bool {
        self.roles.get(key: (account_id, role_id))
    }

    pub fn grant_role(mut self, account_id: u256, role_id: u256) {
        self.roles.set(key: (account_id, role_id), value: true)
    }

    pub fn revoke_role(mut self, account_id: u256, role_id: u256) {
        self.roles.set(key: (account_id, role_id), value: false)
    }
}
```

## Limitations

- **No iteration**: You cannot iterate over all keys in a map. If you need iteration, maintain a separate list of keys.
- **No deletion**: There's no explicit delete operation. Set a value to its default (e.g., 0) to "remove" an entry.
- **Persistent entries**: Copying a map handle does not copy its entries. Explicitly constructing handles with the same salt accesses the same mapping.

## Summary

| Operation | Syntax |
|-----------|--------|
| Declare map | `field: StorageMap<K, V>` |
| Read value | `map.get(key)` |
| Write value | `map.set(key, value)` |
| Tuple key | `StorageMap<(K1, K2), V>` |
| Access tuple key | `map.get((k1, k2))` |
