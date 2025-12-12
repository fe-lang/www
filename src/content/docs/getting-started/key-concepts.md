---
title: Key Concepts at a Glance
description: High-level preview of Effects, messages, and contracts
---

Before diving deep, here's a quick overview of Fe's key concepts.

## Effects

Effects are Fe's system for making dependencies explicit. Every function declares what it needs access to: what state it can read, what it can modify, what external capabilities it requires.

The `uses` clause in a function signature lists these dependencies. If a function needs to modify account balances, it must declare that. If it needs to emit events, it must declare that too. Nothing is hidden.

This explicitness provides key benefits:

- **Auditability**: You can understand a function's scope from its signature alone
- **Security**: The compiler enforces that functions only access what they declare
- **Testability**: Dependencies are easy to mock because they're explicit

When you see a function's `uses` clause, you know exactly what that function can do. No surprises.

[Learn more about Effects →](/www/effects/what-are-effects/)

## Messages

Messages define how the outside world interacts with Fe contracts. Instead of raw function calls, Fe uses typed message definitions that specify the contract's external interface.

A message group declares related operations together, such as all the functions of an ERC20 token. Each message specifies its parameters, return type, and ABI selector for Ethereum compatibility.

Contracts handle messages with `recv` blocks, which pattern-match on incoming messages and route them to the appropriate logic. Each handler can declare its own effect requirements, following the principle of least privilege.

This message-based approach provides:

- **Clear interfaces**: Message groups serve as explicit API definitions
- **ABI compatibility**: Selectors ensure interoperability with existing tooling
- **Organized handlers**: Related operations are grouped logically

[Learn more about Messages →](/www/messages/defining-messages/)

## Contracts

Contracts in Fe bring together effects, messages, and storage into a cohesive unit. A contract declaration specifies:

- **Contract-level effects**: Capabilities available throughout the contract (like execution context and event logging)
- **Storage fields**: Persistent state that acts as effects within the contract
- **Init block**: Constructor logic that runs on deployment
- **Receive blocks**: Handlers for different message groups

Storage fields in Fe contracts aren't just data. They're effects. This means access to storage is explicit and tracked, just like any other capability. A handler that only reads balances declares read-only access; one that transfers tokens declares mutable access.

This unified model means contracts are:

- **Self-documenting**: The declaration shows all capabilities and state
- **Composable**: Storage structs and access control can be reused
- **Auditable**: Every handler's scope is visible in its signature

[Learn more about Contracts →](/www/contracts/declaration/)

## Structs, Traits, and Generics

Fe provides familiar building blocks for organizing code. Structs group related data together, and impl blocks attach methods to them. This pattern appears throughout Fe, from simple data containers to storage definitions to access control modules.

Traits define shared behavior. When multiple types need the same capability (like being comparable or having a default value), a trait specifies what methods they must provide. This enables polymorphism while maintaining type safety.

Generics let you write code that works across multiple types. A function can accept "any type that implements a certain trait," making it reusable without sacrificing compile-time guarantees. Fe's generics combine with traits to enable flexible, type-safe abstractions.

Together, these features support:

- **Code organization**: Group data and behavior logically
- **Reusability**: Write generic code that works with many types
- **Type safety**: The compiler verifies trait bounds at compile time

[Learn more about Structs →](/www/structs/definition/) · [Traits →](/www/traits/definition/)
