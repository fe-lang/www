---
title: The init Block
description: Constructor logic and contract initialization
---

The `init` block is Fe's constructor—it runs once when the contract is deployed and sets up the initial state.

## Basic Syntax

Declare an init block inside a contract:

```fe ignore
contract Token {
    store: TokenStorage,

    init() {
        // Initialization logic
    }
}
```

The init block runs automatically during deployment.

## Init Parameters

Init blocks can accept parameters passed during deployment:

```fe ignore
contract Token {
    store: TokenStorage,

    init(initial_supply: u256, owner: u256) {
        store.total_supply = initial_supply
        store.balances.set(owner, initial_supply)
    }
}
```

These parameters are encoded in the deployment transaction's calldata.

## Initializing Storage

The primary purpose of init is setting up storage:

```fe ignore
pub struct TokenStorage {
    pub balances: StorageMap<u256, u256>,
    pub total_supply: u256,
    pub owner: u256,
}

contract Token {
    store: TokenStorage,

    init(initial_supply: u256) {
        // Set primitive fields directly
        store.total_supply = initial_supply
        store.owner = caller()

        // Set map entries
        store.balances.set(caller(), initial_supply)
    }
}
```

### Direct Field Access in Init

Unlike recv handlers, the init block can access storage fields directly:

```fe ignore
init(supply: u256) {
    store.total_supply = supply  // Direct access allowed in init
}
```

This is because init runs in a special context during deployment, before normal message handling begins.

## Init Without Parameters

Contracts can have parameter-less init blocks:

```fe ignore
contract Counter {
    store: CounterStorage,

    init() {
        store.count = 0
    }
}
```

## Optional Init

The init block is optional. Contracts without init have default-initialized storage (zeros):

```fe ignore
contract Simple {
    store: SimpleStorage,
    // No init block - storage starts at default values

    recv SimpleMsg {
        // ...
    }
}
```

## Complex Initialization

Init can perform multiple setup operations:

```fe ignore
pub struct TokenStorage {
    pub balances: StorageMap<u256, u256>,
    pub allowances: StorageMap<u256, StorageMap<u256, u256>>,
    pub total_supply: u256,
    pub owner: u256,
    pub paused: bool,
}

contract Token {
    store: TokenStorage,

    init(name_hash: u256, initial_supply: u256) {
        let deployer = caller()

        // Set owner
        store.owner = deployer

        // Initialize supply
        store.total_supply = initial_supply
        store.balances.set(deployer, initial_supply)

        // Contract starts unpaused
        store.paused = false
    }
}
```

## What Init Cannot Do

The init block has some restrictions:

- **No external calls**: Init runs during deployment, so calling other contracts is restricted
- **No message receiving**: Init handles deployment, not incoming messages
- **Single execution**: Init runs exactly once per contract deployment

## Init and Effects

While init can access storage directly, it doesn't use the effect system in the same way as handlers:

```fe ignore
// In init: direct access
init(supply: u256) {
    store.total_supply = supply
}

// In handlers: effect-based access
recv TokenMsg {
    TotalSupply -> u256 {
        with (TokenStorage = store) {
            TokenStorage.total_supply
        }
    }
}
```

This difference exists because init is a special deployment-time operation, while handlers are for runtime message processing.

## Deployment Flow

When a Fe contract is deployed:

1. Contract bytecode is sent to the network
2. Init parameters are decoded from calldata
3. The init block executes
4. Storage is initialized
5. The contract is ready to receive messages

```
Deploy Transaction
       │
       ▼
┌──────────────┐
│ Decode init  │
│ parameters   │
└──────────────┘
       │
       ▼
┌──────────────┐
│ Execute init │
│ block        │
└──────────────┘
       │
       ▼
┌──────────────┐
│ Contract     │
│ ready        │
└──────────────┘
```

## Summary

| Concept | Description |
|---------|-------------|
| `init() { }` | Constructor block |
| `init(params) { }` | Constructor with parameters |
| Direct access | Init can access `store.field` directly |
| Optional | Contracts work without init (default values) |
| Single run | Executes once at deployment |
