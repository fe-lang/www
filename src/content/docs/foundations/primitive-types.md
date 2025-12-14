---
title: Primitive Types
description: Boolean, integers (u8..u256, i8..i256), and String types in Fe
---

Fe provides a set of primitive types that form the foundation for all data manipulation. These types are built into the language and are always available without imports.

## Boolean

The `bool` type represents a logical value that can be either `true` or `false`.

```fe ignore
let is_active: bool = true
let has_permission: bool = false
```

Booleans are commonly used in conditional expressions and control flow:

```fe ignore
if is_active {
    // do something
}

let result = is_active && has_permission
```

## Integer Types

Fe provides both signed and unsigned integers in various sizes. The number in the type name indicates the bit width.

### Unsigned Integers

Unsigned integers can only represent non-negative values (zero and positive numbers).

| Type    | Bits | Minimum | Maximum |
|---------|------|---------|---------|
| `u8`    | 8    | 0       | 255 |
| `u16`   | 16   | 0       | 65,535 |
| `u32`   | 32   | 0       | 4,294,967,295 |
| `u64`   | 64   | 0       | 18,446,744,073,709,551,615 |
| `u128`  | 128  | 0       | 2¹²⁸ - 1 |
| `u256`  | 256  | 0       | 2²⁵⁶ - 1 |
| `usize` | *    | 0       | platform-dependent |

```fe ignore
let small: u8 = 255
let balance: u256 = 1000000000000000000  // 1 ETH in wei
let count: u32 = 42
```

### Signed Integers

Signed integers can represent both negative and positive values, using two's complement representation.

| Type    | Bits | Minimum | Maximum |
|---------|------|---------|---------|
| `i8`    | 8    | -128    | 127 |
| `i16`   | 16   | -32,768 | 32,767 |
| `i32`   | 32   | -2,147,483,648 | 2,147,483,647 |
| `i64`   | 64   | -2⁶³    | 2⁶³ - 1 |
| `i128`  | 128  | -2¹²⁷   | 2¹²⁷ - 1 |
| `i256`  | 256  | -2²⁵⁵   | 2²⁵⁵ - 1 |
| `isize` | *    | platform-dependent | platform-dependent |

```fe ignore
let temperature: i32 = -10
let offset: i256 = -500
```

### EVM Considerations

The Ethereum Virtual Machine (EVM) natively operates on 256-bit words. This means:

- **`u256` and `i256`** are the most gas-efficient types for most operations, as they match the EVM's native word size
- Smaller types like `u8` or `u32` may require additional masking operations, potentially using more gas
- Use smaller types when storage packing is important or when interfacing with external systems that expect specific sizes

For most smart contract development, prefer `u256` for unsigned values and `i256` for signed values unless you have a specific reason to use smaller types.

```fe ignore
// Recommended for most EVM operations
let amount: u256 = 1000
let price: u256 = 500

// Use smaller types when needed for storage packing or external interfaces
let percentage: u8 = 100
```

## Numeric Literals

Fe supports several formats for writing numeric literals:

### Decimal

Standard base-10 numbers:

```fe ignore
let x = 42
let large = 1000000
```

### Underscores for Readability

Use underscores to make large numbers more readable. Underscores are ignored by the compiler:

```fe ignore
let wei_per_eth = 1_000_000_000_000_000_000
let million = 1_000_000
```

### Hexadecimal

Prefix with `0x` or `0X` for base-16 numbers. Useful for addresses, hashes, and bit patterns:

```fe ignore
let color = 0xff5733
let mask = 0xFFFFFFFF
let address_value = 0x742d35Cc6634C0532925a3b844Bc9e7595f5e123
```

### Binary

Prefix with `0b` or `0B` for base-2 numbers. Useful for bit flags and masks:

```fe ignore
let flags = 0b1010
let permission_mask = 0b11110000
```

### Octal

Prefix with `0o` or `0O` for base-8 numbers:

```fe ignore
let file_mode = 0o755
let octal_value = 0o177
```

## String

The `String` type represents text data.

```fe ignore
let greeting: String = "Hello, Fe!"
let empty: String = ""
```

String literals are enclosed in double quotes. Escape sequences can be used for special characters:

```fe ignore
let with_newline = "Line 1\nLine 2"
let with_quote = "She said \"Hello\""
```

## Type Inference

Fe can often infer types from context, so explicit type annotations aren't always required:

```fe ignore
let x = 42          // inferred as integer type
let flag = true     // inferred as bool
let name = "Alice"  // inferred as String
```

However, explicit type annotations are recommended when the intended type isn't obvious or when you need a specific integer size:

```fe ignore
let amount: u256 = 100  // explicitly u256, not inferred default
let small: u8 = 50      // explicitly u8 for storage efficiency
```

## EVM Types (Planned)

Fe's primitive types cover the fundamentals, but EVM-specific types like `Address` and other Solidity-compatibility types are planned for the standard library (`std`). These types have not yet been implemented.

Currently, EVM addresses are represented as `u256` values:

```fe ignore
use core::intrinsic::caller

fn get_sender() -> u256 {
    caller()  // returns the sender's address as u256
}
```

Future versions of Fe will provide dedicated types in `std` for better type safety and ergonomics when working with EVM-specific data.
