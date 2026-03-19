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

Storage structs serve as effect types. Define methods on them using impl blocks, with `self` for read-only and `mut self` for write access:

```fe
//<hide>
use _boilerplate::Map
//</hide>

pub struct TokenStorage {
    pub balances: Map<u256, u256>,
    pub total_supply: u256,
}

impl TokenStorage {
    // Read-only access
    fn get_balance(self, account: u256) -> u256 {
        self.balances.get(account)
    }

    // Write access
    fn set_balance(mut self, account: u256, amount: u256) {
        self.balances.set(account, amount)
    }
}
```

## Connecting to Contracts

Contracts hold storage structs as fields and provide them as effects:

```fe
//<hide>
use std::abi::sol
use _boilerplate::{Map, caller}
pub struct TokenStorage { pub balances: Map<u256, u256> }
impl TokenStorage {
    fn get_balance(self, account: u256) -> u256 {
        self.balances.get(account)
    }
    fn transfer(mut self, from: u256, to: u256, amount: u256) -> bool {
        let _ = (from, to, amount)
        true
    }
}
msg TokenMsg {
    #[selector = sol("balanceOf(address)")]
    BalanceOf { account: u256 } -> u256,
    #[selector = sol("transfer(address,uint256)")]
    Transfer { to: u256, amount: u256 } -> bool,
}
//</hide>

contract Token {
    mut store: TokenStorage,

    recv TokenMsg {
        BalanceOf { account } -> u256 uses (store) {
            store.get_balance(account)
        }

        Transfer { to, amount } -> bool uses (mut store) {
            store.transfer(caller(), to, amount)
        }
    }
}
```

The handler's `uses (store)` clause binds the contract field to the effect. Methods on the storage struct are called through this binding.

## Designing Storage Structs

### Single Storage Struct

For simple contracts, one storage struct is sufficient:

```fe
pub struct CounterStorage {
    pub value: u256,
}

impl CounterStorage {
    fn get_value(self) -> u256 {
        self.value
    }

    fn increment(mut self) {
        self.value = self.value + 1
    }
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
    -> bool uses (balances: mut BalanceStorage, pause: PauseStorage)
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
//</hide>

pub struct Registry {
    pub entries: Map<u256, u256>,
    pub nested: Map<u256, Map<u256, u256>>,
}

impl Registry {
    fn get_entry(self, key: u256) -> u256 {
        self.entries.get(key)
    }

    fn set_entry(mut self, key: u256, value: u256) {
        self.entries.set(key, value)
    }

    fn get_nested(self, outer: u256, inner: u256) -> u256 {
        self.nested.get(outer).get(inner)
    }

    fn set_nested(mut self, outer: u256, inner: u256, value: u256) {
        self.nested.get(outer).set(inner, value)
    }
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
use std::abi::sol
use _boilerplate::{Map, caller}
msg Erc20 {
    #[selector = sol("transfer(address,uint256)")]
    Transfer { to: u256, amount: u256 } -> bool,
    #[selector = sol("balanceOf(address)")]
    BalanceOf { account: u256 } -> u256,
    #[selector = sol("decimals()")]
    Decimals -> u8,
}
//</hide>

// Storage definitions
pub struct TokenStorage {
    pub balances: Map<u256, u256>,
    pub allowances: Map<u256, Map<u256, u256>>,
    pub total_supply: u256,
}

impl TokenStorage {
    fn get_balance(self, account: u256) -> u256 {
        self.balances.get(account)
    }

    fn transfer(mut self, from: u256, to: u256, amount: u256) -> bool {
        let from_bal = self.balances.get(from)
        if from_bal < amount {
            return false
        }
        self.balances.set(from, from_bal - amount)

        let to_bal = self.balances.get(to)
        self.balances.set(to, to_bal + amount)
        true
    }
}

pub struct MetadataStorage {
    pub name_hash: u256,
    pub symbol_hash: u256,
    pub decimals: u8,
}

impl MetadataStorage {
    fn get_decimals(self) -> u8 {
        self.decimals
    }
}

// Contract binding storage to effects
contract Token {
    mut tokens: TokenStorage,
    metadata: MetadataStorage,

    recv Erc20 {
        Transfer { to, amount } -> bool uses (mut tokens) {
            tokens.transfer(caller(), to, amount)
        }

        BalanceOf { account } -> u256 uses (tokens) {
            tokens.get_balance(account)
        }

        Decimals -> u8 uses (metadata) {
            metadata.get_decimals()
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
| `uses (store: mut Storage)` | Read-write access |
| Handler `uses (field)` | Bind contract field to effect in handlers |
