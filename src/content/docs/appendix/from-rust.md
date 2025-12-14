---
title: Fe for Rust Developers
description: What's familiar, what's different
---

Fe draws heavy inspiration from Rust. This guide highlights what's familiar and what's different for Rust developers.

## Familiar Concepts

### Structs

Fe structs work like Rust structs:

```fe ignore
struct Point {
    x: u256,
    y: u256,
}

let p = Point { x: 10, y: 20 }
let x = p.x
```

### Impl Blocks

Methods are defined in impl blocks:

```fe ignore
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

```fe ignore
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

```fe ignore
fn identity<T>(value: T) -> T {
    value
}

struct Wrapper<T> {
    value: T,
}

impl<T> Wrapper<T> {
    fn get(self) -> T {
        self.value
    }
}
```

### Trait Bounds

Constrain generics with trait bounds:

```fe ignore
fn process<T: Hashable>(item: T) -> u256 {
    item.hash()
}

fn complex<T: Hashable + Printable>(item: T) {
    // T must implement both traits
}
```

### Enums and Pattern Matching

Enums with match expressions:

```fe ignore
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

```fe ignore
let maybe: Option<u256> = Option::Some(42)

match maybe {
    Option::Some(v) => v,
    Option::None => 0,
}
```

### Expression-Based

Most constructs are expressions:

```fe ignore
let value = if condition { 10 } else { 20 }

let result = match status {
    Status::Active => true,
    _ => false,
}
```

### Type Inference

Types are inferred where possible:

```fe ignore
let x = 42          // u256 inferred
let y: u8 = 42      // Explicit annotation
```

### Mutability

Variables are immutable by default:

```fe ignore
let x = 10          // Immutable
let mut y = 10      // Mutable
y = 20              // OK
```

## Key Differences

### No Ownership/Borrowing

Fe doesn't have Rust's ownership system. All values are copied or have reference semantics based on context:

```fe ignore
// Rust would require borrowing
fn process(data: MyStruct) {
    // In Fe, no ownership concerns
}

let a = MyStruct { ... }
process(a)
process(a)  // Fine in Fe, would be error in Rust
```

### No Lifetimes

No lifetime annotations needed:

```fe ignore
// Rust: fn longest<'a>(a: &'a str, b: &'a str) -> &'a str
// Fe: Just works
fn longest(a: String<32>, b: String<32>) -> String<32> {
    if a.len() > b.len() { a } else { b }
}
```

### Effects Instead of References

Fe uses an effect system instead of borrowing:

```fe ignore
// Rust: fn modify(data: &mut Storage)
// Fe: Effect declaration
fn modify() uses mut Storage {
    Storage.value = 10
}
```

### Different Collection Types

Fe has a standard library, but EVM constraints mean some Rust types aren't available:

| Rust | Fe | Reason |
|------|-----|--------|
| `Vec<T>` | Fixed arrays `[T; N]` | No dynamic heap allocation |
| `HashMap<K, V>` | `Map<K, V>` | Storage-only, uses EVM storage slots |
| `String` | `String<N>` | Fixed size for predictable gas costs |
| `Box<T>` | Not available | No heap |
| `Rc<T>`, `Arc<T>` | Not available | No heap, no threading |

### Fixed-Size Types

Fe prefers fixed-size types for EVM efficiency:

```fe ignore
// Rust: String, Vec<u8>
// Fe: Fixed-size
let name: String<32> = "Token"
let data: [u8; 32] = [0; 32]
```

### Iterators

Currently, Fe has basic loop constructs but not yet the full iterator pattern:

```fe ignore
// Rust: items.iter().map(|x| x + 1).collect()
// Fe: Currently uses manual loops
for i in 0..items.len() {
    // ...
}
```

:::note[Planned Feature]
A trait-based Iterator system similar to Rust's is planned for Fe. This will enable familiar patterns like `map`, `filter`, and `fold`.
:::

### No Result Type (Yet)

Error handling primarily uses assertions:

```fe ignore
// Rust: Result<T, E>
// Fe: Assertions and revert
assert(balance >= amount, "Insufficient balance")
```

### No Closures

Fe doesn't support closures:

```fe ignore
// Rust: let add = |a, b| a + b;
// Fe: Use named functions
fn add(a: u256, b: u256) -> u256 {
    a + b
}
```

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

```fe ignore
contract Token {
    store: TokenStorage,

    init(supply: u256) {
        // Constructor
    }

    recv TokenMsg {
        // Message handlers
    }
}
```

### Message Types

External interfaces are defined separately:

```fe ignore
msg TokenMsg {
    #[selector = 0xa9059cbb]
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

```fe ignore
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

```fe ignore
fn transfer(from: Address, to: Address, amount: u256)
    uses (mut store: TokenStore, mut log: Log)
{
    // Function declares what it accesses
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
| `Result<T, E>` | Use assertions/revert |
| Closures | Not available |
| Iterators | Planned (trait-based) |
| `Vec<T>` | Fixed arrays only |
| Pattern guards | Limited |
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

## Tips for Rust Developers

1. **Forget ownership** - Fe doesn't have borrow checking; think in terms of effects

2. **Use effects** - Instead of `&mut`, declare effects with `uses mut`

3. **Fixed sizes** - Plan for fixed-size data structures upfront

4. **No heap** - EVM has no heap; design accordingly

5. **Storage is special** - `Map` only works in storage, not memory

6. **Selectors matter** - External interfaces need explicit ABI selectors

7. **Events are logs** - Use events for off-chain observability
