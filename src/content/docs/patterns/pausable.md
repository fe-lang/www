---
title: Pausable Contracts
description: Controlling selected operations with an emergency pause
---

A pause flag lets an authorized account temporarily disable selected operations. Each protected handler must check the flag; declaring a flag alone does not affect dispatch.

## A Pausable Counter

This contract allows its owner to pause increments while keeping reads available. The owner is immutable; the flag and count use mutable storage.

```fe
use std::abi::sol

msg CounterMsg {
    #[selector = sol("setPaused(bool)")]
    SetPaused { value: bool },
    #[selector = sol("increment()")]
    Increment,
    #[selector = sol("count()")]
    Count -> u256,
}

pub contract PausableCounter {
    owner: Address,
    mut paused: bool,
    mut count: u256,

    init(admin: Address) uses (mut owner) {
        assert!(admin != Address::zero(), "zero owner")
        owner = admin
    }

    recv CounterMsg {
        SetPaused { value } uses (ctx: Ctx, owner, mut paused) {
            assert!(ctx.caller() == owner, "not owner")
            paused = value
        }
        Increment uses (paused, mut count) {
            assert!(!paused, "contract paused")
            count += 1
        }
        Count -> u256 uses count { count }
    }
}

#[test]
fn increments_when_active() uses (evm: mut Evm) {
    let addr = evm.create2<PausableCounter>(value: 0, args: (evm.address(),), salt: 0)
    evm.call(addr, gas: 100000, value: 0, message: CounterMsg::Increment {})
    let count: u256 = evm.call(addr, gas: 100000, value: 0, message: CounterMsg::Count {})
    assert!(count == 1)
    evm.call(addr, gas: 100000, value: 0, message: CounterMsg::SetPaused { value: true })
    evm.call(addr, gas: 100000, value: 0, message: CounterMsg::SetPaused { value: false })
    evm.call(addr, gas: 100000, value: 0, message: CounterMsg::Increment {})
}

#[test(should_revert)]
fn rejects_increment_while_paused() uses (evm: mut Evm) {
    let addr = evm.create2<PausableCounter>(value: 0, args: (evm.address(),), salt: 0)
    evm.call(addr, gas: 100000, value: 0, message: CounterMsg::SetPaused { value: true })
    evm.call(addr, gas: 100000, value: 0, message: CounterMsg::Increment {})
}

#[test(should_revert)]
fn rejects_unauthorized_pause() uses (evm: mut Evm) {
    let addr = evm.create2<PausableCounter>(value: 0, args: (Address { inner: 1 },), salt: 0)
    evm.call(addr, gas: 100000, value: 0, message: CounterMsg::SetPaused { value: true })
}
```

## Choosing the Scope

Decide explicitly whether pausing blocks transfers, minting, deposits, withdrawals, or all writes. Keeping a recovery or withdrawal path available may be necessary for your application. Emit pause/unpause events in a user-facing protocol so operators can monitor state changes.

The authority able to pause must also have a way to unpause. Document that trust assumption and test every protected entry point, including alternate message groups that share the same state.
