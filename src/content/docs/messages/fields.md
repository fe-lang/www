---
title: Message Fields
description: Parameters and types in message variants
---

Message fields define the parameters that callers pass when invoking a message variant.

## Field Syntax

Fields are defined inside curly braces, similar to struct fields:

```fe
//<hide>
use std::abi::sol
msg Example {
//</hide>
    #[selector = sol("transfer(address,uint256)")]
    Transfer { to: Address, amount: u256 } -> bool,
//<hide>
}
//</hide>
```

Each field has:
- A name (`to`, `amount`)
- A type (`u256`)

Multiple fields are separated by commas.

## Supported Types

Message fields must support the selected ABI. Use ABI-compatible primitives, tuples, and the standard library’s dynamic ABI types; internal types such as storage maps and pointers are not message parameters.

### Primitive Types

```fe
use std::abi::sol

msg Example {
    #[selector = sol("withPrimitives(bool,uint256,int128)")]
    WithPrimitives {
        flag: bool,
        count: u256,
        signed_value: i128,
    },
}
```

### Compound Types

```fe
use std::abi::sol

msg Example {
    #[selector = sol("withTuple((uint256,uint256))")]
    WithTuple { coords: (u256, u256) } -> bool,

    //<hide>
    // WithStruct requires MyStruct to be defined
    //</hide>
}
```

## No Fields

Variants can have no fields:

```fe
use std::abi::sol

msg Query {
    #[selector = sol("totalSupply()")]
    TotalSupply -> u256,

    #[selector = sol("name()")]
    Name -> String<31>,
}
```

## Field Order Matters

Field order is significant for ABI encoding. The order in which fields are defined determines how calldata is decoded:

```fe
//<hide>
use std::abi::sol
//</hide>
// These are different!
msg Example1 {
    #[selector = sol("transfer(address,uint256)")]
    Transfer { to: Address, amount: u256 },
}

msg Example2 {
    #[selector = sol("transfer(uint256,address)")]
    Transfer { amount: u256, to: Address },
}
```

These two signatures have different selectors. Keeping the first signature while reversing the fields is a compile error in Fe. When implementing standard interfaces like ERC20, preserve the specified types and field order.

## Accessing Fields in Handlers

In recv blocks, destructure fields to access their values:

```fe
//<hide>
use std::abi::sol
msg TokenMsg {
    #[selector = sol("transfer(address,uint256)")]
    Transfer { to: Address, amount: u256 } -> bool,
}

contract Token {
//</hide>
    recv TokenMsg {
        Transfer { to, amount } -> bool {
            // 'to' and 'amount' are available here
            true
        }
    }
//<hide>
}
//</hide>
```

You can also rename fields during destructuring:

```fe
//<hide>
use std::abi::sol
msg TokenMsg {
    #[selector = sol("transfer(address,uint256)")]
    Transfer { to: Address, amount: u256 } -> bool,
}

contract Token {
//</hide>
    recv TokenMsg {
        Transfer { to: recipient, amount: value } -> bool {
            // Use 'recipient' and 'value' instead
            true
        }
    }
//<hide>
}
//</hide>
```

## Ignoring Fields

Use `_` to ignore fields you don't need:

```fe
//<hide>
use std::abi::sol
msg TokenMsg {
    #[selector = sol("transfer(address,uint256)")]
    Transfer { to: Address, amount: u256 } -> bool,
}

contract Token {
//</hide>
    recv TokenMsg {
        Transfer { to, amount: _ } -> bool {
            // Only use 'to', ignore amount
            true
        }
    }
//<hide>
}
//</hide>
```

Use `..` to ignore remaining fields:

```fe
//<hide>
use std::abi::sol
msg TokenMsg {
    #[selector = sol("transferFrom(address,address,uint256)")]
    TransferFrom { from: Address, to: Address, amount: u256 } -> bool,
}

contract Token {
//</hide>
    recv TokenMsg {
        TransferFrom { from, .. } -> bool {
            // Only use 'from', ignore to and amount
            true
        }
    }
//<hide>
}
//</hide>
```

## Structured Parameters

Mark a struct `#[abi]` to use it as a message field or return type. The compiler derives `AbiSize`, `Encode<Sol>` and `Decode<Sol>` for it, encoding the struct like the Solidity tuple of its fields, so the selector spells it as a tuple:

```fe
use std::abi::sol

#[abi]
pub struct Position {
    pub owner: Address,
    pub amount: u256,
}

#[event]
struct Opened {
    #[indexed]
    owner: Address,
    position: Position,
}

msg PositionMsg {
    #[selector = sol("open((address,uint256))")]
    Open { position: Position } -> Position,
}

pub contract Positions uses (log: mut Log) {
    recv PositionMsg {
        Open { position } -> Position uses (mut log) {
            let doubled = Position { owner: position.owner, amount: position.amount * 2 }
            log.emit(event: Opened { owner: position.owner, position })
            doubled
        }
    }
}

#[test]
fn round_trips_abi_struct() uses (evm: mut Evm) {
    let target = evm.create2<Positions>(value: Wei::zero(), args: (), salt: 0)
    let result: Position = evm.call(
        addr: target, gas: 1000000, value: Wei::zero(),
        message: PositionMsg::Open { position: Position { owner: Address::new(7), amount: 21 } },
    )
    assert!(result.owner == Address::new(7))
    assert!(result.amount == 42)
}
```

`#[abi]` structs can be nested inside other `#[abi]` structs, used in arrays, and used as `#[event]` and `#[error]` fields. A plain struct without `#[abi]` cannot cross the message boundary; either mark it `#[abi]` or use a tuple and convert it in the handler.

## Summary

| Pattern | Meaning |
|---------|---------|
| `{ field: Type }` | Named field with type |
| `{ a, b, c }` | Multiple fields |
| (no braces) | No parameters |
| `{ field }` | Destructure keeping name |
| `{ field: name }` | Destructure with rename |
| `{ field: _ }` | Ignore specific field |
| `{ field, .. }` | Ignore remaining fields |
| `{ field: (A, B) }` | Tuple field (use instead of a struct) |
