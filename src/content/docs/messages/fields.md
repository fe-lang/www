---
title: Message Fields
description: Parameters and types in message variants
---

Message fields define the parameters that callers pass when invoking a message variant.

## Field Syntax

Fields are defined inside curly braces, similar to struct fields:

```fe
//<hide>
msg Example {
//</hide>
    #[selector = 0xa9059cbb]
    Transfer { to: u256, amount: u256 } -> bool,
//<hide>
}
//</hide>
```

Each field has:
- A name (`to`, `amount`)
- A type (`u256`)

Multiple fields are separated by commas.

## Supported Types

Message fields support all Fe types:

### Primitive Types

```fe
msg Example {
    #[selector = 0x00000001]
    WithPrimitives {
        flag: bool,
        count: u256,
        signed_value: i128,
    },
}
```

### Compound Types

```fe
msg Example {
    #[selector = 0x00000002]
    WithTuple { coords: (u256, u256) } -> bool,

    //<hide>
    // WithStruct requires MyStruct to be defined
    //</hide>
}
```

## No Fields

Variants can have no fields:

```fe
msg Query {
    #[selector = 0x18160ddd]
    TotalSupply -> u256,

    #[selector = 0x06fdde03]
    Name -> String,
}
```

## Field Order Matters

Field order is significant for ABI encoding. The order in which fields are defined determines how calldata is decoded:

```fe
// These are different!
msg Example1 {
    #[selector = 0xa9059cbb]
    Transfer { to: u256, amount: u256 },
}

msg Example2 {
    #[selector = 0xa9059cbb]
    Transfer { amount: u256, to: u256 },
}
```

When implementing standard interfaces like ERC20, ensure field order matches the specification.

## Accessing Fields in Handlers

In recv blocks, destructure fields to access their values:

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
msg TokenMsg {
    #[selector = 0xa9059cbb]
    Transfer { to: u256, amount: u256 } -> bool,
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
msg TokenMsg {
    #[selector = 0xa9059cbb]
    Transfer { to: u256, amount: u256 } -> bool,
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
msg TokenMsg {
    #[selector = 0x23b872dd]
    TransferFrom { from: u256, to: u256, amount: u256 } -> bool,
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
