---
title: Variables & Mutability
description: Variable declaration with let, mutability with mut, shadowing, and scope
---

Variables are fundamental to any program. Fe provides a straightforward yet powerful system for declaring and working with variables, with immutability as the default for safer code.

## Variable Declaration

Use the `let` keyword to declare a variable:

```fe
let x = 42
let name = "Alice"
let is_active = true
```

### With Type Annotations

You can explicitly specify a variable's type using a colon followed by the type:

```fe
let x: u256 = 42
let name: String = "Alice"
let balance: u128 = 1000
```

Type annotations are optional when the compiler can infer the type from the value. However, explicit annotations are useful when:

- You need a specific integer size (e.g., `u256` vs inferred type)
- The type isn't obvious from context
- You want to document the intended type for clarity

```fe
// Without annotation - type is inferred
let count = 100

// With annotation - explicitly u8 for storage efficiency
let small_count: u8 = 100
```

### Uninitialized Variables

You can declare a variable without immediately initializing it:

```fe
let x: u256
// ... later in the code
x = 42
```

However, Fe will ensure the variable is initialized before it's used.

## Immutability by Default

In Fe, variables are **immutable by default**. Once a value is bound to a name, it cannot be changed:

```fe
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
let mut counter = 0
counter = 1      // OK: counter is mutable
counter = 2      // OK: can reassign multiple times
```

The `mut` keyword signals to readers that this variable's value will change during execution.

### When to Use Mutability

Use `mut` when you genuinely need to modify a value:

```fe
let mut total = 0
for item in items {
    total = total + item.value
}
```

Prefer immutable variables when possible. If you find yourself using `mut` frequently, consider whether there's a more functional approach.

## Variable Shadowing

Fe allows you to declare a new variable with the same name as a previous one. The new declaration *shadows* the previous one:

```fe
let x = 5
let x = x + 1    // x is now 6, shadows the previous x
let x = x * 2    // x is now 12, shadows again
```

Shadowing is different from mutation:

- **Shadowing** creates a new variable (can even change the type)
- **Mutation** modifies an existing variable's value

```fe
// Shadowing allows type changes
let value = "42"           // value is a String
let value: u256 = 42       // value is now u256 (new variable)

// Mutation requires same type
let mut count: u256 = 0
count = 1                  // OK: same type
// count = "one"           // Error: type mismatch
```

### When to Use Shadowing

Shadowing is useful when:

- Transforming a value through multiple steps
- Converting between types while keeping a meaningful name
- Reusing a name in a new scope without `mut`

```fe
// Transform through steps
let input = get_raw_input()
let input = validate(input)
let input = process(input)
```

## Scope and Blocks

Variables are scoped to the block in which they're declared. A block is code enclosed in curly braces `{}`:

```fe
let outer = 1

{
    let inner = 2
    // Both outer and inner are accessible here
}

// Only outer is accessible here
// inner is out of scope
```

### Nested Scopes

Inner scopes can access variables from outer scopes:

```fe
let x = 10

{
    let y = 20
    let sum = x + y  // OK: x is accessible from outer scope
}
```

### Shadowing in Inner Scopes

You can shadow an outer variable within an inner scope:

```fe
let x = 5

{
    let x = 10       // Shadows outer x within this block
    // x is 10 here
}

// x is 5 here (outer x unchanged)
```

## Pattern Bindings

The `let` statement supports pattern matching, allowing you to destructure values:

### Tuple Destructuring

```fe
let point = (10, 20)
let (x, y) = point      // x = 10, y = 20
```

You can ignore parts of a tuple with `_`:

```fe
let (x, _) = point      // Only bind x, ignore y
```

### Struct Destructuring

```fe
struct Point {
    x: u256
    y: u256
}

let point = Point { x: 10, y: 20 }
let Point { x, y } = point    // x = 10, y = 20
```

You can also rename bindings:

```fe
let Point { x: horizontal, y: vertical } = point
// horizontal = 10, vertical = 20
```

### Mutable Pattern Bindings

Use `mut` in patterns to make specific bindings mutable:

```fe
let (mut x, y) = (1, 2)
x = 10       // OK: x is mutable
// y = 20    // Error: y is immutable
```

In struct patterns:

```fe
let Point { mut x, y } = point
x = 100      // OK: x is mutable
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
