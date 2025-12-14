---
title: What Are Effects?
description: Explicit dependencies and capability-based access control
---

Effects are Fe's system for making dependencies explicit. They declare what capabilities a function needs—what external resources it can access—and the compiler enforces these declarations.

## The Problem with Hidden State

In many languages, functions can access global state, modify storage, or call external services without any indication in their signature. This leads to:

- **Hidden dependencies**: You can't tell what a function does just by looking at its signature
- **Surprising behavior**: Functions may have side effects you didn't expect
- **Testing difficulties**: Mocking hidden dependencies is awkward
- **Security risks**: In smart contracts, hidden state access can lead to vulnerabilities

```fe ignore
// In languages without effects, this signature tells you nothing
// about what resources the function accesses
fn transfer(from: u256, to: u256, amount: u256)
```

## Effects as Explicit Capabilities

Fe's effect system requires functions to declare their capabilities upfront using the `uses` clause:

```fe ignore
fn transfer(from: u256, to: u256, amount: u256) uses mut Balances {
    // This function can only access Balances
    // and can modify it (mut)
}
```

Now the function signature tells you exactly what it can do:
- It needs access to `Balances`
- It will modify `Balances` (indicated by `mut`)
- It cannot access anything else

## A Simple Example

Here's how effects work in practice:

```fe ignore
// Define an effect type
pub struct Counter {
    pub value: u256,
}

// This function requires the Counter effect
fn increment() uses mut Counter {
    Counter.value = Counter.value + 1
}

// This function requires read-only access
fn get_count() uses Counter -> u256 {
    Counter.value
}

// Caller must provide the effect
fn main() {
    let mut counter = Counter { value: 0 }

    // Provide the effect with 'with'
    with (Counter = counter) {
        increment()
        increment()
        let count = get_count()  // count is 2
    }
}
```

## Key Concepts

| Concept | Description |
|---------|-------------|
| Effect | A capability that a function requires to execute |
| `uses` clause | Declares what effects a function needs |
| `mut` | Indicates the function will modify the effect |
| `with` | Provides an effect to a scope |

## What Effects Enable

The effect system provides:

1. **Explicit dependencies**: Function signatures tell you everything
2. **Compiler enforcement**: Missing or incorrect effects are compile errors
3. **Scoped access**: Effects are only available where explicitly provided
4. **Controlled mutation**: Distinguish between reading and modifying

The following sections cover how to declare effects, use mutability, and understand how effects propagate through your code.
