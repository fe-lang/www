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

```fe
//<hide>
fn example() {
//</hide>
let small: u8 = 255
let balance: u256 = 1000000000000000000  // 1 ETH in wei
let max_supply: u256 = 21000000
//<hide>
let _ = (small, balance, max_supply)
}
//</hide>
```

### Notes

- `u256` is the native EVM word size and most efficient for storage
- Choose integer widths for their range and ABI requirements; do not assume automatic storage packing
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

```fe
//<hide>
fn example() {
//</hide>
let delta: i256 = -100
let temperature: i32 = -40
let positive: i256 = 1000
//<hide>
let _ = (delta, temperature, positive)
}
//</hide>
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

```fe
//<hide>
fn __bool_example() {
//</hide>
let is_active: bool = true
let paused: bool = false

if is_active && !paused {
    // ...
}
//<hide>
}
//</hide>
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

```fe
//<hide>
fn example() {
//</hide>
let name: String<31> = "CoolCoin"
let symbol: String<8> = "COOL"
let message: String<31> = "Transfer failed"
//<hide>
let _ = (name, symbol, message)
}
//</hide>
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

```fe
//<hide>
fn __tuple_example() {
//</hide>
let pair: (u256, bool) = (100, true)
let triple: (u256, u256, u256) = (1, 2, 3)
//<hide>
let _ = triple

// Destructuring shown separately to avoid move conflicts
}
fn __tuple_destructure() {
//</hide>

// Destructuring
let (_amount, _success): (u256, bool) = (100, true)
//<hide>
}
fn __tuple_index() {
//</hide>

// Access by index
let pair2: (u256, bool) = (100, true)
let first = pair2.0
//<hide>
let _ = first
}
fn __tuple_index2() {
//</hide>
let pair3: (u256, bool) = (100, true)
let second = pair3.1
//<hide>
let _ = second
}
//</hide>
```

## Arrays

Fixed-size collections of homogeneous types:

| Type | Description |
|------|-------------|
| `[T; N]` | Array of N elements of type T |

### Usage

```fe
//<hide>
fn example() {
//</hide>
let numbers: [u256; 3] = [1, 2, 3]
let first = numbers[0]
//<hide>
let _ = first
}
//</hide>
```

Fixed-size arrays also support `==` and `!=` when their elements implement `Eq`:

```fe
#[test]
fn array_equality() {
    let left: [u256; 3] = [1, 2, 3]
    let right: [u256; 3] = [1, 2, 3]
    assert!(left == right)
}
```

## Dynamic ABI Arrays

`std::abi::DynArray<T>` represents an ABI array with a runtime length. Build the elements in memory with a `MemVec<T>` (a growable array from the prelude) or a `MemArray<T>`, then encode them with `DynArray::from_slice`:

```fe
use std::abi::DynArray

#[test]
fn dynamic_array_copy() {
    var values = MemVec<u256>::new()
    values.push(10)
    values.push(20)
    let encoded: DynArray<u256> = DynArray::from_slice(values.as_slice())
    values.set(index: 0, value: 99)
    assert!(encoded.len() == 2)
    assert!(encoded.get(0) == 10)
    assert!(values.as_slice()[0] == 99)
}
```

`from_slice` creates an independent copy suitable for ABI arguments, return values, or event fields. `to_mem_array` decodes the elements back into a `MemArray`. `DynArray::get` works for any ABI element type: one-word values, multi-word static structs and tuples, and dynamic elements such as `Bytes`. Lengths and indices are `usize`. Out-of-bounds access reverts with `Panic(0x32)`.

## Unit Type

The empty tuple, representing no value:

| Type | Description |
|------|-------------|
| `()` | Unit type, no value |

### Usage

```fe
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

```fe
//<hide>
fn example() -> u256 {
//</hide>
let maybe_value: Option<u256> = Option::Some(42)
let nothing: Option<u256> = Option::None
//<hide>
let _ = nothing
//</hide>

match maybe_value {
    Option::Some(v) => v,
    Option::None => 0,
}
//<hide>
}
//</hide>
```

## ETH Amounts and Time

`std` types ETH amounts and block time, so that they cannot be mixed up with each other or with plain numbers. All three are in the prelude and are a single `uint256` in the ABI:

| Type | Description |
|------|-------------|
| `Wei` | An amount of native ETH |
| `Timestamp` | A point in time, in unix seconds |
| `Duration` | A span of time, in seconds |

### Usage

```fe
use std::evm::{days, ether, gwei, hours}

const LOCK: Duration = days(2) + hours(12)

#[test]
fn typed_amounts_and_time() {
    let price = gwei(30) * 21_000
    assert!(price < ether(1))
    assert!(price / gwei(1) == 630_000)
    assert!(ether(1).mul_div(numerator: 3, denominator: 1000) == gwei(3_000_000))

    let start = Timestamp::from_seconds(1_700_000_000)
    let unlock = start + LOCK
    assert!(unlock - start == LOCK)
    assert!(LOCK.as_seconds() == 216_000)
}
```

`Timestamp + Duration` is a `Timestamp`, `Timestamp - Timestamp` is a `Duration`, and `Wei / Wei` is a plain `u256` ratio; `Timestamp + Timestamp` or `Wei + Duration` do not compile. `Wei` and `Duration` add, subtract, scale and divide by a `u256`, take a remainder, and compare. Build values with `wei`, `gwei`, `ether`, `seconds`, `minutes`, `hours`, `days` and `weeks` (all `const fn`s in `std::evm`), or the constants `WEI`, `GWEI`, `ETHER`, `SECOND`, `MINUTE`, `HOUR`, `DAY` and `WEEK`. Use `as_wei()` or `as_seconds()` where a plain number is needed.

## StorageMap

Key-value storage mapping:

| Type | Description |
|------|-------------|
| `StorageMap<K, V>` | Maps keys of type K to values of type V |

### Usage

```fe
struct Storage {
    balances: StorageMap<Address, u256>,
    allowances: StorageMap<(Address, Address), u256>,
}

//<hide>
fn __example_map(account: Address, new_balance: u256) uses (storage: mut Storage) {
//</hide>
// Access
let balance = storage.balances.get(account)

// Update
storage.balances.set(key: account, value: new_balance)
//<hide>
let _ = balance
}
//</hide>
```

### Notes

- Maps are storage-only types
- Non-existent keys return the zero value
- Tuples can be used as composite keys

## Type Casting

Convert between numeric types with `as`:

```fe
//<hide>
fn __casting_example() {
//</hide>
let small: u8 = 100
let big: u256 = small as u256

let signed: i256 = -50
let unsigned: u256 = signed.downcast_unchecked()  // Caution: reinterprets bits
//<hide>
let _ = (big, unsigned)
}
//</hide>
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
| ETH and time | `Wei`, `Timestamp`, `Duration` |
| Memory collections | `MemVec<T>`, `MemArray<T>`, `MemSlice<T>` |
| ABI arrays | `DynArray<T>` |
| Map | `StorageMap<K, V>` |

## EVM Considerations

An EVM storage slot is 32 bytes. Each contract field gets its own root slot, in declaration order. Inside a struct, fields narrower than a word share slots the way Solidity packs struct members. A `StorageMap` keeps its entry for `key` at `keccak256(key ++ slot)`, like a Solidity mapping, and stores values in their type's native layout. Inspect the compiler's contract layout information when layout matters.

Pointer-bearing memory values cannot be persisted in contract storage.

## ABI Array Limits

To construct an ABI array, collect the elements in a `MemVec` or `MemArray` and encode them with `DynArray::from_slice` as shown above. `DynArray` moved from `core::abi` to `std::abi`; import it from there.
