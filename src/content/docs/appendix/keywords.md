---
title: Keyword Reference
description: All Fe keywords
---

This appendix lists all reserved keywords in Fe, organized by category.

## Declaration Keywords

| Keyword | Description |
|---------|-------------|
| `const` | Declares a compile-time constant |
| `let` | Declares an immutable local binding |
| `var` | Declares a mutable local binding, or a mutable owned parameter (`var x: own T`) |
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
| `for` | Loop over a range, array, or other collection |
| `while` | Loop while condition is true |
| `break` | Exit a loop early |
| `continue` | Skip to next loop iteration |
| `return` | Return from a function |
| `yield` | Grant the caller access in a projection, then run code after its last use |

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

## Ownership & Access Keywords

| Keyword | Description |
|---------|-------------|
| `own` | Takes ownership of a value |
| `mut` | Grants mutable access to a place (`x: mut T`, `mut self`, `let h = mut p.x`) |
| `ref` | Grants read access to a place (`let r = ref p.x`, `for ref x in xs`) |
| `mut?` | Makes a function usable at either `ref` or `mut` |
| `unsafe` | Marks an `unsafe fn`, `unsafe { .. }` block, `unsafe` field, trait or impl |

## Module Keywords

| Keyword | Description |
|---------|-------------|
| `use` | Import items from other modules |
| `mod` | Declares a module |
| `ingot` | Refers to the current ingot root |
| `super` | Refers to the parent module |

## Other Keywords

| Keyword | Description |
|---------|-------------|
| `as` | Type casting |
| `in` | Used in `for` loops |

## Contextual Keywords

These identifiers have special meaning in certain contexts:

| Keyword | Context | Description |
|---------|---------|-------------|
| `where` | Generic bounds | Introduces where clauses and const predicates |
| `shape` | Traits | Declares an associated shape or a shape parameter |
| `_` | Patterns | Wildcard pattern, ignores value |

## Quick Reference by Category

### Declarations
```fe ignore
const MAX_SUPPLY: u256 = 1000000
let balance = 0
var counter = 0
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
- `crate`

## Summary

Fe has approximately 40 keywords covering:
- **13** declaration keywords
- **9** control flow keywords
- **4** type keywords
- **2** effect keywords
- **2** contract keywords
- **5** ownership/access keywords
- **4** module keywords
- **2** other keywords
- **3** contextual keywords
