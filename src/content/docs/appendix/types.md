---
title: Built-in Types Reference
description: All built-in Fe types
---

This appendix provides a complete reference for Fe's built-in types.

## Unsigned Integers

Unsigned integers cannot be negative. Fe provides sizes matching EVM word boundaries:

| Type | Bits | Bytes | Range |
|------|------|-------|-------|
| `u8` | 8 | 1 | 0 to 255 |
| `u16` | 16 | 2 | 0 to 65,535 |
| `u32` | 32 | 4 | 0 to 4,294,967,295 |
| `u64` | 64 | 8 | 0 to 18,446,744,073,709,551,615 |
| `u128` | 128 | 16 | 0 to 2¹²⁸ - 1 |
| `u256` | 256 | 32 | 0 to 2²⁵⁶ - 1 |

### Usage

```fe ignore
let small: u8 = 255
let balance: u256 = 1000000000000000000  // 1 ETH in wei
let max_supply: u256 = 21000000
```

### Notes

- `u256` is the native EVM word size and most efficient for storage
- Use smaller types when packing multiple values into storage slots
- Arithmetic overflow causes a revert by default

## Signed Integers

Signed integers can be negative. They use two's complement representation:

| Type | Bits | Bytes | Range |
|------|------|-------|-------|
| `i8` | 8 | 1 | -128 to 127 |
| `i16` | 16 | 2 | -32,768 to 32,767 |
| `i32` | 32 | 4 | -2,147,483,648 to 2,147,483,647 |
| `i64` | 64 | 8 | -2⁶³ to 2⁶³ - 1 |
| `i128` | 128 | 16 | -2¹²⁷ to 2¹²⁷ - 1 |
| `i256` | 256 | 32 | -2²⁵⁵ to 2²⁵⁵ - 1 |

### Usage

```fe ignore
let delta: i256 = -100
let temperature: i32 = -40
let positive: i256 = 1000
```

### Notes

- Use signed integers when negative values are meaningful
- Most ERC standards use unsigned integers
- Signed division and comparison use different EVM opcodes

## Boolean

The `bool` type represents true/false values:

| Type | Size | Values |
|------|------|--------|
| `bool` | 1 bit (stored as 1 byte) | `true`, `false` |

### Usage

```fe ignore
let is_active: bool = true
let paused: bool = false

if is_active && !paused {
    // ...
}
```

### Operations

| Operation | Syntax | Description |
|-----------|--------|-------------|
| AND | `a && b` | True if both true |
| OR | `a \|\| b` | True if either true |
| NOT | `!a` | Inverts the value |
| Equality | `a == b` | True if same value |

## String

Fixed-size strings with a maximum length:

| Type | Description |
|------|-------------|
| `String<N>` | String with max length N bytes |

### Usage

```fe ignore
let name: String<32> = "CoolCoin"
let symbol: String<8> = "COOL"
let message: String<64> = "Transfer failed"
```

### Notes

- String length is fixed at compile time
- Shorter strings are padded
- Used for token names, symbols, and error messages

## Tuples

Fixed-size collections of heterogeneous types:

| Type | Description |
|------|-------------|
| `(T1, T2, ...)` | Tuple of types T1, T2, etc. |

### Usage

```fe ignore
let pair: (u256, bool) = (100, true)
let triple: (u256, u256, u256) = (1, 2, 3)

// Destructuring
let (amount, success) = pair

// Access by index
let first = pair.0
let second = pair.1
```

## Arrays

Fixed-size collections of homogeneous types:

| Type | Description |
|------|-------------|
| `[T; N]` | Array of N elements of type T |

### Usage

```fe ignore
let numbers: [u256; 3] = [1, 2, 3]
let first = numbers[0]
```

## Unit Type

The empty tuple, representing no value:

| Type | Description |
|------|-------------|
| `()` | Unit type, no value |

### Usage

```fe ignore
fn do_something() {
    // Implicitly returns ()
}

fn explicit_unit() -> () {
    ()
}
```

## Option

Represents an optional value:

| Type | Description |
|------|-------------|
| `Option<T>` | Either `Some(T)` or `None` |

### Usage

```fe ignore
let maybe_value: Option<u256> = Option::Some(42)
let nothing: Option<u256> = Option::None

match maybe_value {
    Option::Some(v) => v,
    Option::None => 0,
}
```

## Map

Key-value storage mapping:

| Type | Description |
|------|-------------|
| `Map<K, V>` | Maps keys of type K to values of type V |

### Usage

```fe ignore
struct Storage {
    balances: Map<Address, u256>,
    allowances: Map<(Address, Address), u256>,
}

// Access
let balance = storage.balances[account]

// Update
storage.balances[account] = new_balance
```

### Notes

- Maps are storage-only types
- Non-existent keys return the zero value
- Tuples can be used as composite keys

## Type Casting

Convert between numeric types with `as`:

```fe ignore
let small: u8 = 100
let big: u256 = small as u256

let signed: i256 = -50
let unsigned: u256 = signed as u256  // Caution: reinterprets bits
```

### Casting Rules

| From | To | Behavior |
|------|----|----------|
| Smaller unsigned | Larger unsigned | Zero-extends |
| Larger unsigned | Smaller unsigned | Truncates |
| Signed | Unsigned | Reinterprets bits |
| Unsigned | Signed | Reinterprets bits |

## Type Summary

| Category | Types |
|----------|-------|
| Unsigned integers | `u8`, `u16`, `u32`, `u64`, `u128`, `u256` |
| Signed integers | `i8`, `i16`, `i32`, `i64`, `i128`, `i256` |
| Boolean | `bool` |
| String | `String<N>` |
| Tuple | `(T1, T2, ...)` |
| Array | `[T; N]` |
| Unit | `()` |
| Optional | `Option<T>` |
| Map | `Map<K, V>` |

## EVM Considerations

| Type | EVM Storage | Notes |
|------|-------------|-------|
| `u256` | 1 slot | Native word size |
| `u128` | 1/2 slot | Can pack 2 per slot |
| `u64` | 1/4 slot | Can pack 4 per slot |
| `bool` | 1 slot | Unless packed |
| `Map` | Dynamic | Uses keccak256 hashing |
