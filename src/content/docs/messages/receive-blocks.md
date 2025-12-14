---
title: Receive Blocks
description: Handling incoming messages with recv blocks
---

Receive blocks (`recv`) are where contracts handle incoming messages. They connect message definitions to their implementations.

## Named Recv Blocks

A named recv block handles all variants of a specific message type:

```fe
msg TokenMsg {
    #[selector = 0xa9059cbb]
    Transfer { to: u256, amount: u256 } -> bool,

    #[selector = 0x70a08231]
    BalanceOf { account: u256 } -> u256,
}

contract Token {
    recv TokenMsg {
        Transfer { to, amount } -> bool {
            // Handle transfer
            true
        }

        BalanceOf { account } -> u256 {
            // Return balance
            0
        }
    }
}
```

### Exhaustiveness

Named recv blocks must handle **all** variants of the message type:

```fe
contract Token {
    recv TokenMsg {
        Transfer { to, amount } -> bool {
            true
        }
        // Error: missing handler for BalanceOf
    }
}
```

The compiler ensures you don't forget any handlers.

## Bare Recv Blocks

A bare recv block handles messages without specifying a message type:

```fe
contract Example {
    recv {
        TokenMsg::Transfer { to, amount } -> bool {
            true
        }

        OtherMsg::Query { id } -> u256 {
            0
        }
    }
}
```

In bare blocks:
- Use fully qualified paths (`MsgType::Variant`)
- No exhaustiveness checking
- Can mix variants from different message types

## Recv Blocks in Contracts

Recv blocks appear inside contract definitions after fields and the init block:

```fe
contract Token {
    // Fields
    total_supply: u256,

    // Init block
    init() {
        // initialization
    }

    // Recv block
    recv TokenMsg {
        Transfer { to, amount } -> bool {
            true
        }
        // ...
    }
}
```

## Handler Structure

Each handler in a recv block has:

```fe
VariantName { fields } -> ReturnType {
    // handler body
}
```

- **Pattern**: The variant name and field destructuring
- **Return type**: Must match the message variant's return type
- **Body**: The handler implementation

## Effects in Handlers

Handlers can use effects to access contract state:

```fe
pub struct TokenStorage {
    pub balances: StorageMap<u256, u256>,
}

fn do_transfer(from: u256, to: u256, amount: u256) uses mut TokenStorage -> bool {
    let from_bal = TokenStorage.balances.get(from)
    if from_bal < amount {
        return false
    }

    let to_bal = TokenStorage.balances.get(to)
    TokenStorage.balances.set(from, from_bal - amount)
    TokenStorage.balances.set(to, to_bal + amount)
    true
}

contract Token {
    store: TokenStorage,

    recv TokenMsg {
        Transfer { to, amount } -> bool {
            // Provide storage effect and call helper
            with (TokenStorage = store) {
                do_transfer(caller(), to, amount)
            }
        }
    }
}
```

## Multiple Recv Blocks

A contract can have multiple recv blocks for different message types:

```fe
contract MultiInterface {
    recv Erc20 {
        Transfer { to, amount } -> bool { /* ... */ }
        BalanceOf { account } -> u256 { /* ... */ }
        // ...
    }

    recv Erc721 {
        OwnerOf { token_id } -> u256 { /* ... */ }
        SafeTransferFrom { from, to, token_id } { /* ... */ }
        // ...
    }
}
```

See [Multiple Message Types](/messages/multiple-types/) for details.

## When to Use Each Type

| Block Type | Use When |
|------------|----------|
| Named (`recv MsgType`) | Implementing a complete interface |
| Bare (`recv`) | Cherry-picking specific handlers |
| Multiple named | Implementing multiple interfaces |

## Summary

| Syntax | Description |
|--------|-------------|
| `recv MsgType { }` | Named block, must handle all variants |
| `recv { }` | Bare block, no exhaustiveness check |
| `Variant { } -> T { }` | Handler with return type |
| `Variant { } { }` | Handler returning `()` |
