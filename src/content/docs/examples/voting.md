---
title: Voting Contract
description: A two-choice ballot with one vote per address
---

This ballot demonstrates a mapping, an immutable deadline, caller-based authorization, and event emission. Each address can vote once for proposal `0` or `1` before the deadline. One address is not necessarily one person: this example provides no identity or eligibility system.

## Complete Example

```fe
use std::abi::sol

msg BallotMsg {
    #[selector = sol("vote(uint256)")]
    Vote { proposal: u256 },
    #[selector = sol("votes(uint256)")]
    Votes { proposal: u256 } -> u256,
}

#[event]
struct VoteCast {
    #[indexed]
    voter: Address,
    proposal: u256,
}

pub contract Ballot {
    deadline: u256,
    mut voted: StorageMap<Address, bool>,
    mut totals: StorageMap<u256, u256>,

    init(closes_at: u256) uses (ctx: Ctx, mut deadline) {
        assert!(closes_at > ctx.timestamp(), "deadline must be in future")
        deadline = closes_at
    }

    recv BallotMsg {
        Vote { proposal } uses (ctx: Ctx, log: mut Log, deadline, mut voted, mut totals) {
            assert!(ctx.timestamp() < deadline, "voting closed")
            assert!(proposal < 2, "unknown proposal")
            let voter = ctx.caller()
            assert!(!voted.get(key: voter), "already voted")
            voted.set(key: voter, value: true)
            totals.set(key: proposal, value: totals.get(key: proposal) + 1)
            log.emit(event: VoteCast { voter, proposal })
        }
        Votes { proposal } -> u256 uses totals {
            assert!(proposal < 2, "unknown proposal")
            totals.get(key: proposal)
        }
    }
}

#[test]
fn records_vote() uses (evm: mut Evm) {
    let addr = evm.create2<Ballot>(value: 0, args: (evm.timestamp() + 100,), salt: 0)
    evm.call(addr, gas: 200000, value: 0, message: BallotMsg::Vote { proposal: 1 })
    let votes: u256 = evm.call(addr, gas: 100000, value: 0, message: BallotMsg::Votes { proposal: 1 })
    assert!(votes == 1)
    let other: u256 = evm.call(addr, gas: 100000, value: 0, message: BallotMsg::Votes { proposal: 0 })
    assert!(other == 0)
}

#[test]
fn rejects_duplicate_vote() uses (evm: mut Evm) {
    let addr = evm.create2<Ballot>(value: 0, args: (evm.timestamp() + 100,), salt: 0)
    evm.call(addr, gas: 200000, value: 0, message: BallotMsg::Vote { proposal: 0 })
    let second = evm.try_call(addr, gas: 200000, value: 0, message: BallotMsg::Vote { proposal: 1 })
    assert!(!second.success())
}

#[test]
fn rejects_unknown_proposal() uses (evm: mut Evm) {
    let addr = evm.create2<Ballot>(value: 0, args: (evm.timestamp() + 100,), salt: 0)
    let outcome = evm.try_call(addr, gas: 200000, value: 0, message: BallotMsg::Vote { proposal: 2 })
    assert!(!outcome.success())
}
```

## Walkthrough

The constructor writes `deadline` once into the deployed code. The mutable maps start at their default values: `false` for participation and zero for totals. Each vote validates the deadline and proposal, marks the caller as having voted, increases the total, and emits an event. The read handler needs only `totals`.

The tests deploy the contract and exercise real message dispatch. The negative tests make only the call under test with `try_call` and check that it failed; setup goes through `evm.call`, so a failing setup step fails the test instead of counting as the expected revert. Run them with `fe test ballot.fe`. An application extending this example should test the exact deadline boundary and define eligibility, tie handling, and how the result becomes final.
