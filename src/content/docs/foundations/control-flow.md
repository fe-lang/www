---
title: Control Flow
description: Conditionals (if/else), pattern matching (match), and loops (for/while)
---

Control flow constructs determine the order in which code executes. Fe provides conditionals, pattern matching, and loops—all designed as expressions that can return values.

## Conditionals

### If Expressions

Use `if` to execute code based on a condition:

```fe ignore
if balance > 0 {
    process_withdrawal()
}
```

### Else Branches

Add an `else` branch for when the condition is false:

```fe ignore
if balance >= amount {
    withdraw(amount)
} else {
    reject_transaction()
}
```

### Else If Chaining

Chain multiple conditions with `else if`:

```fe ignore
if score >= 90 {
    grade = "A"
} else if score >= 80 {
    grade = "B"
} else if score >= 70 {
    grade = "C"
} else {
    grade = "F"
}
```

### If as an Expression

In Fe, `if` is an expression that returns a value. Both branches must return the same type:

```fe ignore
let max = if a > b { a } else { b }

let status = if is_active {
    "active"
} else {
    "inactive"
}
```

This is useful for concise conditional assignment:

```fe ignore
let fee = if is_premium { 0 } else { calculate_fee(amount) }
```

## Pattern Matching

### Match Expressions

The `match` expression provides powerful pattern matching:

```fe ignore
match value {
    0 => handle_zero()
    1 => handle_one()
    _ => handle_other()
}
```

Like `if`, `match` is an expression that returns a value:

```fe ignore
let description = match count {
    0 => "none"
    1 => "one"
    2 => "two"
    _ => "many"
}
```

### Matching Enum Variants

Match on enum variants to handle different cases:

```fe ignore
enum Status {
    Pending
    Approved
    Rejected(String)
}

let message = match status {
    Status::Pending => "Awaiting review"
    Status::Approved => "Request approved"
    Status::Rejected(reason) => reason  // Extract the reason
}
```

### Matching with Patterns

Use patterns to destructure and bind values:

```fe ignore
match point {
    (0, 0) => "origin"
    (0, y) => "on y-axis"
    (x, 0) => "on x-axis"
    (x, y) => "somewhere else"
}
```

Match on struct fields:

```fe ignore
match user {
    User { active: true, role } => process_active(role)
    User { active: false, .. } => handle_inactive()
}
```

### The Wildcard Pattern

Use `_` to match any value you don't need:

```fe ignore
match result {
    Ok(value) => use_value(value)
    Err(_) => handle_error()  // Ignore the specific error
}
```

### Pattern Exhaustiveness

Match expressions must be exhaustive—every possible value must be handled. The wildcard `_` is often used as a catch-all:

```fe ignore
match day {
    1 => "Monday"
    2 => "Tuesday"
    3 => "Wednesday"
    4 => "Thursday"
    5 => "Friday"
    6 => "Saturday"
    7 => "Sunday"
    _ => "Invalid day"  // Handle all other values
}
```

## Loops

### For Loops

Use `for` to iterate over a collection:

```fe ignore
for item in items {
    process(item)
}
```

### Pattern Binding in For Loops

Destructure elements while iterating:

```fe ignore
for (index, value) in indexed_items {
    store_at(index, value)
}

for User { name, balance } in users {
    if balance > 0 {
        credit(name, balance)
    }
}
```

### While Loops

Use `while` for condition-based loops:

```fe ignore
while count > 0 {
    process_next()
    count = count - 1
}
```

A common pattern for indefinite loops:

```fe ignore
while true {
    if should_stop() {
        break
    }
    do_work()
}
```

## Loop Control

### Break

Use `break` to exit a loop early:

```fe ignore
for item in items {
    if item.is_target() {
        found = item
        break  // Exit the loop
    }
}
```

### Continue

Use `continue` to skip to the next iteration:

```fe ignore
for item in items {
    if item.should_skip() {
        continue  // Skip this item
    }
    process(item)
}
```

### Combining Break and Continue

```fe ignore
let mut sum: u256 = 0
for value in values {
    // Skip negative values
    if value < 0 {
        continue
    }

    // Stop if we exceed the limit
    if sum + value > limit {
        break
    }

    sum = sum + value
}
```

## Early Return

### Return Statement

Use `return` to exit a function early:

```fe ignore
fn find_user(id: u256) -> Option<User> {
    if id == 0 {
        return Option::None  // Early return for invalid ID
    }

    // ... lookup logic ...

    Option::Some(user)  // Implicit return
}
```

### Return with Value

Return a specific value from anywhere in the function:

```fe ignore
fn calculate_discount(amount: u256, is_member: bool) -> u256 {
    if amount < 100 {
        return 0  // No discount for small amounts
    }

    if is_member {
        return amount / 10  // 10% for members
    }

    amount / 20  // 5% for non-members (implicit return)
}
```

### Return vs Implicit Return

Fe functions return the value of their last expression implicitly. Use explicit `return` for:

- Early exits from the function
- Multiple exit points
- Clarity in complex functions

```fe ignore
// Implicit return - last expression is the return value
fn double(x: u256) -> u256 {
    x * 2
}

// Explicit return - needed for early exit
fn safe_divide(a: u256, b: u256) -> Option<u256> {
    if b == 0 {
        return Option::None
    }
    Option::Some(a / b)
}
```

## Summary

| Construct | Syntax | Description |
|-----------|--------|-------------|
| `if` | `if cond { }` | Conditional execution |
| `if-else` | `if cond { } else { }` | Two-way branch |
| `else if` | `if c1 { } else if c2 { }` | Multi-way branch |
| `match` | `match val { pat => expr }` | Pattern matching |
| `for` | `for pat in iter { }` | Iteration over collection |
| `while` | `while cond { }` | Condition-based loop |
| `break` | `break` | Exit loop early |
| `continue` | `continue` | Skip to next iteration |
| `return` | `return` or `return expr` | Exit function early |
