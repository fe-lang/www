---
title: Fe for Rust Developers
description: What's familiar, what's different
---

Fe draws heavy inspiration from Rust. This guide highlights what's familiar and what's different for Rust developers.

## Familiar Concepts

### Structs

Fe structs work like Rust structs:

```fe
struct Point {
    x: u256,
    y: u256,
}

//<hide>
fn example() {
//</hide>
let p = Point { x: 10, y: 20 }
let x = p.x
//<hide>
let _ = x
}
//</hide>
```

### Impl Blocks

Methods are defined in impl blocks:

```fe
struct Counter {
    value: u256,
}

impl Counter {
    fn new() -> Self {
        Counter { value: 0 }
    }

    fn increment(mut self) {
        self.value += 1
    }

    fn get(self) -> u256 {
        self.value
    }
}
```

### Traits

Traits define shared behavior:

```fe
//<hide>
struct Point { x: u256, y: u256 }
//</hide>
trait Hashable {
    fn hash(self) -> u256
}

impl Hashable for Point {
    fn hash(self) -> u256 {
        self.x ^ self.y
    }
}
```

### Generics

Type parameters work similarly:

```fe
fn identity<T>(value: own T) -> T {
    value
}

struct Wrapper<T> {
    value: T,
}

impl<T> Wrapper<T> {
    fn get(own self) -> T {
        self.value
    }
}
```

### Trait Bounds

Constrain generics with trait bounds:

```fe
//<hide>
use _boilerplate::{Hashable, Printable}
//</hide>
fn process<T: Hashable>(item: T) -> u256 {
    item.hash()
}

fn complex<T: Hashable + Printable>(item: T) {
    // T must implement both traits
    //<hide>
    let _ = item.hash()
    //</hide>
}
```

### Enums and Pattern Matching

Enums with match expressions:

```fe
enum Status {
    Pending,
    Active,
    Completed { result: u256 },
}

fn handle(status: Status) -> u256 {
    match status {
        Status::Pending => 0,
        Status::Active => 1,
        Status::Completed { result } => result,
    }
}
```

### Option Type

Optional values use `Option<T>`:

```fe
//<hide>
fn example() -> u256 {
//</hide>
let maybe: Option<u256> = Option::Some(42)

match maybe {
    Option::Some(v) => v,
    Option::None => 0,
}
//<hide>
}
//</hide>
```

### Expression-Based

Most constructs are expressions:

```fe
//<hide>
enum Status {
    Pending,
    Active,
    Completed { result: u256 },
}
fn __expr_example() {
let condition = true
let status = Status::Active
//</hide>
let value: u256 = if condition { 10 } else { 20 }

let result = match status {
    Status::Active => true,
    _ => false,
}
//<hide>
let _ = (value, result)
}
//</hide>
```

### Type Inference

Types are inferred where possible:

```fe
//<hide>
fn __infer_example() {
//</hide>
let x = true    // Type inferred as bool
let y: u8 = 42      // Explicit annotation
//<hide>
let _ = (x, y)
}
//</hide>
```

### Mutability

Variables are immutable by default:

```fe
//<hide>
fn __mut_example() {
//</hide>
let x: u256 = 10    // Immutable
let mut y: u256 = 10 // Mutable
y = 20              // OK
//<hide>
let _ = (x, y)
}
//</hide>
```

## Key Differences

### Simplified Ownership Model

Fe has ownership concepts similar to Rust (`own`, `ref`, `mut`) but with key differences:

- **Default is view mode** (no keyword): the function can read the value but not move or modify it. Unlike Rust, view-mode parameters can be used multiple times without explicit borrowing:

```fe
//<hide>
struct MyStruct {
    pub x: u256,
}
//</hide>

fn process(data: MyStruct) {
    // View mode: read-only access, no ownership transfer
    //<hide>
    let _ = data
    //</hide>
}

//<hide>
fn __ownership_example() {
//</hide>
let a = MyStruct { x: 1 }
process(a)
process(a)  // Fine: view mode doesn't consume the value
//<hide>
}
//</hide>
```

- **`own`** transfers ownership (like Rust's move): the caller cannot use the value after passing it
- **`ref`** creates a read-only reference that can be stored in struct fields (like Rust's `&T`)
- **`mut`** creates a mutable handle (like Rust's `&mut T`)

Fe also has a borrow checker that prevents simultaneous `ref` and `mut` access to the same data.

### No Lifetimes

Fe does not require lifetime annotations. References are scoped but the compiler manages lifetimes implicitly.

See [Ownership & Mutability](/foundations/ownership/) for details on `own`, `ref`, and `mut`.


### Iterators

Currently, Fe has basic loop constructs but not yet the full iterator pattern:

```fe
//<hide>
fn __iter_example() {
let items: [u256; 3] = [1, 2, 3]
let len: u256 = 3
//</hide>
// Rust: items.iter().map(|x| x + 1).collect()
// Fe: Currently uses manual while loops
let mut i: u256 = 0
while i < len {
    // process items[i]
    i = i + 1
}
//<hide>
}
//</hide>
```

:::note[Planned Feature]
A trait-based Iterator system similar to Rust's is planned for Fe. This will enable familiar patterns like `map`, `filter`, and `fold`.
:::

### No Closures

Fe doesn't support closures:

```fe
// Rust: let add = |a, b| a + b;
// Fe: Use named functions
fn add(a: u256, b: u256) -> u256 {
    a + b
}
```

### Modules and Ingots

Fe has modules, but uses different terminology:

| Rust | Fe |

### Modules and Ingots

Fe has modules, but uses different terminology:

| Rust | Fe |
|------|-----|
| Crate | Ingot |
| Module | Module |

```
// In fe.toml
[dependencies]
my_lib = { path = "../my_lib" }
```

Fe organizes code into ingots (packages) containing modules, similar to Rust's crate/module system.

## EVM-Specific Features

### Contract Declarations

Fe has first-class contract support:

```fe
//<hide>
use std::abi::sol
struct TokenStorage { total_supply: u256 }
msg TokenMsg {
    #[selector = sol("totalSupply()")]
    TotalSupply -> u256,
}
//</hide>
contract Token {
    store: TokenStorage

    init(supply: u256) uses (mut store) {
        //<hide>
        let _ = supply
        //</hide>
    }

    recv TokenMsg {
        //<hide>
        TotalSupply -> u256 uses (store) { store.total_supply }
        //</hide>
    }
}
```

### Message Types

External interfaces are defined separately:

```fe
use std::abi::sol

msg TokenMsg {
    #[selector = sol("transfer(address,uint256)")]
    Transfer { to: Address, amount: u256 } -> bool,
}
```

### Storage Maps

Persistent key-value storage:

```fe ignore
struct Storage {
    balances: Map<Address, u256>,
}
```

### Events

Blockchain events for logging:

```fe
#[event]
struct Transfer {
    #[indexed]
    from: Address,
    #[indexed]
    to: Address,
    value: u256,
}
```

### Effect System

Explicit capability tracking:

```fe
//<hide>
struct TokenStore { total_supply: u256 }
//</hide>
fn transfer(from: Address, to: Address, amount: u256)
    uses (store: mut TokenStore, log: mut Log)
{
    // Function declares what it accesses
    //<hide>
    let _ = (from, to, amount, store, log)
    //</hide>
}
```

## Syntax Comparison

| Concept | Rust | Fe |
|---------|------|-----|
| Function | `fn foo() {}` | `fn foo() {}` |
| Struct | `struct Foo {}` | `struct Foo {}` |
| Impl | `impl Foo {}` | `impl Foo {}` |
| Trait | `trait Bar {}` | `trait Bar {}` |
| Generics | `fn foo<T>()` | `fn foo<T>()` |
| Bounds | `T: Trait` | `T: Trait` |
| Match | `match x {}` | `match x {}` |
| If | `if x {}` | `if x {}` |
| Loop | `loop {}` | `loop {}` |
| For | `for x in iter {}` | `for x in iter {}` |
| Let | `let x = 1;` | `let x = 1` |
| Mut | `let mut x = 1;` | `let mut x = 1` |
| Return | `return x` | `return x` |
| Self | `self` | `self` |
| Self type | `Self` | `Self` |

## What You'll Miss from Rust

| Feature | Status in Fe |
|---------|-------------|
| Ownership/Borrowing | Not applicable (effects instead) |
| Lifetimes | Not needed |
| Closures | Not available |
| Iterators | Planned (trait-based) |
| `async`/`await` | Not applicable |
| Macros | Not available |

## What's New in Fe

| Feature | Description |
|---------|-------------|
| `contract` | Smart contract declarations |
| `msg` | Message type definitions |
| `recv` | Message handlers |
| `init` | Contract constructors |
| `uses` | Effect declarations |
| `with` | Effect binding |
| `#[selector]` | ABI selector attributes |
| `#[indexed]` | Event indexing |
| `Map<K, V>` | Storage mappings |

