---
title: Multiple Message Types
description: Implementing several interfaces in one contract
---

Contracts often need to implement multiple interfaces—for example, an NFT marketplace might implement ERC721, ERC2981 (royalties), and custom trading functions. Fe supports this through multiple recv blocks.

## Multiple Recv Blocks

A contract can have multiple recv blocks, each handling a different message type:

```fe ignore
msg Erc20 {
    #[selector = 0xa9059cbb]
    Transfer { to: u256, amount: u256 } -> bool,

    #[selector = 0x70a08231]
    BalanceOf { account: u256 } -> u256,

    #[selector = 0x18160ddd]
    TotalSupply -> u256,
}

msg Erc20Metadata {
    #[selector = 0x06fdde03]
    Name -> String,

    #[selector = 0x95d89b41]
    Symbol -> String,

    #[selector = 0x313ce567]
    Decimals -> u8,
}

contract Token {
    store: TokenStorage,

    recv Erc20 {
        Transfer { to, amount } -> bool {
            with (TokenStorage = store) {
                do_transfer(caller(), to, amount)
            }
        }

        BalanceOf { account } -> u256 {
            with (TokenStorage = store) {
                get_balance(account)
            }
        }

        TotalSupply -> u256 {
            with (TokenStorage = store) {
                TokenStorage.total_supply
            }
        }
    }

    recv Erc20Metadata {
        Name -> String {
            "MyToken"
        }

        Symbol -> String {
            "MTK"
        }

        Decimals -> u8 {
            18
        }
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

```fe ignore
pub struct TokenStorage {
    pub balances: StorageMap<u256, u256>,
    pub allowances: StorageMap<u256, StorageMap<u256, u256>>,
    pub total_supply: u256,
}

contract Token {
    store: TokenStorage,

    // Core token operations
    recv Erc20 {
        Transfer { to, amount } -> bool {
            with (TokenStorage = store) {
                do_transfer(caller(), to, amount)
            }
        }

        BalanceOf { account } -> u256 {
            with (TokenStorage = store) {
                TokenStorage.balances.get(account)
            }
        }
        // ...
    }

    // Permit extension (ERC2612)
    recv Erc2612 {
        Permit { owner, spender, value, deadline, v, r, s } {
            with (TokenStorage = store) {
                verify_and_set_allowance(owner, spender, value, deadline, v, r, s)
            }
        }
        // ...
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
fn transfer_tokens(from: u256, to: u256, amount: u256) uses mut TokenStorage -> bool {
    // ...
}

fn update_allowance(owner: u256, spender: u256, amount: u256) uses mut TokenStorage {
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
