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

```fe ignore
let sum = 10 + 5        // 15
let diff = 10 - 5       // 5
let product = 10 * 5    // 50
let quotient = 10 / 3   // 3 (integer division)
let remainder = 10 % 3  // 1
let power = 2 ** 8      // 256
```

### Integer Division

Division between integers performs integer division, truncating toward zero:

```fe ignore
let result = 7 / 2   // 3, not 3.5
let neg = -7 / 2     // -3
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

```fe ignore
let x = 5
let y = 10

let is_equal = x == y      // false
let is_not_equal = x != y  // true
let is_less = x < y        // true
let is_less_eq = x <= 5    // true
let is_greater = x > y     // false
let is_greater_eq = y >= 10 // true
```

## Logical Operators

Logical operators work on `bool` values.

| Operator | Description | Example |
|----------|-------------|---------|
| `&&` | Logical AND | `a && b` |
| `\|\|` | Logical OR | `a \|\| b` |
| `!` | Logical NOT | `!a` |

```fe ignore
let a = true
let b = false

let and_result = a && b  // false
let or_result = a || b   // true
let not_result = !a      // false
```

### Short-Circuit Evaluation

Logical operators use short-circuit evaluation:

- `&&` stops evaluating if the left operand is `false`
- `||` stops evaluating if the left operand is `true`

```fe ignore
// If is_valid is false, expensive_check() won't be called
if is_valid && expensive_check() {
    // ...
}

// If has_default is true, compute_value() won't be called
let value = has_default || compute_value()
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

```fe ignore
let a: u8 = 0b1100
let b: u8 = 0b1010

let and_bits = a & b   // 0b1000 (8)
let or_bits = a | b    // 0b1110 (14)
let xor_bits = a ^ b   // 0b0110 (6)
let not_bits = ~a      // inverts all bits

let shifted_left = a << 2   // 0b110000 (48)
let shifted_right = a >> 2  // 0b0011 (3)
```

### Common Bitwise Patterns

```fe ignore
// Check if a bit is set
let has_flag = (value & FLAG) != 0

// Set a bit
let with_flag = value | FLAG

// Clear a bit
let without_flag = value & ~FLAG

// Toggle a bit
let toggled = value ^ FLAG
```

## Unary Operators

Unary operators take a single operand.

| Operator | Description | Example |
|----------|-------------|---------|
| `+` | Unary plus (identity) | `+x` |
| `-` | Negation | `-x` |
| `!` | Logical NOT | `!flag` |
| `~` | Bitwise NOT | `~bits` |

```fe ignore
let x: i256 = 42
let negative = -x      // -42
let positive = +x      // 42 (no change)

let flag = true
let inverted = !flag   // false

let bits: u8 = 0b1111_0000
let flipped = ~bits    // 0b0000_1111
```

## Assignment Operators

### Simple Assignment

Use `=` to assign a value to a mutable variable:

```fe ignore
let mut x = 10
x = 20  // x is now 20
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

```fe ignore
let mut count = 10
count += 5   // count is now 15
count -= 3   // count is now 12
count *= 2   // count is now 24

let mut flags: u8 = 0b0000
flags |= 0b0001  // Set bit 0
flags |= 0b0100  // Set bit 2
// flags is now 0b0101
```

## Expression Types

Fe is an expression-oriented language. Most constructs produce values.

### Block Expressions

A block `{ }` is an expression that evaluates to its last expression:

```fe ignore
let result = {
    let a = 10
    let b = 20
    a + b  // no semicolon - this is the block's value
}
// result is 30
```

### Function Calls

Call functions with parentheses:

```fe ignore
let value = compute(10, 20)
let result = process(data, flag: true)  // with labeled argument
```

### Method Calls

Call methods on values using dot notation:

```fe ignore
let length = my_string.len()
let doubled = counter.multiply(by: 2)
```

### Field Access

Access struct fields with dot notation:

```fe ignore
let x = point.x
let name = user.profile.name
```

### Indexing

Access array and tuple elements by index:

```fe ignore
let first = arr[0]
let third = arr[2]

let x = tuple.0
let y = tuple.1
```

### Tuple Expressions

Create tuples with parentheses:

```fe ignore
let point = (10, 20)
let triple = (1, true, "hello")
let unit = ()  // empty tuple (unit type)
```

### Array Expressions

Create arrays with brackets:

```fe ignore
let numbers = [1, 2, 3, 4, 5]
let flags = [true, false, true]

// Repeat syntax: [value; count]
let zeros = [0; 10]  // array of 10 zeros
```

### If Expressions

`if` is an expression that returns a value:

```fe ignore
let max = if a > b { a } else { b }

let description = if count == 0 {
    "none"
} else if count == 1 {
    "one"
} else {
    "many"
}
```

### Match Expressions

`match` is an expression for pattern matching:

```fe ignore
let result = match value {
    0 => "zero"
    1 => "one"
    _ => "other"
}
```

### Parenthesized Expressions

Use parentheses to control evaluation order:

```fe ignore
let result = (a + b) * c
let complex = ((x + y) * z) / w
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

```fe ignore
// These are equivalent, but the second is clearer
let result = a + b * c
let result = a + (b * c)
```

## Summary

| Category | Operators |
|----------|-----------|
| Arithmetic | `+`, `-`, `*`, `/`, `%`, `**` |
| Comparison | `==`, `!=`, `<`, `<=`, `>`, `>=` |
| Logical | `&&`, `\|\|`, `!` |
| Bitwise | `&`, `\|`, `^`, `~`, `<<`, `>>` |
| Assignment | `=`, `+=`, `-=`, `*=`, `/=`, `%=`, `&=`, `\|=`, `^=`, `<<=`, `>>=` |
