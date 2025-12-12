---
title: Storage Structs
description: Structs for persistent contract state
---

Storage structs are structs designed to hold persistent blockchain state. They serve as effect types, enabling the explicit storage access pattern that Fe uses.

## What Makes a Storage Struct

A storage struct contains fields that persist on-chain:

```fe
//<hide>
use _boilerplate::Map
//</hide>

pub struct TokenStorage {
    pub balances: Map<u256, u256>,
    pub total_supply: u256,
    pub owner: u256,
}
```

Key characteristics:
- Contains `Map` fields for mappings
- Contains primitive fields for simple values
- Used as effect types with `uses` clause
- Bound to contract fields

## Storage Structs as Effects

Storage structs become effect types. Functions declare them in `uses`:

```fe
//<hide>
use _boilerplate::Map
//</hide>

pub struct TokenStorage {
    pub balances: Map<u256, u256>,
    pub total_supply: u256,
}

// Function that reads from storage
fn get_balance(account: u256) -> u256 uses (store: TokenStorage) {
    store.balances.get(account)
}

// Function that writes to storage
fn set_balance(account: u256, amount: u256) uses (mut store: TokenStorage) {
    store.balances.set(account, amount)
}
```

## Connecting to Contracts

Contracts hold storage structs as fields and provide them as effects:

```fe
//<hide>
use _boilerplate::{Map, caller}
pub struct TokenStorage { pub balances: Map<u256, u256> }
fn get_balance(account: u256) -> u256 uses (store: TokenStorage) {
    store.balances.get(account)
}
fn transfer(from: u256, to: u256, amount: u256) -> bool uses (mut store: TokenStorage) {
    let _ = (from, to, amount, store)
    true
}
msg TokenMsg {
    #[selector = 0x70a08231]
    BalanceOf { account: u256 } -> u256,
    #[selector = 0xa9059cbb]
    Transfer { to: u256, amount: u256 } -> bool,
}
//</hide>

contract Token {
    mut store: TokenStorage,

    recv TokenMsg {
        BalanceOf { account } -> u256 uses (store) {
            get_balance(account)
        }

        Transfer { to, amount } -> bool uses (mut store) {
            transfer(caller(), to, amount)
        }
    }
}
```

The handler's `uses (store)` clause binds the contract field to the effect.

## Designing Storage Structs

### Single Storage Struct

For simple contracts, one storage struct is sufficient:

```fe
pub struct CounterStorage {
    pub value: u256,
}

fn get_value() -> u256 uses (store: CounterStorage) {
    store.value
}

fn increment() uses (mut store: CounterStorage) {
    store.value = store.value + 1
}
```

### Multiple Storage Structs

For complex contracts, split storage by concern:

```fe
//<hide>
use _boilerplate::Map
//</hide>

// Token balances
pub struct BalanceStorage {
    pub balances: Map<u256, u256>,
    pub total_supply: u256,
}

// Allowance tracking
pub struct AllowanceStorage {
    pub allowances: Map<u256, Map<u256, u256>>,
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

```fe
//<hide>
use _boilerplate::Map
pub struct BalanceStorage { pub balances: Map<u256, u256> }
pub struct PauseStorage { pub paused: bool }
//</hide>

fn transfer(from: u256, to: u256, amount: u256)
    -> bool uses (mut balances: BalanceStorage, pause: PauseStorage)
{
    if pause.paused {
        return false
    }
    // ... transfer logic
    //<hide>
    let _ = (from, to, amount, balances)
    //</hide>
    true
}
```

## Map Fields

`Map` is the primary collection type for storage:

```fe
//<hide>
use _boilerplate::Map
//</hide>

pub struct Registry {
    // Simple mapping: key -> value
    pub entries: Map<u256, u256>,

    // Nested mapping: key -> (key -> value)
    pub nested: Map<u256, Map<u256, u256>>,
}
```

Access patterns:

```fe
//<hide>
use _boilerplate::Map
pub struct Registry {
    pub entries: Map<u256, u256>,
    pub nested: Map<u256, Map<u256, u256>>,
}
//</hide>

fn get_entry(key: u256) -> u256 uses (reg: Registry) {
    reg.entries.get(key)
}

fn set_entry(key: u256, value: u256) uses (mut reg: Registry) {
    reg.entries.set(key, value)
}

fn get_nested(outer: u256, inner: u256) -> u256 uses (reg: Registry) {
    reg.nested.get(outer).get(inner)
}

fn set_nested(outer: u256, inner: u256, value: u256) uses (mut reg: Registry) {
    reg.nested.get(outer).set(inner, value)
}
```

:::note[Map Implementation]
The current `Map` is a temporary implementation that will be replaced with a more advanced Map type in the future.
:::

## Visibility

Storage structs and their fields are typically public:

```fe
//<hide>
use _boilerplate::Map
//</hide>

pub struct TokenStorage {
    pub balances: Map<u256, u256>,  // Public for effect access
    pub total_supply: u256,
}
```

The `pub` on fields allows `store.balances` syntax in functions using the effect.

## Storage Structs vs Regular Structs

| Aspect | Storage Struct | Regular Struct |
|--------|----------------|----------------|
| Purpose | Persistent state | In-memory data |
| Contains | Map, primitives | Any types |
| Used as | Effect type | Value type |
| Access | Via `uses` clause | Direct |
| Location | On-chain | Memory |

## Complete Example

A full token with storage structs:

```fe
//<hide>
use _boilerplate::{Map, caller}
msg Erc20 {
    #[selector = 0xa9059cbb]
    Transfer { to: u256, amount: u256 } -> bool,
    #[selector = 0x70a08231]
    BalanceOf { account: u256 } -> u256,
    #[selector = 0x313ce567]
    Decimals -> u8,
}
//</hide>

// Storage definitions
pub struct TokenStorage {
    pub balances: Map<u256, u256>,
    pub allowances: Map<u256, Map<u256, u256>>,
    pub total_supply: u256,
}

pub struct MetadataStorage {
    pub name_hash: u256,
    pub symbol_hash: u256,
    pub decimals: u8,
}

// Functions using storage effects
fn get_balance(account: u256) -> u256 uses (tokens: TokenStorage) {
    tokens.balances.get(account)
}

fn transfer(from: u256, to: u256, amount: u256) -> bool uses (mut tokens: TokenStorage) {
    let from_bal = tokens.balances.get(from)
    if from_bal < amount {
        return false
    }
    tokens.balances.set(from, from_bal - amount)

    let to_bal = tokens.balances.get(to)
    tokens.balances.set(to, to_bal + amount)
    true
}

fn get_decimals() -> u8 uses (metadata: MetadataStorage) {
    metadata.decimals
}

// Contract binding storage to effects
contract Token {
    mut tokens: TokenStorage,
    metadata: MetadataStorage,

    recv Erc20 {
        Transfer { to, amount } -> bool uses (mut tokens) {
            transfer(caller(), to, amount)
        }

        BalanceOf { account } -> u256 uses (tokens) {
            get_balance(account)
        }

        Decimals -> u8 uses (metadata) {
            get_decimals()
        }
    }
}
```

## Summary

| Concept | Description |
|---------|-------------|
| Storage struct | Struct holding persistent state |
| Effect type | Storage struct used in `uses` clause |
| `Map<K, V>` | Key-value storage field |
| `uses (store: Storage)` | Read-only access |
| `uses (mut store: Storage)` | Read-write access |
| Handler `uses (field)` | Bind contract field to effect in handlers |
