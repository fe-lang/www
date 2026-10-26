---
title: Ownership & Mutability
description: Understanding var, mut, own, and ref in Fe
---

Fe has **mutable value semantics**: every value has exactly one owner, and a reference is never a value. Code reaches data owned by someone else through an **access**. An access exists only as a parameter, a binding, or the result of a projection, and it ends at its last use.

Four keywords control how values are bound and passed around:

- **`var`** declares a mutable value
- **`mut`** grants mutable access to someone else's place
- **`ref`** grants read access to someone else's place
- **`own`** transfers ownership of a value

## Immutability by Default

Bindings in Fe are immutable by default. Once bound, their value cannot change:

```fe
#[test]
fn test_immutable_by_default() {
    let x: u256 = 10
    // x = 20  would be a compile error: x is immutable
    assert!(x == 10)
}
```

## `var`: Mutable Values

Declare a mutable value with `var` instead of `let`:

```fe
#[test]
fn test_var() {
    var x: u256 = 10
    x = 20
    x += 5
    assert!(x == 25)
}
```

:::note
`let mut x = ...` is not Fe. Write `var x = ...` for a mutable value, or `let x = mut p` for a mutable access to `p` (see [Access Bindings](#access-bindings)).
:::

## Parameter Modes

A parameter's mode says how the function may use the argument:

| Mode | Syntax | Call site | Meaning |
|------|--------|-----------|---------|
| View | `x: T` | `f(x: value)` | Read the caller's value |
| Mutable | `x: mut T` | `f(x: mut value)` | Modify the caller's place for the duration of the call |
| Owned | `x: own T` | `f(x: value)` | Take the value; the caller loses it (unless it is `Copy`) |

### View (the Default)

Without a keyword, a parameter is a read-only view of the caller's value. The function can read it but cannot modify or keep it:

```fe
fn total(xs: [u256; 4]) -> u256 {
    xs[0] + xs[1] + xs[2] + xs[3]
}

#[test]
fn test_view_parameter() {
    let xs: [u256; 4] = [1, 2, 3, 4]
    assert!(total(xs) == 10)
    // xs is still fully usable
    assert!(xs[0] == 1)
}
```

### `mut` Parameters

A `mut` parameter modifies the caller's place. The caller must explicitly pass `mut` at the call site:

```fe
//<hide>
struct Wallet {
    balance: u256,
    nonce: u8,
}
//</hide>

fn double_in_place(v: mut u256) {
    v *= 2
}

fn bump_nonce(n: mut u8) {
    n += 1
}

#[test]
fn test_mut_parameter() {
    var x: u256 = 7
    double_in_place(v: mut x)
    // The caller sees the modification
    assert!(x == 14)
}

#[test]
fn test_mut_param_on_field() {
    var w = Wallet { balance: 100, nonce: 1 }
    bump_nonce(n: mut w.nonce)
    assert!(w.nonce == 2)
}
```

Key rules:
- The caller must write `double_in_place(v: mut x)`: the label and `mut` at the call site make the mutation visible and intentional
- The place being passed must itself be mutable (a `var`, or something reached through a `mut` access)

### `own` Parameters

An `own` parameter transfers ownership of the value. After passing a value that is not `Copy` as `own`, the caller can no longer use it: the value has *moved*.

```fe
//<hide>
struct Point {
    x: u256,
    y: u256,
}
//</hide>

fn consume_point(p: own Point) -> u256 {
    p.x + p.y
}

#[test]
fn test_own_parameter() {
    let p = Point { x: 10, y: 20 }
    let sum = consume_point(p)
    assert!(sum == 30)
    // p has been moved: using it here would be a compile error
}
```

An owned parameter is immutable unless it is declared `var x: own T`:

```fe
fn increment(var value: own u256) -> u256 {
    value += 1
    value
}
```

## Receivers

Methods take `self` in the same three modes.

### `mut self`: Mutable Methods

Methods that modify struct fields use `mut self`:

```fe
struct Point {
    x: u256,
    y: u256,
}

impl Point {
    fn translate(mut self, dx: u256, dy: u256) {
        self.x += dx
        self.y += dy
    }
}

#[test]
fn test_mut_self() {
    var p = Point { x: 1, y: 2 }
    p.translate(dx: 10, dy: 20)
    // Modifications are visible on p
    assert!(p.x == 11)
    assert!(p.y == 22)
}
```

### `own self`: Consuming Methods

A method with `own self` consumes the receiver. This is useful for "finalization" patterns:

```fe
//<hide>
struct Point {
    x: u256,
    y: u256,
}
//</hide>

impl Point {
    fn into_tuple(own self) -> (u256, u256) {
        (self.x, self.y)
    }
}

#[test]
fn test_own_self() {
    let p = Point { x: 5, y: 6 }
    let (x, y) = p.into_tuple()
    assert!(x == 5)
    assert!(y == 6)
    // p has been consumed
}
```

### `var own self`: Modify and Consume

An owned receiver is immutable unless it is declared `var own self`:

```fe
//<hide>
struct Point {
    x: u256,
    y: u256,
}
//</hide>

impl Point {
    fn scale_and_consume(var own self, factor: u256) -> Point {
        self.x *= factor
        self.y *= factor
        self
    }
}

#[test]
fn test_var_own_self() {
    let p = Point { x: 2, y: 3 }
    let p2 = p.scale_and_consume(factor: 10)
    assert!(p2.x == 20)
    assert!(p2.y == 30)
}
```

## Access Bindings

A binding can hold an access instead of a value. The marker goes on the initializer: `let h = mut p.x` binds a mutable access to `p.x`, and `let r = ref p.y` binds a read access to `p.y`. Writes through a `mut` access reach the original place:

```fe
//<hide>
struct Point {
    x: u256,
    y: u256,
}
//</hide>

#[test]
fn test_mut_access() {
    var x: u256 = 0
    let handle = mut x
    handle = 5
    handle += 1
    // Modifications through the access are visible on x
    assert!(x == 6)
}

#[test]
fn test_disjoint_field_accesses() {
    var p = Point { x: 0, y: 0 }
    // Different fields can be accessed mutably at the same time
    let hx = mut p.x
    let hy = mut p.y
    hx = 100
    hy = 200
    assert!(p.x == 100)
    assert!(p.y == 200)
}
```

An access is open from its binding to its last use. While it is open, no other access may overlap it unless both only read. Accesses to *different* fields of the same struct never overlap, so Fe allows mutable access to both at once.

### Copies vs. Accesses

A plain `let` always binds a **value**. Reading a `Copy` value through a plain `let` takes a copy, which does not change when the original does:

```fe
//<hide>
struct Data {
    x: u256,
    y: u256,
}
//</hide>

#[test]
fn test_copy_is_independent() {
    var d = Data { x: 10, y: 20 }

    // A copy of the current value
    let old_x = d.x

    d.x = 99

    // The copy still has the old value
    assert!(old_x == 10)
    assert!(d.x == 99)
}
```

A `ref` access reads the original place in place instead. While it is open, the place cannot be written:

```fe
//<hide>
struct Data {
    x: u256,
    y: u256,
}
//</hide>

#[test]
fn test_ref_access() {
    var d = Data { x: 10, y: 20 }
    let r = ref d.y
    // d.y = 0  would be rejected here: `r` is still in use
    assert!(r == 20)
    // r's last use has passed, so d.y can be written again
    d.y = 0
    assert!(d.y == 0)
}
```

### Accesses Are Not Values

`ref` and `mut` are not types. An access cannot be stored in a struct field, in storage, passed as `own`, or returned from an ordinary function. A struct always holds values, never references into other data.

To give a caller access to part of a value, write a **projection**: a function whose return type is `ref T` or `mut T`.

```fe
struct Pair {
    a: u256,
    b: u256,
}

impl Pair {
    fn larger(mut self) -> mut u256 {
        if self.a >= self.b { mut self.a } else { mut self.b }
    }
}

#[test]
fn test_projection() {
    var p = Pair { a: 3, b: 7 }
    let big = mut p.larger()
    big += 1
    assert!(p.b == 8)
}
```

A projection's result binds like a place: `let x = mut p.larger()` holds the access, while a plain `let` of a `ref` result of a `Copy` type takes a copy. Memory views such as `MemSlice` are the built-in way to work with part of a buffer without copying it.

### `mut?`: One Method for Both Modes

A method that should work for both reading and writing can be written once with `mut?`. It is used at `ref` unless the caller asks for `mut`: by assigning to its result, binding it with `mut`, or passing it on as `mut`:

```fe
struct Slots {
    words: [u256; 4],
}

impl Slots {
    fn at(mut? self, _ i: usize) -> mut? u256 {
        mut? self.words[i]
    }
}

#[test]
fn maybe_mut() {
    var s = Slots { words: [1, 2, 3, 4] }
    let x = s.at(1)          // used at `ref`: reads a copy
    s.at(2) = 30             // used at `mut`: writes in place
    let h = mut s.at(3)
    h += 1
    assert!(x == 2)
    assert!(s.words[2] == 30 && s.words[3] == 5)
}
```

Many `core` and `std` methods are `mut?`. For example, `MemVec::as_slice` and `MemBuffer::span` give a read-only view by default and a writable one when taken at `mut`: `let s = mut buffer.span()`.

## Patterns

In a pattern, the marker goes on each bound name: `x` takes a value, `var x` a mutable value, `ref x` a read access, and `mut x` a mutable access.

```fe
//<hide>
struct Point {
    x: u256,
    y: u256,
}
//</hide>

#[test]
fn test_pattern_markers() {
    var p = Point { x: 1, y: 2 }
    let Point { mut x, y } = p
    x += y
    assert!(p.x == 3)

    let (var a, b): (u256, u256) = (10, 20)
    a += b
    assert!(a == 30)
}
```

A marker on the initializer of a destructuring pattern, such as `let (a, b) = mut t`, is an error. Mark each name instead.

## Moving Out

A value reached through a view, a `ref` access, an effect, or storage cannot be moved out; bind it `ref` to read it in place. A move out of a `mut` access leaves a hole that must be filled before the access ends. `core::mem::replace` and `core::mem::take` do both in one call, as does `take()` on an `Option`.

## Summary

| Keyword | Position | Meaning |
|---------|----------|---------|
| `var` | `var x = e` | Mutable value |
| `var` | `fn f(var v: own T)` | Owned parameter that can be modified |
| `var` | `fn f(var own self)` | Method can modify and consume the receiver |
| `mut` | `fn f(v: mut T)` | Function can modify the caller's place |
| `mut` | `fn f(mut self)` | Method can modify struct fields |
| `mut` | `let h = mut x` | Mutable access to `x` |
| `mut` | `fn f(mut self) -> mut T` | Projection granting mutable access |
| `mut?` | `fn f(mut? self) -> mut? T` | Usable at `ref` or at `mut` |
| `own` | `fn f(v: own T)` | Function takes ownership, caller loses the value |
| `own` | `fn f(own self)` | Method consumes the receiver |
| `ref` | `let r = ref x` | Read access to `x` |
| `ref` | `fn f(self) -> ref T` | Projection granting read access |

### Default Behavior

Without any keyword, a parameter is a **view**: the function can read the value but cannot modify, keep or consume it. This is the most restrictive, and safest, default.

### Choosing the Right Mode

- Use **no keyword** (view) when you just need to read a value
- Use **`mut`** when the function needs to modify a value in place
- Use **`own`** when the function needs to take full ownership of a value
- Use **`var`** for local values (and owned parameters) you want to change

## Loops Over Collections

A `for` loop binds each element the way a `let` binds a projection's result. A plain name copies a `Copy` element, `ref` reads a non-`Copy` element in place, and `mut` modifies the element in place:

```fe
struct Reading { value: u256 }

#[test]
fn sums_readings() {
    var readings = [Reading { value: 2 }, Reading { value: 3 }]
    var sum = 0
    for ref reading in readings {
        sum += reading.value
    }
    assert!(sum == 5)

    for mut reading in readings {
        reading.value *= 10
    }
    assert!(readings[0].value == 20)
}
```

Do not add `Copy` to a resource-owning type merely to bypass a move diagnostic. Use a `ref` binding or explicit ownership transfer appropriate to that type.
