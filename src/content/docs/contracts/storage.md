---
title: Storage Fields
description: Declaring persistent state in contracts
---

Storage fields hold the persistent state of a contract. In Fe, storage is defined as struct types that contain storage-capable fields.

## Declaring Storage

Storage is defined as a struct with storage-compatible fields:

```fe ignore
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

```fe ignore
pub struct Config {
    pub enabled: bool,
    pub count: u256,
    pub threshold: i128,
}
```

### StorageMap

For key-value mappings, use `StorageMap`:

```fe ignore
pub struct TokenStorage {
    // Maps account -> balance
    pub balances: StorageMap<u256, u256>,

    // Maps owner -> (spender -> allowance)
    pub allowances: StorageMap<u256, StorageMap<u256, u256>>,
}
```

:::note[StorageMap Implementation]
The current `StorageMap` is a temporary implementation that will be replaced with a more advanced Map type in the future.
:::

### Nested Structs

Storage structs can contain other structs:

```fe ignore
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

```fe ignore
fn get_balance(account: u256) uses TokenStorage -> u256 {
    TokenStorage.balances.get(account)
}

fn set_balance(account: u256, amount: u256) uses mut TokenStorage {
    TokenStorage.balances.set(account, amount)
}
```

In handlers, provide the contract field as an effect:

```fe ignore
contract Token {
    store: TokenStorage,

    recv TokenMsg {
        BalanceOf { account } -> u256 {
            with (TokenStorage = store) {
                get_balance(account)
            }
        }
    }
}
```

## StorageMap Operations

### get

Retrieve a value (returns zero/default if not set):

```fe ignore
let balance = TokenStorage.balances.get(account)
```

### set

Store a value:

```fe ignore
TokenStorage.balances.set(account, new_balance)
```

### Nested Maps

For nested mappings, chain the operations:

```fe ignore
pub struct AllowanceStorage {
    // owner -> spender -> amount
    pub allowances: StorageMap<u256, StorageMap<u256, u256>>,
}

fn get_allowance(owner: u256, spender: u256) uses AllowanceStorage -> u256 {
    AllowanceStorage.allowances.get(owner).get(spender)
}

fn set_allowance(owner: u256, spender: u256, amount: u256) uses mut AllowanceStorage {
    AllowanceStorage.allowances.get(owner).set(spender, amount)
}
```

## Multiple Storage Fields

Contracts can have multiple storage fields for logical separation:

```fe ignore
pub struct BalanceStorage {
    pub balances: StorageMap<u256, u256>,
    pub total_supply: u256,
}

pub struct OwnerStorage {
    pub owner: u256,
    pub pending_owner: u256,
}

contract OwnableToken {
    tokens: BalanceStorage,
    ownership: OwnerStorage,

    recv TokenMsg {
        Transfer { to, amount } -> bool {
            with (BalanceStorage = tokens) {
                do_transfer(caller(), to, amount)
            }
        }
    }

    recv OwnerMsg {
        TransferOwnership { new_owner } {
            with (OwnerStorage = ownership) {
                initiate_transfer(new_owner)
            }
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
