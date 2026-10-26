---
title: Closures
description: Inline function values, the Fn traits, and callable bounds
---

A closure is a function value written inline. Closures are passed to functions such as `fold` and the loop adapters, bound to variables, and called like functions.

## Writing Closures

Parameters go between pipes, followed by the body:

```fe
#[test]
fn closure_basics() {
    let inc = |x: u256| x + 1
    assert!(inc(41) == 42)

    let add = |a: u256, b: u256| a + b
    assert!(add(2, 3) == 5)

    // An explicit return type needs a block body
    let max = |a: own u256, b: u256| -> u256 { if b > a { b } else { a } }
    assert!(max(3, 7) == 7)
}
```

Each parameter has a [mode](/foundations/ownership/#parameter-modes) and a type, as a function parameter does: `x: u256` is a view, `x: own u256` owned and `x: mut u256` a mutable access. Both may be left out where the closure is passed to a function whose bound fixes them, as in `xs.fold(0, |acc, x| acc + x)`.

A parameter may be a pattern that takes its argument apart:

```fe
#[test]
fn closure_patterns() {
    let pairs: [(u256, u256); 2] = [(2, 3), (4, 5)]
    let dot = pairs.fold(0, |acc, (a, b)| acc + a * b)
    assert!(dot == 26)
}
```

## Taking Callables

A function takes a callable through a generic parameter bounded by `Fn`. The bound names the callable's parameter modes and types and its result:

```fe
fn apply_twice<F: Fn(u256) -> u256>(_ f: F, _ x: u256) -> u256 uses F::E {
    f(f(x))
}

#[test]
fn passes_closures() {
    assert!(apply_twice(|x| x * 3, 2) == 18)
}
```

`Fn(own A, B) -> R` is shorthand for the core trait `Fn<(own A, B), Out = R>`. `FnMut` is the variant for callables that are called through a `mut` access. `-> _` leaves the result type open, as in `F: Fn(u256) -> _`.

`uses F::E` forwards the closure's effects (see [Effects](#effects) below).

## Functions as Callables

A named function can be passed wherever a closure can:

```fe
fn add(_ acc: own u256, _ x: u256) -> u256 {
    acc + x
}

#[test]
fn passes_function() {
    let xs: [u256; 3] = [1, 2, 3]
    assert!(xs.fold(0, add) == 6)
}
```

An `unsafe fn` and a [projection](/foundations/ownership/#accesses-are-not-values) are not callable values.

## Captures

A closure captures the values its body uses by copy (for `Copy` values) or by move. Captures are read-only: a closure cannot assign to a captured variable or take `mut` access to it. Thread state through parameters and results instead, as `fold` does:

```fe
#[test]
fn captures() {
    let offset: u256 = 10
    let shift = |x: u256| x + offset
    assert!(shift(5) == 15)

    let xs: [u256; 3] = [1, 2, 3]
    let total = xs.fold(0, |acc, x| acc + x + offset)
    assert!(total == 36)
}
```

A closure cannot capture a `ref` or `mut` binding, or a view of a non-`Copy` value; pass such values as parameters.

## Effects

A closure's body may use effects, such as contract storage or `Ctx`. These are not captured: they are the closure's *effect row* `E`, which is provided wherever the closure is called. A generic function that calls a closure declares `uses F::E`, so its own callers provide those effects:

```fe
struct Limits { max: u256 }

fn count_matching<F: Fn(u256) -> bool>(_ xs: [u256; 4], _ p: F) -> u256 uses F::E {
    var n = 0
    for x in xs {
        if p(x) {
            n += 1
        }
    }
    n
}

fn over_limit(_ xs: [u256; 4]) -> u256 uses (limits: Limits) {
    count_matching(xs, |x| x > limits.max)
}

#[test]
fn closure_effects() {
    with (Limits { max: 2 }) {
        assert!(over_limit([1, 2, 3, 4]) == 2)
    }
}
```

## Restrictions

- Closures cannot be used in constant contexts.
- A closure's captures cannot be modified from inside it.
- A closure that is not passed to a function with a callable bound must annotate its parameter types.
