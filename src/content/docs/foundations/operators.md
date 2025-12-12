---
title: Operators & Expressions
description: Arithmetic, comparison, logical, bitwise operators and expression types
---

Fe provides a comprehensive set of operators for arithmetic, comparison, logic, and bit manipulation, along with various expression types for building complex computations.

## Arithmetic Operators

Arithmetic operators work on numeric types.

| Operator | Description | Example |
|----------|-------------|---------|
| `+` | Addition | `a + b` |
| `-` | Subtraction | `a - b` |
| `*` | Multiplication | `a * b` |
| `/` | Division | `a / b` |
| `%` | Modulo (remainder) | `a % b` |
| `**` | Exponentiation | `a ** b` |

```fe
//<hide>
fn example() {
//</hide>
let sum: u256 = 10 + 5        // 15
let diff: u256 = 10 - 5       // 5
let product: u256 = 10 * 5    // 50
let quotient: u256 = 10 / 3   // 3 (integer division)
let remainder: u256 = 10 % 3  // 1
let power: u256 = 2 ** 8      // 256
//<hide>
let _ = (sum, diff, product, quotient, remainder, power)
}
//</hide>
```

### Integer Division

Division between integers performs integer division, truncating toward zero:

```fe
//<hide>
fn example() {
//</hide>
let result: i256 = 7 / 2   // 3, not 3.5
let neg: i256 = -7 / 2     // -3
//<hide>
let _ = (result, neg)
}
//</hide>
```

## Comparison Operators

Comparison operators return `bool` values.

| Operator | Description | Example |
|----------|-------------|---------|
| `==` | Equal to | `a == b` |
| `!=` | Not equal to | `a != b` |
| `<` | Less than | `a < b` |
| `<=` | Less than or equal | `a <= b` |
| `>` | Greater than | `a > b` |
| `>=` | Greater than or equal | `a >= b` |

```fe
//<hide>
fn example() {
//</hide>
let x: u256 = 5
let y: u256 = 10

let is_equal = x == y      // false
let is_not_equal = x != y  // true
let is_less = x < y        // true
let is_less_eq = x <= 5    // true
let is_greater = x > y     // false
let is_greater_eq = y >= 10 // true
//<hide>
let _ = (is_equal, is_not_equal, is_less, is_less_eq, is_greater, is_greater_eq)
}
//</hide>
```

## Logical Operators

Logical operators work on `bool` values.

| Operator | Description | Example |
|----------|-------------|---------|
| `&&` | Logical AND | `a && b` |
| `\|\|` | Logical OR | `a \|\| b` |
| `!` | Logical NOT | `!a` |

```fe
//<hide>
fn example() {
//</hide>
let a = true
let b = false

let and_result = a && b  // false
let or_result = a || b   // true
let not_result = !a      // false
//<hide>
let _ = (and_result, or_result, not_result)
}
//</hide>
```

### Short-Circuit Evaluation

Logical operators use short-circuit evaluation:

- `&&` stops evaluating if the left operand is `false`
- `||` stops evaluating if the left operand is `true`

```fe
//<hide>
fn expensive_check() -> bool { true }
fn compute_value() -> bool { false }
fn example() {
let is_valid = true
let has_default = false
//</hide>
// If is_valid is false, expensive_check() won't be called
if is_valid && expensive_check() {
    // ...
}

// If has_default is true, compute_value() won't be called
let value = has_default || compute_value()
//<hide>
let _ = value
}
//</hide>
```

## Bitwise Operators

Bitwise operators manipulate individual bits of integer values.

| Operator | Description | Example |
|----------|-------------|---------|
| `&` | Bitwise AND | `a & b` |
| `\|` | Bitwise OR | `a \| b` |
| `^` | Bitwise XOR | `a ^ b` |
| `~` | Bitwise NOT | `~a` |
| `<<` | Left shift | `a << n` |
| `>>` | Right shift | `a >> n` |

```fe
//<hide>
fn example() {
//</hide>
let a: u8 = 0b1100
let b: u8 = 0b1010

let and_bits: u8 = a & b   // 0b1000 (8)
let or_bits: u8 = a | b    // 0b1110 (14)
let xor_bits: u8 = a ^ b   // 0b0110 (6)
let not_bits: u8 = ~a      // inverts all bits

let shifted_left: u8 = a << 2   // 0b110000 (48)
let shifted_right: u8 = a >> 2  // 0b0011 (3)
//<hide>
let _ = (and_bits, or_bits, xor_bits, not_bits, shifted_left, shifted_right)
}
//</hide>
```

### Common Bitwise Patterns

```fe
//<hide>
fn example() {
let value: u8 = 0b1010
//</hide>
const FLAG: u8 = 0b0010

// Check if a bit is set
let has_flag = (value & FLAG) != 0

// Set a bit
let with_flag = value | FLAG

// Clear a bit
let without_flag = value & ~FLAG

// Toggle a bit
let toggled = value ^ FLAG
//<hide>
let _ = (has_flag, with_flag, without_flag, toggled)
}
//</hide>
```

## Unary Operators

Unary operators take a single operand.

| Operator | Description | Example |
|----------|-------------|---------|
| `+` | Unary plus (identity) | `+x` |
| `-` | Negation | `-x` |
| `!` | Logical NOT | `!flag` |
| `~` | Bitwise NOT | `~bits` |

```fe
//<hide>
fn example() {
//</hide>
let x: i256 = 42
let negative: i256 = -x      // -42
let positive: i256 = +x      // 42 (no change)

let flag = true
let inverted = !flag   // false

let bits: u8 = 0b11110000
let flipped: u8 = ~bits    // 0b00001111
//<hide>
let _ = (negative, positive, inverted, flipped)
}
//</hide>
```

## Assignment Operators

### Simple Assignment

Use `=` to assign a value to a mutable variable:

```fe
//<hide>
fn example() {
//</hide>
let mut x: u256 = 10
x = 20  // x is now 20
//<hide>
let _ = x
}
//</hide>
```

### Compound Assignment

Compound assignment operators combine an operation with assignment:

| Operator | Equivalent to | Description |
|----------|---------------|-------------|
| `+=` | `x = x + y` | Add and assign |
| `-=` | `x = x - y` | Subtract and assign |
| `*=` | `x = x * y` | Multiply and assign |
| `/=` | `x = x / y` | Divide and assign |
| `%=` | `x = x % y` | Modulo and assign |
| `&=` | `x = x & y` | Bitwise AND and assign |
| `\|=` | `x = x \| y` | Bitwise OR and assign |
| `^=` | `x = x ^ y` | Bitwise XOR and assign |
| `<<=` | `x = x << y` | Left shift and assign |
| `>>=` | `x = x >> y` | Right shift and assign |

```fe
//<hide>
fn example() {
//</hide>
let mut count: u256 = 10
count += 5   // count is now 15
count -= 3   // count is now 12
count *= 2   // count is now 24

let mut flags: u8 = 0b0000
flags |= 0b0001  // Set bit 0
flags |= 0b0100  // Set bit 2
// flags is now 0b0101
//<hide>
let _ = (count, flags)
}
//</hide>
```

## Expression Types

Fe is an expression-oriented language. Most constructs produce values.

### Block Expressions

A block `{ }` is an expression that evaluates to its last expression:

```fe
//<hide>
fn example() {
//</hide>
let result: u256 = {
    let a: u256 = 10
    let b: u256 = 20
    a + b  // no semicolon - this is the block's value
}
// result is 30
//<hide>
let _ = result
}
//</hide>
```

### Function Calls

Call functions with parentheses:

```fe
//<hide>
fn compute(a: u256, b: u256) -> u256 { a + b }
fn process(data: u256, flag: bool) -> u256 { if flag { data } else { 0 } }
fn example() {
let data: u256 = 100
//</hide>
let value = compute(10, 20)
let result = process(data, flag: true)  // with labeled argument
//<hide>
let _ = (value, result)
}
//</hide>
```

### Method Calls

Call methods on values using dot notation:

```fe
//<hide>
struct Counter { pub value: u256 }
impl Counter {
    pub fn multiply(self, by: u256) -> u256 { self.value * by }
    pub fn add(self, amount: u256) -> u256 { self.value + amount }
}
fn example() {
let counter = Counter { value: 5 }
//</hide>
let doubled = counter.multiply(by: 2)
let incremented = counter.add(amount: 10)
//<hide>
let _ = (doubled, incremented)
}
//</hide>
```

### Field Access

Access struct fields with dot notation:

```fe
//<hide>
struct Point { pub x: u256, pub y: u256 }
struct Profile { pub name: String<32> }
struct User { pub profile: Profile }
fn example() {
let point = Point { x: 10, y: 20 }
let user = User { profile: Profile { name: "Alice" } }
//</hide>
let x = point.x
let name = user.profile.name
//<hide>
let _ = (x, name)
}
//</hide>
```

### Indexing

Access array and tuple elements by index:

```fe
//<hide>
fn example() {
let arr: [u256; 3] = [10, 20, 30]
let tuple: (u256, u256) = (100, 200)
//</hide>
let first = arr[0]
let third = arr[2]

let x = tuple.0
let y = tuple.1
//<hide>
let _ = (first, third, x, y)
}
//</hide>
```

### Tuple Expressions

Create tuples with parentheses:

```fe
//<hide>
fn example() {
//</hide>
let point: (u256, u256) = (10, 20)
let triple: (u256, bool, String<5>) = (1, true, "hello")
let unit: () = ()  // empty tuple (unit type)
//<hide>
let _ = (point, triple, unit)
}
//</hide>
```

### Array Expressions

Create arrays with brackets:

```fe
//<hide>
fn example() {
//</hide>
let numbers: [u256; 5] = [1, 2, 3, 4, 5]
let flags: [bool; 3] = [true, false, true]

// Repeat syntax: [value; count]
let zeros: [u256; 10] = [0; 10]  // array of 10 zeros
//<hide>
let _ = (numbers, flags, zeros)
}
//</hide>
```

### If Expressions

`if` is an expression that returns a value:

```fe
//<hide>
fn example() {
let a: u256 = 5
let b: u256 = 10
let count: u256 = 3
//</hide>
let max = if a > b { a } else { b }

let description = if count == 0 {
    "none"
} else if count == 1 {
    "one"
} else {
    "many"
}
//<hide>
let _ = (max, description)
}
//</hide>
```

### Match Expressions

`match` is an expression for pattern matching:

```fe
//<hide>
fn example() {
let value: u256 = 2
//</hide>
let result = match value {
    0 => "zero"
    1 => "one"
    _ => "other"
}
//<hide>
let _ = result
}
//</hide>
```

### Parenthesized Expressions

Use parentheses to control evaluation order:

```fe
//<hide>
fn example() {
let a: u256 = 5
let b: u256 = 10
let c: u256 = 2
let x: u256 = 3
let y: u256 = 4
let z: u256 = 5
let w: u256 = 2
//</hide>
let result: u256 = (a + b) * c
let complex: u256 = ((x + y) * z) / w
//<hide>
let _ = (result, complex)
}
//</hide>
```

## Operator Precedence

Operators are evaluated according to their precedence. Higher precedence operators bind tighter.

| Precedence | Operators | Associativity |
|------------|-----------|---------------|
| Highest | `()`, `.`, `[]` | Left to right |
| | Unary `+`, `-`, `!`, `~` | Right to left |
| | `**` | Right to left |
| | `*`, `/`, `%` | Left to right |
| | `+`, `-` | Left to right |
| | `<<`, `>>` | Left to right |
| | `&` | Left to right |
| | `^` | Left to right |
| | `\|` | Left to right |
| | `==`, `!=`, `<`, `<=`, `>`, `>=` | Left to right |
| | `&&` | Left to right |
| | `\|\|` | Left to right |
| Lowest | `=`, `+=`, `-=`, etc. | Right to left |

When in doubt, use parentheses to make your intent clear:

```fe
//<hide>
fn example() {
let a: u256 = 5
let b: u256 = 10
let c: u256 = 2
//</hide>
// These are equivalent, but the second is clearer
let result: u256 = a + b * c
let result: u256 = a + (b * c)
//<hide>
let _ = result
}
//</hide>
```

## Summary

| Category | Operators |
|----------|-----------|
| Arithmetic | `+`, `-`, `*`, `/`, `%`, `**` |
| Comparison | `==`, `!=`, `<`, `<=`, `>`, `>=` |
| Logical | `&&`, `\|\|`, `!` |
| Bitwise | `&`, `\|`, `^`, `~`, `<<`, `>>` |
| Assignment | `=`, `+=`, `-=`, `*=`, `/=`, `%=`, `&=`, `\|=`, `^=`, `<<=`, `>>=` |
