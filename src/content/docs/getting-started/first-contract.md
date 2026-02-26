---
title: Your First Contract
description: Write, test, deploy, and interact with a Counter contract
---

In this tutorial you'll create a Counter contract, test it, compile it, deploy it to a local chain with [Foundry](https://book.getfoundry.sh/), and interact with it.

## Prerequisites

- **Fe** installed ([Installation](/getting-started/installation/))
- **Foundry** installed ([getfoundry.sh](https://getfoundry.sh/))

## Create a Project

Fe has a built-in project scaffolding command. Run it to create a new project called `counter`:

```bash
fe new counter
cd counter
```

This creates the following structure:

```
counter/
├── fe.toml
└── src/
    └── lib.fe
```

`fe.toml` is the project manifest. `src/lib.fe` contains a starter Counter contract.

## The Contract

Open `src/lib.fe`. You'll see the following contract:

```fe
use std::abi::sol
use std::evm::{Evm, Call}
use std::evm::effects::assert

msg CounterMsg {
    #[selector = sol("increment()")]
    Increment,
    #[selector = sol("get()")]
    Get -> u256,
}

struct CounterStore {
    value: u256,
}

pub contract Counter {
    mut store: CounterStore

    init() uses (mut store) {
        store.value = 0
    }

    recv CounterMsg {
        Increment uses (mut store) {
            store.value = store.value + 1
        }

        Get -> u256 uses (store) {
            store.value
        }
    }
}
```

Let's break this down:

- **`msg CounterMsg`** defines the contract's public interface. Each variant becomes a callable function. The `sol(...)` helper computes standard Solidity function selectors, making the contract compatible with existing Ethereum tooling.

- **`struct CounterStore`** declares the on-chain storage layout. Its fields are persisted between calls.

- **`pub contract Counter`** is the contract itself. The `mut store` field connects it to its storage.

- **`init()`** is the constructor. It runs once when the contract is deployed. The `uses (mut store)` clause explicitly declares that this function writes to storage.

- **`recv CounterMsg`** is the receive block. It routes incoming messages to handlers. `Increment` needs `mut store` because it writes; `Get` only needs `store` (read-only).

This explicit declaration of effects — what each function reads or writes — is one of Fe's defining features. Nothing is hidden.

## Run the Tests

The generated file also includes a test. Run it:

```bash
fe test
```

You should see the test pass. The test deploys the contract in a local EVM sandbox, calls `Get` (expects `0`), calls `Increment`, then calls `Get` again (expects `1`).

## Build

Compile the contract to EVM bytecode:

```bash
fe build
```

This creates an `out/` directory with the compiled artifacts:

```
out/
├── Counter.bin           # Deploy (init) bytecode
└── Counter.runtime.bin   # Runtime bytecode
```

## Deploy to a Local Chain

Start a local Ethereum node with Foundry's `anvil`:

```bash
anvil
```

Anvil prints a list of pre-funded accounts and their private keys. Keep it running and **open a second terminal**.

Deploy the Counter contract using `cast`:

```bash
cast send \
  --rpc-url http://127.0.0.1:8545 \
  --private-key 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80 \
  --create 0x$(cat out/Counter.bin)
```

:::note
The private key above is Anvil's default first account. Never use it outside of local development.
:::

In the output, look for the `contractAddress` field — that's your deployed Counter. Export it for the next steps:

```bash
export COUNTER=<the contract address from the output>
```

## Interact with the Contract

Read the current counter value:

```bash
cast call --rpc-url http://127.0.0.1:8545 $COUNTER "get()(uint256)"
```

This should return `0`.

Increment the counter:

```bash
cast send \
  --rpc-url http://127.0.0.1:8545 \
  --private-key 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80 \
  $COUNTER "increment()"
```

Read the value again:

```bash
cast call --rpc-url http://127.0.0.1:8545 $COUNTER "get()(uint256)"
```

It should now return `1`. Each `cast send` with `increment()` will increase the value by one.

## Next Steps

You've written, tested, compiled, deployed, and interacted with a Fe contract. From here:

- [Key Concepts](/getting-started/key-concepts/) — understand Fe's core ideas
- [Effects & the `uses` Clause](/effects/overview/) — learn how Fe tracks state access
- [Messages & Receive Blocks](/messages/overview/) — dig deeper into the message model
- [Examples](/examples/erc20/) — see more realistic contracts
