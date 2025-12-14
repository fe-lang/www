---
title: Receive Blocks in Contracts
description: Handling messages within contract context
---

Receive blocks inside contracts handle incoming messages and have access to the contract's storage through effects. This section focuses on how recv blocks work within the contract context.

## Recv Blocks and Contract State

In a contract, recv blocks access storage via `with` expressions:

```fe
pub struct TokenStorage {
    pub balances: StorageMap<u256, u256>,
    pub total_supply: u256,
}

msg TokenMsg {
    #[selector = 0x70a08231]
    BalanceOf { account: u256 } -> u256,

    #[selector = 0xa9059cbb]
    Transfer { to: u256, amount: u256 } -> bool,
}

contract Token {
    store: TokenStorage,

    recv TokenMsg {
        BalanceOf { account } -> u256 {
            with (TokenStorage = store) {
                TokenStorage.balances.get(account)
            }
        }

        Transfer { to, amount } -> bool {
            with (TokenStorage = store) {
                do_transfer(caller(), to, amount)
            }
        }
    }
}
```

## The with Expression

The `with` expression binds a contract field to an effect type:

```fe
with (TokenStorage = store) {
    // TokenStorage effect is available here
    TokenStorage.balances.get(account)
}
```

This pattern:
1. Takes the contract field `store`
2. Makes it available as the `TokenStorage` effect
3. Enables functions that `uses TokenStorage` to be called

## Calling Helper Functions

Handlers typically delegate to helper functions:

```fe
fn get_balance(account: u256) uses TokenStorage -> u256 {
    TokenStorage.balances.get(account)
}

fn do_transfer(from: u256, to: u256, amount: u256) uses mut TokenStorage -> bool {
    let from_bal = TokenStorage.balances.get(from)
    if from_bal < amount {
        return false
    }

    TokenStorage.balances.set(from, from_bal - amount)

    let to_bal = TokenStorage.balances.get(to)
    TokenStorage.balances.set(to, to_bal + amount)
    true
}

contract Token {
    store: TokenStorage,

    recv TokenMsg {
        BalanceOf { account } -> u256 {
            with (TokenStorage = store) {
                get_balance(account)
            }
        }

        Transfer { to, amount } -> bool {
            with (TokenStorage = store) {
                do_transfer(caller(), to, amount)
            }
        }
    }
}
```

## Multiple Storage Effects

When handlers need multiple storage types:

```fe
pub struct BalanceStorage {
    pub balances: StorageMap<u256, u256>,
}

pub struct AllowanceStorage {
    pub allowances: StorageMap<u256, StorageMap<u256, u256>>,
}

contract Token {
    balances: BalanceStorage,
    allowances: AllowanceStorage,

    recv TokenMsg {
        TransferFrom { from, to, amount } -> bool {
            with (BalanceStorage = balances, AllowanceStorage = allowances) {
                do_transfer_from(caller(), from, to, amount)
            }
        }
    }
}
```

## Complete Contract Example

A full ERC20-style token contract:

```fe
pub struct TokenStorage {
    pub balances: StorageMap<u256, u256>,
    pub allowances: StorageMap<u256, StorageMap<u256, u256>>,
    pub total_supply: u256,
}

msg Erc20 {
    #[selector = 0xa9059cbb]
    Transfer { to: u256, amount: u256 } -> bool,

    #[selector = 0x095ea7b3]
    Approve { spender: u256, amount: u256 } -> bool,

    #[selector = 0x23b872dd]
    TransferFrom { from: u256, to: u256, amount: u256 } -> bool,

    #[selector = 0x70a08231]
    BalanceOf { account: u256 } -> u256,

    #[selector = 0xdd62ed3e]
    Allowance { owner: u256, spender: u256 } -> u256,

    #[selector = 0x18160ddd]
    TotalSupply -> u256,
}

// Helper functions
fn get_balance(account: u256) uses TokenStorage -> u256 {
    TokenStorage.balances.get(account)
}

fn set_balance(account: u256, amount: u256) uses mut TokenStorage {
    TokenStorage.balances.set(account, amount)
}

fn transfer_tokens(from: u256, to: u256, amount: u256) uses mut TokenStorage -> bool {
    let from_bal = get_balance(from)
    if from_bal < amount {
        return false
    }

    set_balance(from, from_bal - amount)
    set_balance(to, get_balance(to) + amount)
    true
}

fn get_allowance(owner: u256, spender: u256) uses TokenStorage -> u256 {
    TokenStorage.allowances.get(owner).get(spender)
}

fn set_allowance(owner: u256, spender: u256, amount: u256) uses mut TokenStorage {
    TokenStorage.allowances.get(owner).set(spender, amount)
}

contract Token {
    store: TokenStorage,

    init(initial_supply: u256) {
        store.total_supply = initial_supply
        store.balances.set(caller(), initial_supply)
    }

    recv Erc20 {
        Transfer { to, amount } -> bool {
            with (TokenStorage = store) {
                transfer_tokens(caller(), to, amount)
            }
        }

        Approve { spender, amount } -> bool {
            with (TokenStorage = store) {
                set_allowance(caller(), spender, amount)
            }
            true
        }

        TransferFrom { from, to, amount } -> bool {
            with (TokenStorage = store) {
                let spender = caller()
                let allowed = get_allowance(from, spender)
                if allowed < amount {
                    return false
                }
                set_allowance(from, spender, allowed - amount)
                transfer_tokens(from, to, amount)
            }
        }

        BalanceOf { account } -> u256 {
            with (TokenStorage = store) {
                get_balance(account)
            }
        }

        Allowance { owner, spender } -> u256 {
            with (TokenStorage = store) {
                get_allowance(owner, spender)
            }
        }

        TotalSupply -> u256 {
            with (TokenStorage = store) {
                TokenStorage.total_supply
            }
        }
    }
}
```

## Handler Organization

For contracts with many handlers, organize by interface:

```fe
contract Token {
    store: TokenStorage,

    // Core ERC20 operations
    recv Erc20 {
        Transfer { to, amount } -> bool { /* ... */ }
        Approve { spender, amount } -> bool { /* ... */ }
        TransferFrom { from, to, amount } -> bool { /* ... */ }
        BalanceOf { account } -> u256 { /* ... */ }
        Allowance { owner, spender } -> u256 { /* ... */ }
        TotalSupply -> u256 { /* ... */ }
    }

    // Metadata extension
    recv Erc20Metadata {
        Name -> String { /* ... */ }
        Symbol -> String { /* ... */ }
        Decimals -> u8 { /* ... */ }
    }
}
```

## Summary

| Concept | Description |
|---------|-------------|
| `recv MsgType { }` | Recv block in contract |
| `with (Effect = field)` | Bind field to effect |
| Helper functions | Functions with `uses` clause |
| Multiple effects | `with (A = a, B = b)` |
| Organization | Separate recv blocks per interface |
