---
title: Storage Structs
description: Structs for persistent contract state
---

Storage structs are structs designed to hold persistent blockchain state. They serve as effect types, enabling the explicit storage access pattern that Fe uses.

## What Makes a Storage Struct

A storage struct contains fields that persist on-chain:

```fe
pub struct TokenStorage {
    pub balances: StorageMap<u256, u256>,
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
pub struct TokenStorage {
    pub balances: StorageMap<u256, u256>,
    pub total_supply: u256,
}

impl TokenStorage {
    // Read-only access
    fn get_balance(self, account: u256) -> u256 {
        self.balances.get(key: account)
    }

    // Write access
    fn set_balance(mut self, account: u256, amount: u256) {
        self.balances.set(key: account, value: amount)
    }
}
```

## Connecting to Contracts

Contracts hold storage structs as fields and provide them as effects:

```fe
//<hide>
use std::abi::sol
pub struct TokenStorage { pub balances: StorageMap<Address, u256> }
impl TokenStorage {
    fn get_balance(self, account: Address) -> u256 {
        self.balances.get(key: account)
    }
    fn transfer(mut self, from: Address, to: Address, amount: u256) -> bool {
        let _ = (from, to, amount)
        true
    }
}
msg TokenMsg {
    #[selector = sol("balanceOf(address)")]
    BalanceOf { account: Address } -> u256,
    #[selector = sol("transfer(address,uint256)")]
    Transfer { to: Address, amount: u256 } -> bool,
}
//</hide>

contract Token uses (ctx: Ctx) {
    mut store: TokenStorage,

    recv TokenMsg {
        BalanceOf { account } -> u256 uses (store) {
            store.get_balance(account)
        }

        Transfer { to, amount } -> bool uses (ctx, mut store) {
            store.transfer(from: ctx.caller(), to, amount)
        }
    }
}
```

The handler's `uses (store)` clause binds the contract field to the effect. Methods on the storage struct are called through this binding. The `Transfer` handler also pulls in `ctx`, the context effect declared on the contract with `uses (ctx: Ctx)`, so it can read the message sender via `ctx.caller()` (which returns an `Address`).

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
// Token balances
pub struct BalanceStorage {
    pub balances: StorageMap<u256, u256>,
    pub total_supply: u256,
}

// Allowance tracking
pub struct AllowanceStorage {
    pub allowances: StorageMap<(u256, u256), u256>,
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
pub struct BalanceStorage { pub balances: StorageMap<u256, u256> }
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
pub struct Registry {
    // Simple mapping: key -> value
    pub entries: StorageMap<u256, u256>,

    // Composite key mapping: (key, key) -> value
    pub nested: StorageMap<(u256, u256), u256>,
}
```

Access patterns:

```fe
pub struct Registry {
    pub entries: StorageMap<u256, u256>,
    pub nested: StorageMap<(u256, u256), u256>,
}

impl Registry {
    fn get_entry(self, key: u256) -> u256 {
        self.entries.get(key)
    }

    fn set_entry(mut self, key: u256, value: u256) {
        self.entries.set(key, value)
    }

    fn get_nested(self, outer: u256, inner: u256) -> u256 {
        self.nested.get(key: (outer, inner))
    }

    fn set_nested(mut self, outer: u256, inner: u256, value: u256) {
        self.nested.set(key: (outer, inner), value)
    }
}
```

:::note[Map Implementation]
The current `Map` is a temporary implementation that will be replaced with a more advanced Map type in the future.
:::

## Visibility

Storage structs and their fields are typically public:

```fe
pub struct TokenStorage {
    pub balances: StorageMap<u256, u256>,  // Public for effect access
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
msg Erc20 {
    #[selector = sol("transfer(address,uint256)")]
    Transfer { to: Address, amount: u256 } -> bool,
    #[selector = sol("balanceOf(address)")]
    BalanceOf { account: Address } -> u256,
    #[selector = sol("decimals()")]
    Decimals -> u8,
}
//</hide>

// Storage definitions
pub struct TokenStorage {
    pub balances: StorageMap<Address, u256>,
    pub allowances: StorageMap<(Address, Address), u256>,
    pub total_supply: u256,
}

impl TokenStorage {
    fn get_balance(self, account: Address) -> u256 {
        self.balances.get(key: account)
    }

    fn transfer(mut self, from: Address, to: Address, amount: u256) -> bool {
        let from_bal = self.balances.get(key: from)
        if from_bal < amount {
            return false
        }
        self.balances.set(key: from, value: from_bal - amount)

        let to_bal = self.balances.get(key: to)
        self.balances.set(key: to, value: to_bal + amount)
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
contract Token uses (ctx: Ctx) {
    mut tokens: TokenStorage,
    mut metadata: MetadataStorage,

    recv Erc20 {
        Transfer { to, amount } -> bool uses (ctx, mut tokens) {
            tokens.transfer(from: ctx.caller(), to, amount)
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
| `StorageMap<K, V>` | Key-value storage field |
| `uses (store: Storage)` | Read-only access |
| `uses (store: mut Storage)` | Read-write access |
| Handler `uses (field)` | Bind contract field to effect in handlers |
