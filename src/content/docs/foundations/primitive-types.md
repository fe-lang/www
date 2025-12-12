---
title: Primitive Types
description: Boolean, integers (u8..u256, i8..i256), and String types in Fe
---

Fe provides a set of primitive types that form the foundation for all data manipulation. These types are built into the language and are always available without imports.

## Boolean

The `bool` type represents a logical value that can be either `true` or `false`.

```fe
//<hide>
fn example() {
//</hide>
let is_active: bool = true
let has_permission: bool = false
//<hide>
let _ = (is_active, has_permission)
}
//</hide>
```

Booleans are commonly used in conditional expressions and control flow:

```fe
//<hide>
fn example() {
let is_active: bool = true
let has_permission: bool = false
//</hide>
if is_active {
    // do something
}

let result = is_active && has_permission
//<hide>
let _ = result
}
//</hide>
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

```fe
//<hide>
fn example() {
//</hide>
let small: u8 = 255
let balance: u256 = 1000000000000000000  // 1 ETH in wei
let count: u32 = 42
//<hide>
let _ = (small, balance, count)
}
//</hide>
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

```fe
//<hide>
fn example() {
//</hide>
let temperature: i32 = -10
let offset: i256 = -500
//<hide>
let _ = (temperature, offset)
}
//</hide>
```

### EVM Considerations

The Ethereum Virtual Machine (EVM) natively operates on 256-bit words. This means:

- **`u256` and `i256`** are the most gas-efficient types for most operations, as they match the EVM's native word size
- Smaller types like `u8` or `u32` may require additional masking operations, potentially using more gas
- Use smaller types when storage packing is important or when interfacing with external systems that expect specific sizes

For most smart contract development, prefer `u256` for unsigned values and `i256` for signed values unless you have a specific reason to use smaller types.

```fe
//<hide>
fn example() {
//</hide>
// Recommended for most EVM operations
let amount: u256 = 1000
let price: u256 = 500

// Use smaller types when needed for storage packing or external interfaces
let percentage: u8 = 100
//<hide>
let _ = (amount, price, percentage)
}
//</hide>
```

## Numeric Literals

Fe supports several formats for writing numeric literals:

### Decimal

Standard base-10 numbers:

```fe
//<hide>
fn example() {
//</hide>
let x: u256 = 42
let large: u256 = 1000000
//<hide>
let _ = (x, large)
}
//</hide>
```

### Underscores for Readability

Use underscores to make large numbers more readable. Underscores are ignored by the compiler:

```fe
//<hide>
fn example() {
//</hide>
let wei_per_eth: u256 = 1_000_000_000_000_000_000
let million: u256 = 1_000_000
//<hide>
let _ = (wei_per_eth, million)
}
//</hide>
```

### Hexadecimal

Prefix with `0x` or `0X` for base-16 numbers. Useful for addresses, hashes, and bit patterns:

```fe
//<hide>
fn example() {
//</hide>
let color: u256 = 0xff5733
let mask: u256 = 0xFFFFFFFF
let address_value: u256 = 0x742d35Cc6634C0532925a3b844Bc9e7595f5e123
//<hide>
let _ = (color, mask, address_value)
}
//</hide>
```

### Binary

Prefix with `0b` or `0B` for base-2 numbers. Useful for bit flags and masks:

```fe
//<hide>
fn example() {
//</hide>
let flags: u8 = 0b1010
let permission_mask: u8 = 0b11110000
//<hide>
let _ = (flags, permission_mask)
}
//</hide>
```

### Octal

Prefix with `0o` or `0O` for base-8 numbers:

```fe
//<hide>
fn example() {
//</hide>
let file_mode: u16 = 0o755
let octal_value: u16 = 0o177
//<hide>
let _ = (file_mode, octal_value)
}
//</hide>
```

## String

The `String` type represents text data.

```fe
//<hide>
fn example() {
//</hide>
let greeting = "Hello, Fe!"
let empty = ""
//<hide>
let _ = (greeting, empty)
}
//</hide>
```

String literals are enclosed in double quotes. Escape sequences can be used for special characters:

```fe
//<hide>
fn example() {
//</hide>
let with_newline = "Line 1\nLine 2"
let with_quote = "She said \"Hello\""
//<hide>
let _ = (with_newline, with_quote)
}
//</hide>
```

## Type Inference

Fe can often infer types from context, so explicit type annotations aren't always required:

```fe
//<hide>
fn example() {
//</hide>
let x: u256 = 42    // type annotation required for integers
let flag = true     // inferred as bool
let name = "Alice"  // inferred as String<5>
//<hide>
let _ = (x, flag, name)
}
//</hide>
```

However, explicit type annotations are recommended when the intended type isn't obvious or when you need a specific integer size:

```fe
//<hide>
fn example() {
//</hide>
let amount: u256 = 100  // explicitly u256, not inferred default
let small: u8 = 50      // explicitly u8 for storage efficiency
//<hide>
let _ = (amount, small)
}
//</hide>
```

## EVM Types (Planned)

Fe's primitive types cover the fundamentals, but EVM-specific types like `Address` and other Solidity-compatibility types are planned for the standard library (`std`). These types have not yet been implemented.

Currently, EVM addresses are represented as `u256` values:

```fe
use core::intrinsic::caller

fn get_sender() -> u256 {
    caller()  // returns the sender's address as u256
}
```

Future versions of Fe will provide dedicated types in `std` for better type safety and ergonomics when working with EVM-specific data.
