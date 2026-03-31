---
title: Handler Syntax
description: Pattern matching and destructuring in message handlers
---

Handlers are the functions inside recv blocks that process incoming messages. Each handler matches a specific message variant and implements its logic.

## Basic Handler Structure

A handler consists of a pattern, optional return type, and body:

```fe
//<hide>
use std::abi::sol
msg Example {
    #[selector = sol("variantName(uint256)")]
    VariantName { fields: u256 } -> u256,
}
contract C {
    recv Example {
//</hide>
        VariantName { fields } -> u256 {
            // handler body
            //<hide>
            let _ = fields
            //</hide>
            0
        }
//<hide>
    }
}
//</hide>
```

For handlers that don't return a value:

```fe
//<hide>
use std::abi::sol
msg Example {
    #[selector = sol("variantName(uint256)")]
    VariantName { fields: u256 },
}
contract C {
    recv Example {
//</hide>
        VariantName { fields } {
            // handler body, implicitly returns ()
            //<hide>
            let _ = fields
            //</hide>
        }
//<hide>
    }
}
//</hide>
```

## Pattern Matching

Handlers use pattern matching to destructure message fields:

### Simple Destructuring

Extract fields by their names:

```fe
//<hide>
use std::abi::sol
msg TokenMsg {
    #[selector = sol("transfer(address,uint256)")]
    Transfer { to: u256, amount: u256 } -> bool,
}

contract Token {
//</hide>
    recv TokenMsg {
        Transfer { to, amount } -> bool {
            // 'to' and 'amount' are available as local variables
            true
        }
    }
//<hide>
}
//</hide>
```

### Renaming Fields

Give fields different local names:

```fe
//<hide>
use std::abi::sol
msg TokenMsg {
    #[selector = sol("transfer(address,uint256)")]
    Transfer { to: u256, amount: u256 } -> bool,
}

contract Token {
//</hide>
    recv TokenMsg {
        Transfer { to: recipient, amount: value } -> bool {
            // Use 'recipient' and 'value' instead of 'to' and 'amount'
            true
        }
    }
//<hide>
}
//</hide>
```

### Ignoring Fields

Use `_` to ignore specific fields:

```fe
//<hide>
use std::abi::sol
msg TokenMsg {
    #[selector = sol("transfer(address,uint256)")]
    Transfer { to: u256, amount: u256 } -> bool,
}

contract Token {
//</hide>
    recv TokenMsg {
        Transfer { to, amount: _ } -> bool {
            // Only use 'to', ignore the amount
            true
        }
    }
//<hide>
}
//</hide>
```

Use `..` to ignore all remaining fields:

```fe
//<hide>
use std::abi::sol
msg TokenMsg {
    #[selector = sol("transferFrom(address,address,uint256)")]
    TransferFrom { from: u256, to: u256, amount: u256 } -> bool,
}

contract Token {
//</hide>
    recv TokenMsg {
        TransferFrom { from, .. } -> bool {
            // Only use 'from', ignore 'to' and 'amount'
            true
        }
    }
//<hide>
}
//</hide>
```

### No Fields

For variants without parameters, omit the braces:

```fe
//<hide>
use std::abi::sol
msg TokenMsg {
    #[selector = sol("totalSupply()")]
    TotalSupply -> u256,
}

contract Token {
//</hide>
    recv TokenMsg {
        TotalSupply -> u256 {
            1000000
        }
    }
//<hide>
}
//</hide>
```

## Return Types

### Explicit Returns

The return type must match the message variant's declaration:

```fe
//<hide>
use std::abi::sol
fn get_balance(account: u256) -> u256 { account }
//</hide>

msg Query {
    #[selector = sol("balanceOf(address)")]
    BalanceOf { account: u256 } -> u256,
}

//<hide>
contract Token {
//</hide>
    recv Query {
        BalanceOf { account } -> u256 {
            // Must return u256
            get_balance(account)
        }
    }
//<hide>
}
//</hide>
```

### Implicit Unit Return

Handlers without a return type implicitly return `()`:

```fe
use std::abi::sol

msg Commands {
    #[selector = sol("safeTransferFrom(address,address,uint256)")]
    SafeTransfer { from: u256, to: u256, token_id: u256 },
}

//<hide>
contract Token {
//</hide>
    recv Commands {
        SafeTransfer { from, to, token_id } {
            // No return type means () is returned
        }
    }
//<hide>
}
//</hide>
```

## Handler Bodies

Handler bodies contain the implementation logic. They can use all standard Fe expressions and statements.

### Simple Handlers

```fe
//<hide>
use std::abi::sol
msg TokenMsg {
    #[selector = sol("totalSupply()")]
    TotalSupply -> u256,
    #[selector = sol("balanceOf(address)")]
    BalanceOf { account: u256 } -> u256,
}

contract Token {
//</hide>
    recv TokenMsg {
        TotalSupply -> u256 {
            1000000
        }

        BalanceOf { account } -> u256 {
            if account == 0 {
                0
            } else {
                100
            }
        }
    }
//<hide>
}
//</hide>
```

### Early Returns

Use `return` for early exits:

```fe
//<hide>
use std::abi::sol
msg TokenMsg {
    #[selector = sol("transfer(address,uint256)")]
    Transfer { to: u256, amount: u256 } -> bool,
}

contract Token {
//</hide>
    recv TokenMsg {
        Transfer { to, amount } -> bool {
            if amount == 0 {
                return false
            }
            if to == 0 {
                return false
            }
            true
        }
    }
//<hide>
}
//</hide>
```

### Calling Helper Functions

Handlers typically delegate to helper functions:

```fe
//<hide>
use std::abi::sol
msg TokenMsg {
    #[selector = sol("transfer(address,uint256)")]
    Transfer { to: u256, amount: u256 } -> bool,
}
//</hide>

pub struct TokenStorage {}

// Pure validation — no storage needed, stays standalone
fn validate_transfer(to: u256, amount: u256) -> bool {
    to != 0 && amount > 0
}

impl TokenStorage {
    fn execute_transfer(mut self, to: u256, amount: u256) -> bool {
        //<hide>
        let _ = to
        let _ = amount
        //</hide>
        true
    }
}

//<hide>
contract Token {
    mut store: TokenStorage,
//</hide>
    recv TokenMsg {
        Transfer { to, amount } -> bool uses (mut store) {
            if !validate_transfer(to, amount) {
                return false
            }
            store.execute_transfer(to, amount)
        }
    }
//<hide>
}
//</hide>
```

## Using Effects in Handlers

Handlers access contract state through effects:

```fe
//<hide>
use std::abi::sol
msg TokenMsg {
    #[selector = sol("balanceOf(address)")]
    BalanceOf { account: u256 } -> u256,
    #[selector = sol("transfer(address,uint256)")]
    Transfer { to: u256, amount: u256 } -> bool,
}
//</hide>

pub struct TokenStorage {
    pub balances: StorageMap<u256, u256>,
    pub total_supply: u256,
}

impl TokenStorage {
    fn get_balance(self, account: u256) -> u256 {
        self.balances.get(account)
    }

    fn add_balance(mut self, account: u256, amount: u256) {
        let current = self.balances.get(account)
        self.balances.set(key: account, value: current + amount)
    }
}

contract Token {
    mut store: TokenStorage,

    recv TokenMsg {
        BalanceOf { account } -> u256 uses (store) {
            store.get_balance(account)
        }

        Transfer { to, amount } -> bool uses (mut store) {
            store.add_balance(account: to, amount)
            true
        }
    }
}
```

## Context Functions

Handlers can access transaction context using built-in functions:

```fe
//<hide>
use std::abi::sol
use _boilerplate::caller
fn do_transfer(from: u256, to: u256, amount: u256) -> bool {
    let _ = (from, to, amount)
    true
}
msg TokenMsg {
    #[selector = sol("transfer(address,uint256)")]
    Transfer { to: u256, amount: u256 } -> bool,
}
contract Token {
//</hide>
    recv TokenMsg {
        Transfer { to, amount } -> bool {
            let sender = caller()  // Get the message sender
            do_transfer(from: sender, to, amount)
        }
    }
//<hide>
}
//</hide>
```

Common context functions:
- `caller()` - The address that called this contract
- `self_address()` - The contract's own address
- `block_number()` - Current block number
- `block_timestamp()` - Current block timestamp

## Summary

| Pattern | Description |
|---------|-------------|
| `{ field }` | Extract field with same name |
| `{ field: name }` | Extract field with new name |
| `{ field: _ }` | Ignore specific field |
| `{ .., field }` | Extract one, ignore rest |
| `-> Type { }` | Handler with return type |
| `{ }` | Handler returning `()` |
