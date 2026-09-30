---
title: Storage Fields
description: Declaring persistent state in contracts
---

Storage fields hold the persistent state of a contract. In Fe, storage is defined as struct types that contain storage-capable fields.

## Declaring Storage

Storage is defined as a struct with storage-compatible fields:

```fe
pub struct TokenStorage {
    pub balances: StorageMap<Address, u256>,
    pub total_supply: u256,
}

contract Token {
    mut store: TokenStorage,
}
```

The contract field `store` holds an instance of `TokenStorage`, which persists between transactions.

## Mutable and Immutable Fields

Contract fields are immutable by default. A field without `mut` is initialized in `init` and embedded in deployed code. Every successful constructor exit must initialize it; later handlers can read it but cannot request mutable access. A `mut` field uses mutable state and begins zero-initialized.

```fe
use std::abi::sol

msg ConfigMsg {
    #[selector = sol("owner()")]
    Owner -> Address,
}

pub contract Configured {
    owner: Address,
    mut count: u256,

    init(admin: Address) uses (mut owner) {
        owner = admin
    }

    recv ConfigMsg {
        Owner -> Address uses owner { owner }
    }
}
```

The `mut` on a contract field determines whether it can be mutated after deployment. `uses (mut field)` separately grants a particular handler permission to write it.

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
    pub balances: StorageMap<Address, u256>,

    // Maps (owner, spender) -> allowance
    pub allowances: StorageMap<(Address, Address), u256>,
}
```

Each structural occurrence of a map with an inferred salt receives its own layout parameter, including maps nested in structs and arrays. Fe 26.3 fixed collisions in these inferred layouts. Explicitly shared salts still share entries.

### Nested Structs

Storage structs can contain other structs:

```fe
pub struct Metadata {
    pub name_length: u256,
    pub decimals: u8,
}

pub struct TokenStorage {
    pub balances: StorageMap<Address, u256>,
    pub metadata: Metadata,
}
```

## Dynamic Bytes in Storage

`StorageBytes<K>` stores byte sequences under keys. Fe provides `to_memory(key)` to copy a stored payload into a `MemBuffer` without ending the call, and `word_at(key, index)` to read a payload word by word index.

```fe
use std::evm::{StorageBytes, crypto}

struct Documents {
    contents: StorageBytes<u256>,
}

fn document_hash(id: u256) -> u256 uses (documents: Documents) {
    let data = documents.contents.to_memory(key: id)
    crypto::keccak256(data.span())
}
```

The returned buffer contains payload bytes rather than an ABI length prefix. You can hash or otherwise process it before returning from the handler.

## Accessing Storage

Storage is accessed through effects, not directly:

```fe
//<hide>
pub struct TokenStorage { pub balances: StorageMap<Address, u256> }
//</hide>

fn get_balance(account: Address) -> u256 uses (store: TokenStorage) {
    store.balances.get(key: account)
}

fn set_balance(account: Address, amount: u256) uses (store: mut TokenStorage) {
    store.balances.set(key: account, value: amount)
}
```

In handlers, use the `uses` clause to access storage fields:

```fe
//<hide>
use std::abi::sol
pub struct TokenStorage { pub balances: StorageMap<Address, u256> }
msg TokenMsg {
    #[selector = sol("balanceOf(address)")]
    BalanceOf { account: Address } -> u256,
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
pub struct TokenStorage { pub balances: StorageMap<Address, u256> }
fn example(account: Address) uses (store: TokenStorage) {
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
pub struct TokenStorage { pub balances: StorageMap<Address, u256> }
fn example(account: Address, new_balance: u256) uses (store: mut TokenStorage) {
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
    pub allowances: StorageMap<(Address, Address), u256>,
}

fn get_allowance(owner: Address, spender: Address) -> u256 uses (store: AllowanceStorage) {
    store.allowances.get(key: (owner, spender))
}

fn set_allowance(owner: Address, spender: Address, amount: u256) uses (store: mut AllowanceStorage) {
    store.allowances.set(key: (owner, spender), value: amount)
}
```

## Multiple Storage Fields

Contracts can have multiple storage fields for logical separation:

```fe
//<hide>
use std::abi::sol
fn do_transfer(from: Address, to: Address, amount: u256) -> bool uses (tokens: mut BalanceStorage) {
    let _ = (from, to, amount, tokens)
    true
}
fn initiate_transfer(new_owner: Address) uses (ownership: mut OwnerStorage) {
    let _ = (new_owner, ownership)
}
msg TokenMsg {
    #[selector = sol("transfer(address,uint256)")]
    Transfer { to: Address, amount: u256 } -> bool,
}
msg OwnerMsg {
    #[selector = sol("transferOwnership(address)")]
    TransferOwnership { new_owner: Address },
}
//</hide>

pub struct BalanceStorage {
    pub balances: StorageMap<Address, u256>,
    pub total_supply: u256,
}

pub struct OwnerStorage {
    pub owner: Address,
    pub pending_owner: Address,
}

contract OwnableToken uses (ctx: Ctx) {
    mut tokens: BalanceStorage,
    mut ownership: OwnerStorage,

    recv TokenMsg {
        Transfer { to, amount } -> bool uses (ctx, mut tokens) {
            do_transfer(from: ctx.caller(), to, amount)
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

## Explicit Solidity Layouts

`SolSlot` accesses a runtime storage slot using Solidity's packed layout. Offsets count bytes from the low end of the word, and writing a field preserves its neighbours. `SolPacked` covers booleans, addresses, integer widths (including `sol::` wrappers), and fixed bytes. This is explicit layout access; it does not change Fe's ordinary field layout.

```fe
use std::evm::{RawStorage, SolSlot}

#[test]
fn packed_fields_preserve_neighbours() uses (storage: mut RawStorage) {
    let slot = SolSlot::at(0)
    slot.write(offset: 0, value: Address { inner: 123 })
    slot.write(offset: 20, value: true)
    let owner: Address = slot.read(offset: 0)
    let paused: bool = slot.read(offset: 20)
    assert!(owner.inner == 123 && paused)
    slot.write(offset: 20, value: false)
    let unchanged: Address = slot.read(offset: 0)
    assert!(unchanged == owner)
}
```

`read_bytes`/`write_bytes` and `read_string`/`write_string` use Solidity's short/long byte layouts. Replacing a longer value clears its abandoned storage words.

`SolMapping` derives Solidity mapping slots from a runtime root. For `mapping(address => mapping(address => uint256)) allowances` at slot 5:

```fe
use std::evm::{SolMapping, SolSlot, RawStorage}

fn allowance(owner: Address, spender: Address) -> u256 uses (storage: RawStorage) {
    let slot = SolMapping::at(5).nested(owner).slot_of(spender)
    SolSlot::at(slot).read(offset: 0)
}
```

Use the actual deployed layout when choosing slot roots and offsets. These helpers do not discover layouts or prevent collisions with compiler-managed fields.

## Summary

| Concept | Description |
|---------|-------------|
| Storage struct | Struct type containing persistent fields |
| Contract field | Instance of storage struct in contract |
| `StorageMap<K, V>` | Key-value mapping in storage |
| `.get(key)` | Read from map |
| `.set(key, value)` | Write to map |
| Effect access | Use `with` to provide storage to functions |
| `SolSlot` / `SolMapping` | Explicit access to Solidity storage layouts |
