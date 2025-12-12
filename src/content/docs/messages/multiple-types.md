---
title: Multiple Message Types
description: Implementing several interfaces in one contract
---

Contracts often need to implement multiple interfaces. For example, an NFT marketplace might implement ERC721, ERC2981 (royalties), and custom trading functions. Fe supports this through multiple recv blocks.

## Multiple Recv Blocks

A contract can have multiple recv blocks, each handling a different message type:

```fe
//<hide>
use core::StorageMap

pub struct TokenStorage {
    pub balances: StorageMap<u256, u256>,
    pub total_supply: u256,
}

pub struct Ctx {}
impl Ctx {
    pub fn caller(self) -> u256 { todo() }
}

fn do_transfer(from: u256, to: u256, amount: u256) -> bool uses (mut store: TokenStorage) {
    let bal = store.balances.get(from)
    if bal < amount { return false }
    store.balances.set(from, bal - amount)
    store.balances.set(to, store.balances.get(to) + amount)
    true
}

fn get_balance(account: u256) -> u256 uses (store: TokenStorage) {
    store.balances.get(account)
}
//</hide>

msg Erc20 {
    #[selector = 0xa9059cbb]
    Transfer { to: u256, amount: u256 } -> bool,

    #[selector = 0x70a08231]
    BalanceOf { account: u256 } -> u256,

    #[selector = 0x18160ddd]
    TotalSupply {} -> u256,
}

msg Erc20Metadata {
    #[selector = 0x06fdde03]
    Name {} -> String<32>,

    #[selector = 0x95d89b41]
    Symbol {} -> String<8>,

    #[selector = 0x313ce567]
    Decimals {} -> u8,
}

contract Token {
    mut store: TokenStorage,

    recv Erc20 {
        Transfer { to, amount } -> bool uses (ctx: Ctx, mut store) {
            do_transfer(ctx.caller(), to, amount)
        }

        BalanceOf { account } -> u256 uses store {
            get_balance(account)
        }

        TotalSupply {} -> u256 uses store {
            store.total_supply
        }
    }

    recv Erc20Metadata {
        Name {} -> String<32> { "MyToken" }
        Symbol {} -> String<8> { "MTK" }
        Decimals {} -> u8 { 18 }
    }
}
```

## Selector Uniqueness

Selectors must be unique across **all** recv blocks in a contract. The compiler will error if two variants share a selector:

```fe ignore
msg InterfaceA {
    #[selector = 0x12345678]
    Operation { } -> bool,
}

msg InterfaceB {
    #[selector = 0x12345678]  // Same selector!
    DifferentOp { } -> bool,
}

contract Example {
    recv InterfaceA {
        Operation { } -> bool { true }
    }

    recv InterfaceB {
        DifferentOp { } -> bool { true }
        // Error: duplicate selector 0x12345678
    }
}
```

This ensures the contract can unambiguously route incoming calls.

## Shared State

Multiple recv blocks can share the same contract state:

```fe
//<hide>
use core::StorageMap

pub struct Ctx {}
impl Ctx {
    pub fn caller(self) -> u256 { todo() }
}

fn do_transfer(from: u256, to: u256, amount: u256) -> bool uses (mut store: TokenStorage) {
    let bal = store.balances.get(from)
    if bal < amount { return false }
    store.balances.set(from, bal - amount)
    store.balances.set(to, store.balances.get(to) + amount)
    true
}

msg Erc20 {
    #[selector = 0xa9059cbb]
    Transfer { to: u256, amount: u256 } -> bool,
    #[selector = 0x70a08231]
    BalanceOf { account: u256 } -> u256,
}

msg Erc2612 {
    #[selector = 0xd505accf]
    Permit { owner: u256, spender: u256, value: u256, deadline: u256, v: u8, r: u256, s: u256 } -> bool,
}
//</hide>

pub struct TokenStorage {
    pub balances: StorageMap<u256, u256>,
    pub total_supply: u256,
}

contract Token {
    mut store: TokenStorage,

    // Core token operations
    recv Erc20 {
        Transfer { to, amount } -> bool uses (ctx: Ctx, mut store) {
            do_transfer(ctx.caller(), to, amount)
        }

        BalanceOf { account } -> u256 uses store {
            store.balances.get(account)
        }
    }

    // Permit extension (ERC2612) - shares same store
    recv Erc2612 {
        Permit { owner, spender, value, deadline, v, r, s } -> bool uses (mut store) {
            // Both recv blocks access the same store field
            let _ = (owner, spender, value, deadline, v, r, s)
            true
        }
    }
}
```

## Combining Named and Bare Blocks

You can mix named recv blocks with a bare recv block:

```fe ignore
contract Hybrid {
    // Named block: implements full ERC20 interface
    recv Erc20 {
        Transfer { to, amount } -> bool { /* ... */ }
        BalanceOf { account } -> u256 { /* ... */ }
        TotalSupply -> u256 { /* ... */ }
        // ... all variants required
    }

    // Bare block: cherry-pick specific handlers
    recv {
        // Custom operations not part of a standard
        CustomMsg::SetFee { fee } {
            set_protocol_fee(fee)
        }

        AdminMsg::Pause { } {
            pause_contract()
        }
    }
}
```

## Common Multi-Interface Patterns

### ERC721 + Metadata + Enumerable

```fe ignore
contract NFT {
    recv Erc721 {
        OwnerOf { token_id } -> u256 { /* ... */ }
        SafeTransferFrom { from, to, token_id } { /* ... */ }
        TransferFrom { from, to, token_id } { /* ... */ }
        Approve { to, token_id } { /* ... */ }
        SetApprovalForAll { operator, approved } { /* ... */ }
        GetApproved { token_id } -> u256 { /* ... */ }
        IsApprovedForAll { owner, operator } -> bool { /* ... */ }
        BalanceOf { owner } -> u256 { /* ... */ }
    }

    recv Erc721Metadata {
        Name -> String { /* ... */ }
        Symbol -> String { /* ... */ }
        TokenURI { token_id } -> String { /* ... */ }
    }

    recv Erc721Enumerable {
        TotalSupply -> u256 { /* ... */ }
        TokenOfOwnerByIndex { owner, index } -> u256 { /* ... */ }
        TokenByIndex { index } -> u256 { /* ... */ }
    }
}
```

### Token + Governance

```fe ignore
contract GovernanceToken {
    recv Erc20 {
        // Standard token operations
        Transfer { to, amount } -> bool { /* ... */ }
        // ...
    }

    recv Erc20Votes {
        // Voting power delegation
        Delegate { delegatee } { /* ... */ }
        GetVotes { account } -> u256 { /* ... */ }
        GetPastVotes { account, block_number } -> u256 { /* ... */ }
        // ...
    }
}
```

## Organizing Large Contracts

For contracts with many message types, consider organizing handlers logically:

```fe ignore
// Group related helper functions
fn transfer_tokens(from: u256, to: u256, amount: u256) -> bool uses (mut store: TokenStorage) {
    // ...
}

fn update_allowance(owner: u256, spender: u256, amount: u256) uses (mut store: TokenStorage) {
    // ...
}

// Group related message handlers
contract Token {
    store: TokenStorage,

    // Core transfers
    recv Erc20Core {
        Transfer { to, amount } -> bool { /* delegates to helpers */ }
        TransferFrom { from, to, amount } -> bool { /* delegates to helpers */ }
    }

    // Allowance management
    recv Erc20Allowance {
        Approve { spender, amount } -> bool { /* delegates to helpers */ }
        Allowance { owner, spender } -> u256 { /* delegates to helpers */ }
    }

    // Read-only queries
    recv Erc20Query {
        BalanceOf { account } -> u256 { /* ... */ }
        TotalSupply -> u256 { /* ... */ }
    }
}
```

## Summary

| Concept | Description |
|---------|-------------|
| Multiple recv blocks | Handle different message types in one contract |
| Selector uniqueness | Selectors must be unique across all recv blocks |
| Shared state | All recv blocks access the same contract fields |
| Mixed blocks | Combine named and bare recv blocks as needed |
