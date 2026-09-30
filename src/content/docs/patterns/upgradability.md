---
title: Upgradability
description: Migration and proxy design considerations
---

Deployed EVM code cannot be edited in place. Upgrading means either deploying a replacement and moving users/state to it, or designing an indirection mechanism before deployment.

## Redeployment and Migration

For a small application, a new deployment with explicit migration is often easiest to reason about. Define which data can be reconstructed from events, which balances or permissions must be transferred, who authorizes migration, and when the old contract stops accepting writes. Publish the new address and test the transition with realistic state.

## Proxy-Based Upgrades

An EVM proxy can delegate execution to another address while retaining the proxy's storage and call context. This is a low-level design: Fe's ordinary typed contract calls are not a proxy-upgrade mechanism. The `Call` effect does provide the delegatecall primitives: `raw_delegatecall(addr, gas, args, ret)` forwards raw calldata into a caller-supplied buffer and returns a `RawCallOutcome`, and `try_delegate(addr, gas, message)` encodes a typed message and returns a `CallOutcome`. Neither bubbles a failure; check the outcome. A proxy needs implementation selection, upgrade authorization, calldata/returndata forwarding, and a carefully specified storage layout.

A constructor runs for the implementation deployment, not as an initializer for the proxy's state. Code-backed immutable fields belong to the implementation code. Mutable storage must be initialized through a separately guarded path when executing through the proxy.

## Storage Compatibility

Do not assume that reordering, adding, or changing Fe fields preserves an existing deployment's layout. Maps use layout parameters as well as ordinary storage slots; changes to nested structs and inferred parameters can affect where values are stored. Fe 26.3 fixed layout collisions involving repeated inferred layout parameters, which makes review especially important when comparing artifacts from older compilers.

Inspect compiler layout information, pin compiler versions, and test an upgrade against populated old state. Verify balances, allowances, ownership, pause flags, and any nested maps after the transition. Matching ABI signatures is insufficient to establish storage compatibility.

This guide does not provide a validated upgradeable proxy implementation. Until you have a reviewed forwarding mechanism and demonstrated layout compatibility for your contracts, use this section as design guidance rather than a deployable recipe. See [Contract Storage](/contracts/storage/) and [Storage Structs](/structs/storage-structs/) for the underlying field model.

## Minimal Clones

`std::evm::clones` deploys ERC-1167 minimal proxies with a fixed implementation address. They share implementation code but have separate storage. Their implementation address cannot be upgraded through these helpers.

```fe
use std::abi::sol
use std::evm::{clones, Create, RawMem}

msg CloneQuery {
    #[selector = sol("answer()")]
    Answer -> u256,
}

pub contract Implementation {
    recv CloneQuery {
        Answer -> u256 { 42 }
    }
}

#[test]
fn deploys_predicted_clone() uses (evm: mut Evm, create: mut Create, mem: mut RawMem) {
    let implementation = evm.create2<Implementation>(value: 0, args: (), salt: 0)
    let predicted = clones::predict_deterministic_address(
        implementation, salt: 7, deployer: evm.address(),
    )
    let proxy = clones::clone_deterministic(implementation, salt: 7, value: 0)
    assert!(proxy == predicted)
    let answer: u256 = evm.call(
        addr: proxy, gas: 1000000, value: 0, message: CloneQuery::Answer {},
    )
    assert!(answer == 42)
}
```

`clone` uses CREATE; `clone_deterministic` uses CREATE2 and rejects an occupied address. The helpers do not validate implementation code or initialize clone storage. If initialization is needed, perform it atomically through a guarded initializer.

A clone never runs the implementation's Fe `init`, which affects the two kinds of fields differently:

- Immutable (non-`mut`) fields are stored in the implementation's deployed code, so every clone reads the values written when the *implementation* was deployed. They cannot differ per clone.
- `mut` fields live in each clone's own storage and start zeroed, even if the implementation's `init` set them. `clone_initcode` exposes the standard 55-byte creation code.
