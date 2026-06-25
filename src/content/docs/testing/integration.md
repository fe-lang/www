---
title: Integration Testing
description: Testing deployed contracts with evm.create2 and evm.call
---

Integration tests deploy contracts to a local EVM and interact with them through messages — just like a real caller would.

## The `Evm` Effect in Tests

Test functions that interact with contracts need the `Evm` effect:

```fe
//<hide>
use std::abi::sol
msg Msg {
    #[selector = sol("getValue()")]
    GetValue -> u256,
}
struct Store { value: u256 }
pub contract MyContract {
    mut store: Store
    init() uses (mut store) { store.value = 42 }
    recv Msg {
        GetValue -> u256 uses (store) { store.value }
    }
}
//</hide>

#[test]
fn test_my_contract() uses (evm: mut Evm) {
    // evm provides the EVM runtime for deploying and calling contracts
    let addr = evm.create2<MyContract>(value: 0, args: (), salt: 0)
    assert!(addr.inner != 0)
}
```

`evm: mut Evm` gives you the ability to deploy contracts, send messages, and emit events. The `mut` is required because these operations modify EVM state.

## Deploying Contracts

Use `evm.create2` to deploy a contract:

```fe
//<hide>
use std::abi::sol
msg Msg {
    #[selector = sol("getCount()")]
    GetCount -> u256,
}
struct CounterStore { count: u256, step: u256 }
pub contract Counter {
    mut store: CounterStore
    init(step: u256) uses (mut store) {
        store.count = 0
        store.step = step
    }
    recv Msg {
        GetCount -> u256 uses (store) { store.count }
    }
}
//</hide>

#[test]
fn test_deploy() uses (evm: mut Evm) {
    // Deploy with constructor arguments
    let addr = evm.create2<Counter>(value: 0, args: (5,), salt: 0)

    // The address is non-zero on success
    assert!(addr.inner != 0)
}
```

Parameters:
- `value` — Ether (in wei) to send with deployment
- `args` — Constructor arguments as a tuple (use trailing comma for single args: `(5,)`)
- `salt` — Deterministic deployment salt (use different salts to deploy multiple instances)

## Calling Contracts

Use `evm.call` to send messages to a deployed contract:

```fe
use std::abi::sol

msg CounterMsg {
    #[selector = sol("increment()")]
    Increment,

    #[selector = sol("getCount()")]
    GetCount -> u256,
}

struct CounterStore {
    count: u256,
    step: u256,
}

pub contract Counter {
    mut store: CounterStore

    init(step: u256) uses (mut store) {
        store.count = 0
        store.step = step
    }

    recv CounterMsg {
        Increment uses (mut store) {
            store.count += store.step
        }

        GetCount -> u256 uses (store) {
            store.count
        }
    }
}

#[test]
fn test_counter() uses (evm: mut Evm) {
    let addr = evm.create2<Counter>(value: 0, args: (5,), salt: 0)

    // Call with no return value
    evm.call(addr: addr, gas: 100000, value: 0, message: CounterMsg::Increment {})
    evm.call(addr: addr, gas: 100000, value: 0, message: CounterMsg::Increment {})

    // Call with return value
    let count: u256 = evm.call(
        addr: addr, gas: 100000, value: 0,
        message: CounterMsg::GetCount {},
    )
    assert!(count == 10)  // 2 increments × step of 5
}
```

Parameters for `evm.call`:
- `addr` — Contract address (from `create2`)
- `gas` — Gas limit for the call
- `value` — Ether to send (in wei)
- `message` — The message variant to send, with fields

## State Persists Across Calls

Within a single test function, all calls share the same EVM state. This means contract storage persists between calls:

```fe
//<hide>
use std::abi::sol
msg VaultMsg {
    #[selector = sol("deposit(uint256)")]
    Deposit { amount: u256 },
    #[selector = sol("getBalance()")]
    GetBalance -> u256,
}
struct VaultStore { balance: u256, deposit_count: u256 }
pub contract Vault {
    mut store: VaultStore
    init() uses (mut store) {
        store.balance = 0
        store.deposit_count = 0
    }
    recv VaultMsg {
        Deposit { amount } uses (mut store) {
            store.balance += amount
            store.deposit_count += 1
        }
        GetBalance -> u256 uses (store) { store.balance }
    }
}
//</hide>

#[test]
fn test_state_persists() uses (evm: mut Evm) {
    let addr = evm.create2<Vault>(value: 0, args: (), salt: 0)

    evm.call(addr: addr, gas: 100000, value: 0, message: VaultMsg::Deposit { amount: 100 })
    evm.call(addr: addr, gas: 100000, value: 0, message: VaultMsg::Deposit { amount: 200 })

    // State accumulated across calls
    let bal: u256 = evm.call(
        addr: addr, gas: 100000, value: 0,
        message: VaultMsg::GetBalance {},
    )
    assert!(bal == 300)
}
```

Each `#[test]` function gets a fresh EVM — tests are isolated from each other.

## Multiple Contract Instances

Use different `salt` values to deploy multiple instances of the same contract:

```fe
//<hide>
use std::abi::sol
msg CounterMsg {
    #[selector = sol("increment()")]
    Increment,
    #[selector = sol("getCount()")]
    GetCount -> u256,
}
struct CounterStore { count: u256, step: u256 }
pub contract Counter {
    mut store: CounterStore
    init(step: u256) uses (mut store) {
        store.count = 0
        store.step = step
    }
    recv CounterMsg {
        Increment uses (mut store) { store.count += store.step }
        GetCount -> u256 uses (store) { store.count }
    }
}
//</hide>

#[test]
fn test_multiple_instances() uses (evm: mut Evm) {
    // Deploy two counters with different steps
    let fast = evm.create2<Counter>(value: 0, args: (10,), salt: 0)
    let slow = evm.create2<Counter>(value: 0, args: (1,), salt: 1)

    // Increment both
    evm.call(addr: fast, gas: 100000, value: 0, message: CounterMsg::Increment {})
    evm.call(addr: slow, gas: 100000, value: 0, message: CounterMsg::Increment {})

    // They have independent state
    let fast_count: u256 = evm.call(addr: fast, gas: 100000, value: 0, message: CounterMsg::GetCount {})
    let slow_count: u256 = evm.call(addr: slow, gas: 100000, value: 0, message: CounterMsg::GetCount {})
    assert!(fast_count == 10)
    assert!(slow_count == 1)
}
```
