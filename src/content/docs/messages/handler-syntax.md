---
title: Handler Syntax
description: Pattern matching and destructuring in message handlers
---

Handlers are the functions inside recv blocks that process incoming messages. Each handler matches a specific message variant and implements its logic.

## Basic Handler Structure

A handler consists of a pattern, optional return type, and body:

```fe
//<hide>
msg Example {
    #[selector = 0x12345678]
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
msg Example {
    #[selector = 0x12345678]
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
msg TokenMsg {
    #[selector = 0xa9059cbb]
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
msg TokenMsg {
    #[selector = 0xa9059cbb]
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
msg TokenMsg {
    #[selector = 0xa9059cbb]
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
msg TokenMsg {
    #[selector = 0x23b872dd]
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
msg TokenMsg {
    #[selector = 0x18160ddd]
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
fn get_balance(account: u256) -> u256 { account }
//</hide>

msg Query {
    #[selector = 0x70a08231]
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
msg Commands {
    #[selector = 0x42842e0e]
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
msg TokenMsg {
    #[selector = 0x18160ddd]
    TotalSupply -> u256,
    #[selector = 0x70a08231]
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
msg TokenMsg {
    #[selector = 0xa9059cbb]
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
pub struct TokenStorage {}
msg TokenMsg {
    #[selector = 0xa9059cbb]
    Transfer { to: u256, amount: u256 } -> bool,
}
//</hide>

fn validate_transfer(to: u256, amount: u256) -> bool {
    to != 0 && amount > 0
}

fn execute_transfer(to: u256, amount: u256) -> bool uses (mut store: TokenStorage) {
    // transfer logic using storage effect
    //<hide>
    let _ = store
    //</hide>
    true
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
            execute_transfer(to, amount)
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
use _boilerplate::Map
msg TokenMsg {
    #[selector = 0x70a08231]
    BalanceOf { account: u256 } -> u256,
    #[selector = 0xa9059cbb]
    Transfer { to: u256, amount: u256 } -> bool,
}
//</hide>

pub struct TokenStorage {
    pub balances: Map<u256, u256>,
    pub total_supply: u256,
}

fn get_balance(account: u256) -> u256 uses (store: TokenStorage) {
    store.balances.get(account)
}

fn add_balance(account: u256, amount: u256) uses (mut store: TokenStorage) {
    let current = store.balances.get(account)
    store.balances.set(account, current + amount)
}

contract Token {
    mut store: TokenStorage,

    recv TokenMsg {
        BalanceOf { account } -> u256 uses (store) {
            get_balance(account)
        }

        Transfer { to, amount } -> bool uses (mut store) {
            add_balance(to, amount)
            true
        }
    }
}
```

## Context Functions

Handlers can access transaction context using built-in functions:

```fe
//<hide>
use _boilerplate::caller
fn do_transfer(from: u256, to: u256, amount: u256) -> bool {
    let _ = (from, to, amount)
    true
}
msg TokenMsg {
    #[selector = 0xa9059cbb]
    Transfer { to: u256, amount: u256 } -> bool,
}
contract Token {
//</hide>
    recv TokenMsg {
        Transfer { to, amount } -> bool {
            let sender = caller()  // Get the message sender
            do_transfer(sender, to, amount)
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
