---
title: Handler Syntax
description: Pattern matching and destructuring in message handlers
---

Handlers are the functions inside recv blocks that process incoming messages. Each handler matches a specific message variant and implements its logic.

## Basic Handler Structure

A handler consists of a pattern, optional return type, and body:

```fe
VariantName { fields } -> ReturnType {
    // handler body
}
```

For handlers that don't return a value:

```fe
VariantName { fields } {
    // handler body, implicitly returns ()
}
```

## Pattern Matching

Handlers use pattern matching to destructure message fields:

### Simple Destructuring

Extract fields by their names:

```fe
recv TokenMsg {
    Transfer { to, amount } -> bool {
        // 'to' and 'amount' are available as local variables
        process_transfer(to, amount)
    }
}
```

### Renaming Fields

Give fields different local names:

```fe
recv TokenMsg {
    Transfer { to: recipient, amount: value } -> bool {
        // Use 'recipient' and 'value' instead of 'to' and 'amount'
        send_to(recipient, value)
    }
}
```

### Ignoring Fields

Use `_` to ignore specific fields:

```fe
recv TokenMsg {
    Transfer { to, amount: _ } -> bool {
        // Only use 'to', ignore the amount
        validate_recipient(to)
    }
}
```

Use `..` to ignore all remaining fields:

```fe
recv TokenMsg {
    TransferFrom { from, .. } -> bool {
        // Only use 'from', ignore 'to' and 'amount'
        check_sender(from)
    }
}
```

### No Fields

For variants without parameters, omit the braces:

```fe
recv TokenMsg {
    TotalSupply -> u256 {
        get_total_supply()
    }
}
```

## Return Types

### Explicit Returns

The return type must match the message variant's declaration:

```fe
msg Query {
    #[selector = 0x70a08231]
    BalanceOf { account: u256 } -> u256,
}

recv Query {
    BalanceOf { account } -> u256 {
        // Must return u256
        get_balance(account)
    }
}
```

### Implicit Unit Return

Handlers without a return type implicitly return `()`:

```fe
msg Commands {
    #[selector = 0x42842e0e]
    SafeTransfer { from: u256, to: u256, token_id: u256 },
}

recv Commands {
    SafeTransfer { from, to, token_id } {
        // No return type means () is returned
        do_safe_transfer(from, to, token_id)
    }
}
```

## Handler Bodies

Handler bodies contain the implementation logic. They can use all standard Fe expressions and statements.

### Simple Handlers

```fe
recv TokenMsg {
    TotalSupply -> u256 {
        1000000
    }

    BalanceOf { account } -> u256 {
        if account == 0 {
            0
        } else {
            lookup_balance(account)
        }
    }
}
```

### Early Returns

Use `return` for early exits:

```fe
recv TokenMsg {
    Transfer { to, amount } -> bool {
        if amount == 0 {
            return false
        }
        if to == 0 {
            return false
        }
        do_transfer(to, amount)
    }
}
```

### Calling Helper Functions

Handlers typically delegate to helper functions:

```fe
fn validate_transfer(to: u256, amount: u256) -> bool {
    to != 0 && amount > 0
}

fn execute_transfer(to: u256, amount: u256) uses mut TokenStorage -> bool {
    // transfer logic using storage effect
    true
}

recv TokenMsg {
    Transfer { to, amount } -> bool {
        if !validate_transfer(to, amount) {
            return false
        }
        with (TokenStorage = store) {
            execute_transfer(to, amount)
        }
    }
}
```

## Using Effects in Handlers

Handlers access contract state through effects:

```fe
pub struct TokenStorage {
    pub balances: StorageMap<u256, u256>,
    pub total_supply: u256,
}

fn get_balance(account: u256) uses TokenStorage -> u256 {
    TokenStorage.balances.get(account)
}

fn add_balance(account: u256, amount: u256) uses mut TokenStorage {
    let current = TokenStorage.balances.get(account)
    TokenStorage.balances.set(account, current + amount)
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
                add_balance(to, amount)
            }
            true
        }
    }
}
```

## Context Functions

Handlers can access transaction context using built-in functions:

```fe
recv TokenMsg {
    Transfer { to, amount } -> bool {
        let sender = caller()  // Get the message sender
        do_transfer(sender, to, amount)
    }
}
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
