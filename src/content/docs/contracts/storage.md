---
title: Storage Fields
description: Declaring persistent state in contracts
---

Storage fields hold the persistent state of a contract. In Fe, storage is defined as struct types that contain storage-capable fields.

## Declaring Storage

Storage is defined as a struct with storage-compatible fields:

```fe
pub struct TokenStorage {
    pub balances: StorageMap<u256, u256>,
    pub total_supply: u256,
}

contract Token {
    store: TokenStorage,
}
```

The contract field `store` holds an instance of `TokenStorage`, which persists between transactions.

## Storage-Compatible Types

### Primitive Types

All primitive types can be stored:

```fe
pub struct Config {
    pub enabled: bool,
    pub count: u256,
    pub threshold: i128,
}
```

### StorageMap

For key-value mappings, use `StorageMap`:

```fe
pub struct TokenStorage {
    // Maps account -> balance
    pub balances: StorageMap<u256, u256>,

    // Maps (owner, spender) -> allowance
    pub allowances: StorageMap<(u256, u256), u256>,
}
```

:::note[StorageMap Implementation]
The current `StorageMap` is a temporary implementation that will be replaced with a more advanced Map type in the future.
:::

### Nested Structs

Storage structs can contain other structs:

```fe
pub struct Metadata {
    pub name_length: u256,
    pub decimals: u8,
}

pub struct TokenStorage {
    pub balances: StorageMap<u256, u256>,
    pub metadata: Metadata,
}
```

## Accessing Storage

Storage is accessed through effects, not directly:

```fe
//<hide>
pub struct TokenStorage { pub balances: StorageMap<u256, u256> }
//</hide>

fn get_balance(account: u256) -> u256 uses (store: TokenStorage) {
    store.balances.get(key: account)
}

fn set_balance(account: u256, amount: u256) uses (store: mut TokenStorage) {
    store.balances.set(key: account, value: amount)
}
```

In handlers, use the `uses` clause to access storage fields:

```fe
//<hide>
use std::abi::sol
pub struct TokenStorage { pub balances: StorageMap<u256, u256> }
msg TokenMsg {
    #[selector = sol("balanceOf(address)")]
    BalanceOf { account: u256 } -> u256,
}
//</hide>

contract Token {
    mut store: TokenStorage,

    recv TokenMsg {
        BalanceOf { account } -> u256 uses (store) {
            store.balances.get(key: account)
        }
    }
}
```

## StorageMap Operations

### get

Retrieve a value (returns zero/default if not set):

```fe
//<hide>
pub struct TokenStorage { pub balances: StorageMap<u256, u256> }
fn example(account: u256) uses (store: TokenStorage) {
//</hide>
let balance = store.balances.get(key: account)
//<hide>
let _ = balance
}
//</hide>
```

### set

Store a value:

```fe
//<hide>
pub struct TokenStorage { pub balances: StorageMap<u256, u256> }
fn example(account: u256, new_balance: u256) uses (store: mut TokenStorage) {
//</hide>
store.balances.set(key: account, value: new_balance)
//<hide>
}
//</hide>
```

### Composite Keys

For multi-dimensional mappings, use tuple keys:

```fe
pub struct AllowanceStorage {
    // (owner, spender) -> amount
    pub allowances: StorageMap<(u256, u256), u256>,
}

fn get_allowance(owner: u256, spender: u256) -> u256 uses (store: AllowanceStorage) {
    store.allowances.get(key: (owner, spender))
}

fn set_allowance(owner: u256, spender: u256, amount: u256) uses (store: mut AllowanceStorage) {
    store.allowances.set(key: (owner, spender), value: amount)
}
```

## Multiple Storage Fields

Contracts can have multiple storage fields for logical separation:

```fe
//<hide>
use std::abi::sol
use _boilerplate::caller
fn do_transfer(from: u256, to: u256, amount: u256) -> bool uses (tokens: mut BalanceStorage) {
    let _ = (from, to, amount, tokens)
    true
}
fn initiate_transfer(new_owner: u256) uses (ownership: mut OwnerStorage) {
    let _ = (new_owner, ownership)
}
msg TokenMsg {
    #[selector = sol("transfer(address,uint256)")]
    Transfer { to: u256, amount: u256 } -> bool,
}
msg OwnerMsg {
    #[selector = sol("transferOwnership(address)")]
    TransferOwnership { new_owner: u256 },
}
//</hide>

pub struct BalanceStorage {
    pub balances: StorageMap<u256, u256>,
    pub total_supply: u256,
}

pub struct OwnerStorage {
    pub owner: u256,
    pub pending_owner: u256,
}

contract OwnableToken {
    mut tokens: BalanceStorage,
    mut ownership: OwnerStorage,

    recv TokenMsg {
        Transfer { to, amount } -> bool uses (mut tokens) {
            do_transfer(from: caller(), to, amount)
        }
    }

    recv OwnerMsg {
        TransferOwnership { new_owner } uses (mut ownership) {
            initiate_transfer(new_owner)
        }
    }
}
```

## Storage Layout

Fe computes storage slots automatically. Each field gets a deterministic location based on:
- The struct layout
- The field position
- For maps, the key combined with the base slot

You don't need to manually specify storage slots.

## Summary

| Concept | Description |
|---------|-------------|
| Storage struct | Struct type containing persistent fields |
| Contract field | Instance of storage struct in contract |
| `StorageMap<K, V>` | Key-value mapping in storage |
| `.get(key)` | Read from map |
| `.set(key, value)` | Write to map |
| Effect access | Use `with` to provide storage to functions |
