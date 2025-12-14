---
title: Storage Structs
description: Structs for persistent contract state
---

Storage structs are structs designed to hold persistent blockchain state. They serve as effect types, enabling the explicit storage access pattern that Fe uses.

## What Makes a Storage Struct

A storage struct contains fields that persist on-chain:

```fe ignore
pub struct TokenStorage {
    pub balances: StorageMap<u256, u256>,
    pub total_supply: u256,
    pub owner: u256,
}
```

Key characteristics:
- Contains `StorageMap` fields for mappings
- Contains primitive fields for simple values
- Used as effect types with `uses` clause
- Bound to contract fields

## Storage Structs as Effects

Storage structs become effect types. Functions declare them in `uses`:

```fe ignore
pub struct TokenStorage {
    pub balances: StorageMap<u256, u256>,
    pub total_supply: u256,
}

// Function that reads from storage
fn get_balance(account: u256) uses TokenStorage -> u256 {
    TokenStorage.balances.get(account)
}

// Function that writes to storage
fn set_balance(account: u256, amount: u256) uses mut TokenStorage {
    TokenStorage.balances.set(account, amount)
}
```

## Connecting to Contracts

Contracts hold storage structs as fields and provide them as effects:

```fe ignore
contract Token {
    store: TokenStorage,

    recv TokenMsg {
        BalanceOf { account } -> u256 {
            with (TokenStorage = store) {
                get_balance(account)
            }
        }

        Transfer { to, amount } -> bool {
            with (TokenStorage = store) {
                transfer(caller(), to, amount)
            }
        }
    }
}
```

The `with (TokenStorage = store)` binds the contract field to the effect type.

## Designing Storage Structs

### Single Storage Struct

For simple contracts, one storage struct is sufficient:

```fe ignore
pub struct CounterStorage {
    pub value: u256,
}

fn get_value() uses CounterStorage -> u256 {
    CounterStorage.value
}

fn increment() uses mut CounterStorage {
    CounterStorage.value += 1
}
```

### Multiple Storage Structs

For complex contracts, split storage by concern:

```fe ignore
// Token balances
pub struct BalanceStorage {
    pub balances: StorageMap<u256, u256>,
    pub total_supply: u256,
}

// Allowance tracking
pub struct AllowanceStorage {
    pub allowances: StorageMap<u256, StorageMap<u256, u256>>,
}

// Access control
pub struct OwnerStorage {
    pub owner: u256,
    pub pending_owner: u256,
}

// Pausability
pub struct PauseStorage {
    pub paused: bool,
}
```

Each becomes an independent effect:

```fe ignore
fn transfer(from: u256, to: u256, amount: u256)
    uses mut BalanceStorage, PauseStorage -> bool
{
    if PauseStorage.paused {
        return false
    }
    // ... transfer logic
}
```

## StorageMap Fields

`StorageMap` is the primary collection type for storage:

```fe ignore
pub struct Registry {
    // Simple mapping: key -> value
    pub entries: StorageMap<u256, u256>,

    // Nested mapping: key -> (key -> value)
    pub nested: StorageMap<u256, StorageMap<u256, u256>>,
}
```

Access patterns:

```fe ignore
fn get_entry(key: u256) uses Registry -> u256 {
    Registry.entries.get(key)
}

fn set_entry(key: u256, value: u256) uses mut Registry {
    Registry.entries.set(key, value)
}

fn get_nested(outer: u256, inner: u256) uses Registry -> u256 {
    Registry.nested.get(outer).get(inner)
}

fn set_nested(outer: u256, inner: u256, value: u256) uses mut Registry {
    Registry.nested.get(outer).set(inner, value)
}
```

:::note[StorageMap Implementation]
The current `StorageMap` is a temporary implementation that will be replaced with a more advanced Map type in the future.
:::

## Visibility

Storage structs and their fields are typically public:

```fe ignore
pub struct TokenStorage {
    pub balances: StorageMap<u256, u256>,  // Public for effect access
    pub total_supply: u256,
}
```

The `pub` on fields allows `TokenStorage.balances` syntax in functions using the effect.

## Storage Structs vs Regular Structs

| Aspect | Storage Struct | Regular Struct |
|--------|----------------|----------------|
| Purpose | Persistent state | In-memory data |
| Contains | StorageMap, primitives | Any types |
| Used as | Effect type | Value type |
| Access | Via `uses` clause | Direct |
| Location | On-chain | Memory |

## Complete Example

A full token with storage structs:

```fe ignore
// Storage definitions
pub struct TokenStorage {
    pub balances: StorageMap<u256, u256>,
    pub allowances: StorageMap<u256, StorageMap<u256, u256>>,
    pub total_supply: u256,
}

pub struct MetadataStorage {
    pub name_hash: u256,
    pub symbol_hash: u256,
    pub decimals: u8,
}

// Functions using storage effects
fn get_balance(account: u256) uses TokenStorage -> u256 {
    TokenStorage.balances.get(account)
}

fn transfer(from: u256, to: u256, amount: u256) uses mut TokenStorage -> bool {
    let from_bal = TokenStorage.balances.get(from)
    if from_bal < amount {
        return false
    }
    TokenStorage.balances.set(from, from_bal - amount)

    let to_bal = TokenStorage.balances.get(to)
    TokenStorage.balances.set(to, to_bal + amount)
    true
}

fn get_decimals() uses MetadataStorage -> u8 {
    MetadataStorage.decimals
}

// Contract binding storage to effects
contract Token {
    tokens: TokenStorage,
    metadata: MetadataStorage,

    init(supply: u256, decimals: u8) {
        tokens.total_supply = supply
        tokens.balances.set(caller(), supply)
        metadata.decimals = decimals
    }

    recv Erc20 {
        Transfer { to, amount } -> bool {
            with (TokenStorage = tokens) {
                transfer(caller(), to, amount)
            }
        }

        BalanceOf { account } -> u256 {
            with (TokenStorage = tokens) {
                get_balance(account)
            }
        }

        Decimals -> u8 {
            with (MetadataStorage = metadata) {
                get_decimals()
            }
        }
    }
}
```

## Summary

| Concept | Description |
|---------|-------------|
| Storage struct | Struct holding persistent state |
| Effect type | Storage struct used in `uses` clause |
| `StorageMap<K, V>` | Key-value storage field |
| `uses Storage` | Read-only access |
| `uses mut Storage` | Read-write access |
| `with (Effect = field)` | Bind contract field to effect |
