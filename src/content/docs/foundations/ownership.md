---
title: Ownership & Mutability
description: Understanding mut, own, and ref in Fe
---

Fe uses three keywords to control how values are accessed and passed around: **`mut`** for mutability, **`own`** for ownership transfer, and **`ref`** for read-only borrows. Together they give you fine-grained control over who can read, modify, or consume a value.

## Immutability by Default

Variables in Fe are immutable by default. Once bound, their value cannot change:

```fe
#[test]
fn test_immutable_by_default() {
    let x: u256 = 10
    // x = 20  would be a compile error — x is immutable
    assert!(x == 10)
}
```

## `mut` — Mutability

The `mut` keyword appears in several positions, always meaning the same thing: *this value can be modified*.

### Mutable Variables

Add `mut` to a `let` binding to allow reassignment:

```fe
#[test]
fn test_mut_variable() {
    let mut x: u256 = 10
    x = 20
    x += 5
    assert!(x == 25)
}
```

### Mutable Parameters

A function can declare a parameter as `mut` to modify the caller's value. The caller must explicitly pass `mut` at the call site:

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
    let mut x: u256 = 7
    double_in_place(v: mut x)
    // The caller sees the modification
    assert!(x == 14)
}

#[test]
fn test_mut_param_on_field() {
    let mut w = Wallet { balance: 100, nonce: 1 }
    bump_nonce(n: mut w.nonce)
    assert!(w.nonce == 2)
}
```

Key rules:
- The caller must write `double_in_place(v: mut x)` — the label and `mut` at the call site make the mutation visible and intentional
- The variable being passed must itself be `mut`

### `mut self` — Mutable Methods

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
    let mut p = Point { x: 1, y: 2 }
    p.translate(dx: 10, dy: 20)
    // Modifications are visible on p
    assert!(p.x == 11)
    assert!(p.y == 22)
}
```

### Mutable Borrow Handles

You can create a **mutable handle** to a variable or field with `mut`. Writes through the handle are reflected on the original:

```fe
//<hide>
struct Point {
    x: u256,
    y: u256,
}
//</hide>

#[test]
fn test_mut_borrow_handle() {
    let mut x: u256 = 0
    let handle: mut u256 = mut x
    handle = 5
    handle += 1
    // Modifications through the handle are visible on x
    assert!(x == 6)
}

#[test]
fn test_disjoint_field_borrows() {
    let mut p = Point { x: 0, y: 0 }
    // Can borrow different fields simultaneously
    let hx: mut u256 = mut p.x
    let hy: mut u256 = mut p.y
    hx = 100
    hy = 200
    assert!(p.x == 100)
    assert!(p.y == 200)
}
```

Fe allows simultaneous mutable borrows of *different* fields of the same struct — this is safe because the fields are disjoint.

## `own` — Ownership Transfer

The `own` keyword transfers ownership of a value. After passing a value as `own`, the caller can no longer use it — the value has *moved*.

### `own` on Parameters

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
    // p has been moved — using it here would be a compile error
}
```

### `own self` — Consuming Methods

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

### `mut own self` — Modify and Consume

Combine `mut` and `own` to modify the value before consuming it:

```fe
//<hide>
struct Point {
    x: u256,
    y: u256,
}
//</hide>

impl Point {
    fn scale_and_consume(mut own self, factor: u256) -> Point {
        self.x *= factor
        self.y *= factor
        self
    }
}

#[test]
fn test_mut_own_self() {
    let p = Point { x: 2, y: 3 }
    let p2 = p.scale_and_consume(factor: 10)
    assert!(p2.x == 20)
    assert!(p2.y == 30)
}
```

## `ref` — Read-Only References

The `ref` keyword creates a read-only reference. At first glance it looks similar to the default view mode (no keyword) — both give read-only access. The difference becomes clear when you need to **store** a reference.

### Copy vs Reference: Seeing the Difference

When you store a value in a struct field normally, it is **copied**. If the original changes afterwards, the copy is stale:

```fe
struct Data {
    x: u256,
    y: u256,
}

struct Snapshot {
    x: u256,
    y: u256,
}

fn take_snapshot(d: Data) -> Snapshot {
    Snapshot { x: d.x, y: d.y }  // copies the values
}

#[test]
fn test_copy_goes_stale() {
    let mut d = Data { x: 10, y: 20 }

    // Take a snapshot — copies the current values
    let snap = take_snapshot(d)

    // Swap the fields on the original
    let tmp = d.x
    d.x = d.y
    d.y = tmp

    // The snapshot is stale — it still has the old values
    assert!(snap.x == 10)
    assert!(snap.y == 20)

    // The original has been swapped
    assert!(d.x == 20)
    assert!(d.y == 10)
}
```

With `ref`, you don't get a copy — you get a **reference to the original**. The compiler enforces this at the type level. You cannot accidentally put a plain `u256` into a `ref u256` field:

```fe
//<hide>
struct Data {
    x: u256,
    y: u256,
}
//</hide>

struct LiveView {
    x: ref u256,  // must hold a reference, not a copy
    y: ref u256,
}

fn live_view(d: ref Data) -> LiveView {
    LiveView { x: ref d.x, y: ref d.y }  // stores references
}

#[test]
fn test_ref_is_not_a_copy() {
    let d = Data { x: 10, y: 20 }

    let live = live_view(d: ref d)

    // live.x and live.y point to d's fields — they are NOT copies.
    // The compiler guarantees this: writing `LiveView { x: d.x }` would
    // be a type error ("expected `ref u256`, but `u256` is given").
    assert!(live.x == d.x)
    assert!(live.y == d.y)
}
```

Because `ref` borrows prevent mutation (Fe's borrow checker disallows writing to data while a `ref` exists), you cannot demonstrate the "ref sees mutation" pattern at runtime. Instead, Fe gives you a stronger guarantee: the type system ensures that `ref` fields can **only** hold references, never accidental copies. If you need a frozen snapshot, you copy explicitly. If you need a live view, you use `ref`.

### When `ref` is Essential: Zero-Copy Wrappers

Consider building a `Slice` that represents a window into an existing array. The slice should not copy the data — it should reference it:

```fe
struct Slice {
    source: ref [u256; 8],  // reference to the original array
    start: usize,
    len: usize,
}

fn slice(arr: ref [u256; 8], start: usize, len: usize) -> Slice {
    Slice { source: arr, start, len }
}

fn sum_slice(s: Slice) -> u256 {
    let mut total: u256 = 0
    let mut i: usize = 0
    while i < s.len {
        total += s.source[s.start + i]
        i += 1
    }
    total
}

#[test]
fn test_slice_no_copy() {
    let arr: [u256; 8] = [10, 20, 30, 40, 50, 60, 70, 80]

    // Create two slices over the same array — no data is copied
    let first_half = slice(arr: ref arr, start: 0, len: 4)
    let second_half = slice(arr: ref arr, start: 4, len: 4)

    assert!(sum_slice(s: first_half) == 100)   // 10+20+30+40
    assert!(sum_slice(s: second_half) == 260)  // 50+60+70+80

    // arr is still fully usable
    assert!(arr[0] == 10)
}
```

With `source: [u256; 8]` instead of `source: ref [u256; 8]`, every `Slice` would contain a full copy of the 8-element array. With `ref`, both slices point to the same original — zero copies, guaranteed by the type system.

### `ref` vs View: Summary

| | View (no keyword) | `ref` |
|---|---|---|
| Can read values | Yes | Yes |
| Can modify values | No | No |
| Is a type (`ref T`) | No | Yes |
| Can store in struct fields | No | Yes |
| Forwards to `ref` param | Needs `ref` at call site | Passes directly |

Use **view** (the default) when you just need to read a value. Use **`ref`** when you need to store a reference in a struct or pass it through a chain of functions that all expect `ref`.

## Summary

| Keyword | Position | Meaning |
|---------|----------|---------|
| `mut` | `let mut x` | Variable can be reassigned |
| `mut` | `fn f(v: mut T)` | Function can modify caller's value |
| `mut` | `fn f(mut self)` | Method can modify struct fields |
| `mut` | `let h: mut T = mut x` | Mutable handle (borrow) to `x` |
| `own` | `fn f(v: own T)` | Function takes ownership, caller loses access |
| `own` | `fn f(own self)` | Method consumes the receiver |
| `mut own` | `fn f(mut own self)` | Method can modify and consume the receiver |
| `ref` | `fn f(v: ref T)` | Function gets read-only reference |
| `ref` | `source: ref T` | Struct field holds a reference |

### Default Behavior

Without any keyword, Fe parameters use **view** mode: the function can read the value but cannot modify or consume it. This is the most restrictive — and safest — default.

### Choosing the Right Mode

- Use **no keyword** (view) when you just need to read a value
- Use **`ref`** when you need to store a reference in a struct or forward it through multiple functions
- Use **`mut`** when the function needs to modify a value in place
- Use **`own`** when the function needs to take full ownership of a value
