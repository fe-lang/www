---
title: Keyword Reference
description: All Fe keywords
---

This appendix lists all reserved keywords in Fe, organized by category.

## Declaration Keywords

| Keyword | Description |
|---------|-------------|
| `const` | Declares a compile-time constant |
| `let` | Declares a local variable |
| `mut` | Marks a variable or parameter as mutable |
| `fn` | Declares a function |
| `struct` | Declares a struct type |
| `enum` | Declares an enum type |
| `trait` | Declares a trait |
| `impl` | Implements methods or traits for a type |
| `type` | Declares a type alias |
| `contract` | Declares a smart contract |
| `msg` | Declares a message type group |
| `pub` | Makes an item publicly visible |
| `extern` | Declares external items |

## Control Flow Keywords

| Keyword | Description |
|---------|-------------|
| `if` | Conditional branch |
| `else` | Alternative branch |
| `match` | Pattern matching expression |
| `for` | Loop over an iterator |
| `while` | Loop while condition is true |
| `break` | Exit a loop early |
| `continue` | Skip to next loop iteration |
| `return` | Return from a function |

## Type Keywords

| Keyword | Description |
|---------|-------------|
| `Self` | The implementing type in trait/impl |
| `self` | The receiver in methods |
| `true` | Boolean true literal |
| `false` | Boolean false literal |

## Effect Keywords

| Keyword | Description |
|---------|-------------|
| `uses` | Declares effect requirements |
| `with` | Binds values to effects |

## Contract Keywords

| Keyword | Description |
|---------|-------------|
| `init` | Contract constructor block |
| `recv` | Message receive block |

## Ownership & Reference Keywords

| Keyword | Description |
|---------|-------------|
| `own` | Takes ownership of a value |
| `ref` | Reserved for future use (references) |

## Module Keywords

| Keyword | Description |
|---------|-------------|
| `use` | Import items from other modules |
| `mod` | Declares a module |
| `ingot` | Refers to the current ingot root |

## Other Keywords

| Keyword | Description |
|---------|-------------|
| `as` | Type casting |
| `in` | Used in `for` loops |

## Contextual Keywords

These identifiers have special meaning in certain contexts:

| Keyword | Context | Description |
|---------|---------|-------------|
| `where` | Generic bounds | Introduces where clauses |
| `_` | Patterns | Wildcard pattern, ignores value |

## Quick Reference by Category

### Declarations
```fe ignore
const MAX_SUPPLY: u256 = 1000000
let balance = 0
let mut counter = 0
fn transfer() { }
struct Token { }
enum Status { }
trait Hashable { }
impl Hashable for Token { }
pub contract MyContract { }
msg TokenMsg { }
```

### Control Flow
```fe ignore
if condition { } else { }
match value { }
for item in items { }
while condition { }
return value
```

### Effects
```fe ignore
fn foo() uses (storage: Storage) { }
fn foo() uses (storage: mut Storage) { }
with (storage: Storage = store) { }
```

### Contracts
```fe
//<hide>
use std::abi::sol
msg Msg {
    #[selector = sol("getValue()")]
    GetValue -> u256,
}
//</hide>
contract Token {
    init() { }
    recv Msg {
        //<hide>
        GetValue -> u256 { 0 }
        //</hide>
    }
}
```

## Reserved for Future Use

The following keywords are reserved and may not be used as identifiers:

- `async`
- `await`
- `dyn`
- `move`
- `static`
- `super`
- `unsafe`
- `crate`

## Summary

Fe has approximately 40 keywords covering:
- **13** declaration keywords
- **8** control flow keywords
- **4** type keywords
- **2** effect keywords
- **2** contract keywords
- **2** ownership/reference keywords
- **3** module keywords
- **2** other keywords
- **2** contextual keywords
