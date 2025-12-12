---
title: Variables & Mutability
description: Variable declaration with let, mutability with mut, shadowing, and scope
---

Variables are fundamental to any program. Fe provides a straightforward yet powerful system for declaring and working with variables, with immutability as the default for safer code.

## Variable Declaration

Use the `let` keyword to declare a variable:

```fe
//<hide>
fn example() {
//</hide>
let x: u256 = 42
let name = "Alice"
let is_active = true
//<hide>
let _ = (x, name, is_active)
}
//</hide>
```

### With Type Annotations

You can explicitly specify a variable's type using a colon followed by the type:

```fe
//<hide>
fn example() {
//</hide>
let x: u256 = 42
let name: String<5> = "Alice"
let balance: u128 = 1000
//<hide>
let _ = (x, name, balance)
}
//</hide>
```

Type annotations are optional when the compiler can infer the type from the value. However, explicit annotations are useful when:

- You need a specific integer size (e.g., `u256` vs inferred type)
- The type isn't obvious from context
- You want to document the intended type for clarity

```fe
//<hide>
fn example() {
//</hide>
// With annotation - type must be specified for integers
let count: u256 = 100

// Explicitly u8 for storage efficiency
let small_count: u8 = 100
//<hide>
let _ = (count, small_count)
}
//</hide>
```

### Uninitialized Variables

You can declare a variable without immediately initializing it:

```fe
//<hide>
fn example() {
//</hide>
let mut x: u256
// ... later in the code
x = 42
//<hide>
let _ = x
}
//</hide>
```

However, Fe will ensure the variable is initialized before it's used.

## Immutability by Default

In Fe, variables are **immutable by default**. Once a value is bound to a name, it cannot be changed:

```fe ignore
let x = 5
x = 10  // Error: cannot assign to immutable variable
```

This design choice promotes:

- **Safety**: Prevents accidental modifications
- **Predictability**: Values don't change unexpectedly
- **Clarity**: When you see a variable, you know its value won't change

## Mutable Variables

When you need a variable whose value can change, use the `mut` keyword:

```fe
//<hide>
fn example() {
//</hide>
let mut counter: u256 = 0
counter = 1      // OK: counter is mutable
counter = 2      // OK: can reassign multiple times
//<hide>
let _ = counter
}
//</hide>
```

The `mut` keyword signals to readers that this variable's value will change during execution.

### When to Use Mutability

Use `mut` when you genuinely need to modify a value:

```fe ignore
let mut total = 0
for item in items {
    total = total + item.value
}
```

Prefer immutable variables when possible. If you find yourself using `mut` frequently, consider whether there's a more functional approach.

## Variable Shadowing

Fe allows you to declare a new variable with the same name as a previous one. The new declaration *shadows* the previous one:

```fe
//<hide>
fn example() {
//</hide>
let x: u256 = 5
let x: u256 = x + 1    // x is now 6, shadows the previous x
let x: u256 = x * 2    // x is now 12, shadows again
//<hide>
let _ = x
}
//</hide>
```

Shadowing is different from mutation:

- **Shadowing** creates a new variable (can even change the type)
- **Mutation** modifies an existing variable's value

```fe
//<hide>
fn example() {
//</hide>
// Shadowing allows type changes
let value = "42"           // value is a String<2>
let value: u256 = 42       // value is now u256 (new variable)

// Mutation requires same type
let mut count: u256 = 0
count = 1                  // OK: same type
// count = "one"           // Error: type mismatch
//<hide>
let _ = (value, count)
}
//</hide>
```

### When to Use Shadowing

Shadowing is useful when:

- Transforming a value through multiple steps
- Converting between types while keeping a meaningful name
- Reusing a name in a new scope without `mut`

```fe
//<hide>
fn get_raw_input() -> u256 { 100 }
fn validate(x: u256) -> u256 { x }
fn process(x: u256) -> u256 { x * 2 }
fn example() {
//</hide>
// Transform through steps
let input = get_raw_input()
let input = validate(input)
let input = process(input)
//<hide>
let _ = input
}
//</hide>
```

## Scope and Blocks

Variables are scoped to the block in which they're declared. A block is code enclosed in curly braces `{}`:

```fe
//<hide>
fn example() {
//</hide>
let outer: u256 = 1

{
    let inner: u256 = 2
    // Both outer and inner are accessible here
    //<hide>
    let _ = (outer, inner)
    //</hide>
}

// Only outer is accessible here
// inner is out of scope
//<hide>
let _ = outer
}
//</hide>
```

### Nested Scopes

Inner scopes can access variables from outer scopes:

```fe
//<hide>
fn example() {
//</hide>
let x: u256 = 10

{
    let y: u256 = 20
    let sum: u256 = x + y  // OK: x is accessible from outer scope
    //<hide>
    let _ = sum
    //</hide>
}
//<hide>
let _ = x
}
//</hide>
```

### Shadowing in Inner Scopes

You can shadow an outer variable within an inner scope:

```fe
//<hide>
fn example() {
//</hide>
let x: u256 = 5

{
    let x: u256 = 10       // Shadows outer x within this block
    // x is 10 here
    //<hide>
    let _ = x
    //</hide>
}

// x is 5 here (outer x unchanged)
//<hide>
let _ = x
}
//</hide>
```

## Pattern Bindings

The `let` statement supports pattern matching, allowing you to destructure values:

### Tuple Destructuring

```fe
//<hide>
fn example() {
//</hide>
let point: (u256, u256) = (10, 20)
let (x, y) = point      // x = 10, y = 20
//<hide>
let _ = (x, y)
}
//</hide>
```

You can ignore parts of a tuple with `_`:

```fe
//<hide>
fn example() {
let point: (u256, u256) = (10, 20)
//</hide>
let (x, _) = point      // Only bind x, ignore y
//<hide>
let _ = x
}
//</hide>
```

### Struct Destructuring

```fe
struct Point {
    x: u256,
    y: u256,
}

//<hide>
fn example() {
//</hide>
let point = Point { x: 10, y: 20 }
let Point { x, y } = point    // x = 10, y = 20
//<hide>
let _ = (x, y)
}
//</hide>
```

You can also rename bindings:

```fe
//<hide>
struct Point {
    x: u256,
    y: u256,
}

fn example() {
let point = Point { x: 10, y: 20 }
//</hide>
let Point { x: horizontal, y: vertical } = point
// horizontal = 10, vertical = 20
//<hide>
let _ = (horizontal, vertical)
}
//</hide>
```

### Mutable Pattern Bindings

Use `mut` in patterns to make specific bindings mutable:

```fe
//<hide>
fn example() {
//</hide>
let (mut x, y): (u256, u256) = (1, 2)
x = 10       // OK: x is mutable
// y = 20    // Error: y is immutable
//<hide>
let _ = (x, y)
}
//</hide>
```

In struct patterns:

```fe
//<hide>
struct Point {
    x: u256,
    y: u256,
}

fn example() {
let point = Point { x: 10, y: 20 }
//</hide>
let Point { mut x, y } = point
x = 100      // OK: x is mutable
//<hide>
let _ = (x, y)
}
//</hide>
```

## Summary

| Feature | Syntax | Description |
|---------|--------|-------------|
| Immutable variable | `let x = value` | Cannot be reassigned |
| Mutable variable | `let mut x = value` | Can be reassigned |
| Type annotation | `let x: Type = value` | Explicit type |
| Shadowing | `let x = ...` (again) | New variable, same name |
| Tuple destructuring | `let (a, b) = tuple` | Bind tuple elements |
| Struct destructuring | `let S { field } = s` | Bind struct fields |
