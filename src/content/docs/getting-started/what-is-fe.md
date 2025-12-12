---
title: What is Fe?
description: Philosophy, goals, and Rust-inspired safety for smart contracts
---

Fe is a statically typed language for the Ethereum Virtual Machine (EVM) that blends Rust-like syntax with an innovative message-passing paradigm tailored to the platform. It offers a complete, batteries-included toolchain, featuring a built-in package manager, formatter, and robust language server to streamline development. Designed for safety and correctness, Fe empowers developers with features like generics, traits, pattern matching, and even higher-kinded types, while ensuring a smooth, modern developer experience. It serves as a secure foundation for building the next generation of decentralized applications.

:::caution[Pre-Release Software]
Fe has undergone intensive development over the past two years. The last published release is outdated and should not be used. This documentation covers the upcoming release currently in development. Follow progress on [GitHub](https://github.com/fe-lang/fe).
:::

## Philosophy

Fe's design is guided by principles that address the unique challenges of smart contract development.

### Explicit Over Implicit

In Fe, dependencies are visible. The effect system requires functions to declare what capabilities they need: what state they can read, what they can modify, what external resources they can access. No hidden state access. No surprise side effects. Auditors can understand a function's scope from its signature alone.

### Safety First

Fe catches errors at compile time, not after deployment. The type system prevents common vulnerabilities:

- Integer overflow protection through explicit types
- No implicit type coercions
- Null-free design with `Option` types
- Compiler-enforced effect boundaries

When Fe compiles, you have strong guarantees about what your code can and cannot do.

### Developer Experience

Fe provides modern tooling out of the box:

- **Package manager**: Manage dependencies with ingots
- **Formatter**: Consistent code style
- **Language server**: IDE integration with completions and diagnostics
- **Clear errors**: Helpful compiler messages that guide you to solutions

### EVM-Native

Fe is designed specifically for the Ethereum Virtual Machine, not adapted from a general-purpose language. This means:

- Native understanding of EVM types (`u256`, `Address`)
- First-class support for contract patterns (storage, events, messages)
- Efficient compilation to EVM bytecode
- ABI compatibility with existing tooling and contracts

## Goals

### Safe Smart Contract Development

Smart contracts manage real value and are immutable once deployed. Fe's primary goal is preventing bugs before they reach production through:

- Strong static typing that catches errors early
- Effect system that limits what each function can access
- Explicit mutability that shows where state changes occur

### Readable, Auditable Code

Security audits are essential for smart contracts. Fe prioritizes code that humans can understand:

- Function signatures reveal capabilities
- No magic or hidden behavior
- Clear, consistent syntax
- Self-documenting effect declarations

### Modern Developer Experience

Writing smart contracts shouldn't mean giving up modern tooling:

- Fast compilation
- Integrated package management
- IDE support with the language server
- Familiar syntax for developers coming from Rust or similar languages

## Rust-Inspired Safety

Fe brings proven safety concepts from Rust to smart contract development.

### Strong Static Typing

Every value has a known type at compile time. The compiler rejects type mismatches before your code runs, catching errors during development rather than after deployment.

### Explicit Mutability

Variables are immutable by default. The `mut` keyword explicitly marks what can change. This applies to effect parameters too, making it clear at a glance whether a function reads or modifies state.

### Pattern Matching

Fe supports pattern matching for expressive control flow. The compiler ensures all cases are handled, preventing bugs from unhandled conditions.

### Option and Result Types

Fe avoids null with explicit optional types. You must handle the case where a value might not exist, eliminating null pointer errors by design.

### Traits and Generics

Fe supports generic programming with trait bounds, enabling reusable code that works across types while maintaining type safety.
