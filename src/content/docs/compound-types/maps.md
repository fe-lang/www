---
title: Maps
description: Key-value storage for smart contracts
---

Maps provide key-value storage for smart contracts. In Fe, maps are implemented as `StorageMap<K, V>` in the standard library, designed specifically for contract storage.

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

A map is a **storage collection**: it lives at its place in contract storage and is never copied or moved. A struct that holds a map is *state-only*: it is reached through a contract field, a `mut` or view parameter, or an effect, never constructed as a value. Declare maps in contract fields (directly or inside a storage struct) and the compiler assigns their slots.

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

If a key hasn't been set, `get` returns the zero value for the value type (zero for numbers, `false`, the zero address).

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

### Indexing

`map[key]` names the entry's place directly, so it can be read, assigned, and updated in place like any other place:

```fe
pub struct Token {
    balances: StorageMap<Address, u256>,
}

impl Token {
    pub fn balance_of(self, owner: Address) -> u256 {
        self.balances[owner]
    }

    pub fn mint(mut self, to: Address, amount: u256) {
        self.balances[to] += amount
    }
}
```

`map[key].field += 1` reads and writes a single field of a struct value, and `let entry = mut map[key]` binds a mutable access to the entry.

### Removing Values

`remove(key)` zeroes the entry, so it reads as if it was never set:

```fe
//<hide>
pub struct Token {
    balances: StorageMap<Address, u256>,
}
//</hide>
impl Token {
    pub fn burn_all(mut self, owner: Address) {
        self.balances.remove(owner)
    }
}
```

## Nested Maps

A map's value can itself be a map, like Solidity's `mapping(address => mapping(address => uint256))`. Index twice to reach an inner entry:

```fe
pub struct Allowances {
    allowed: StorageMap<Address, StorageMap<Address, u256>>,
}

impl Allowances {
    pub fn allowance(self, owner: Address, spender: Address) -> u256 {
        self.allowed[owner][spender]
    }

    pub fn approve(mut self, owner: Address, spender: Address, amount: u256) {
        self.allowed[owner][spender] = amount
    }
}
```

The inner map derives its slot from the outer entry, exactly as Solidity nests mappings.

## Composite Keys

Tuples can also be used as keys:

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

A map's value can be any type that can live in storage: integers, `bool`, `Address`, typed units such as `Wei`, structs (with narrow fields packed like Solidity struct members), arrays, and other maps. The value at `key` is laid out in storage like any value of its type. A value that holds a storage collection, such as a nested map, cannot be `remove`d, since zeroing its slots would leave the inner entries behind.

## Storage Layout

StorageMap uses Solidity's mapping layout. The map itself takes one slot, which is never written, and the value for a key is stored from the slot computed as:

```
slot = keccak256(key ++ map_slot)
```

For scalar keys this matches Solidity's mapping-slot derivation. Tuple keys concatenate their components before the map slot; this is not the same layout as nested Solidity mappings, so use a nested map when you need Solidity compatibility.

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
    let addr = evm.create2<Ledger>(value: Wei::zero(), args: (), salt: 0)
    let balance: u256 = evm.call(addr, gas: 200000, value: Wei::zero(),
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
- **No copies**: A map is never copied or moved. Pass the struct holding it as a `mut` or view parameter, or as an effect.
- **Persistent storage only**: Map entries are persistent, so a map cannot live in transient storage.

## Summary

| Operation | Syntax |
|-----------|--------|
| Declare map | `field: StorageMap<K, V>` |
| Read value | `map.get(key)` or `map[key]` |
| Write value | `map.set(key, value)` or `map[key] = value` |
| Update in place | `map[key] += 1` |
| Remove value | `map.remove(key)` |
| Nested map | `StorageMap<K1, StorageMap<K2, V>>`, `map[k1][k2]` |
| Tuple key | `StorageMap<(K1, K2), V>` |
| Access tuple key | `map.get((k1, k2))` |
