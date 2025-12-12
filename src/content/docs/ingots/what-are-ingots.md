---
title: What are Ingots?
description: Understanding Fe's module system and how ingots organize code
---

An **ingot** is Fe's unit of code organization and distribution, similar to a "crate" in Rust or a "package" in other languages. Every Fe project is an ingot, and ingots can depend on other ingots.

## Why Ingots?

Ingots provide several benefits:

- **Code Organization**: Group related code into logical units
- **Reusability**: Share code between projects as dependencies
- **Encapsulation**: Control what's exposed publicly vs kept internal
- **Versioning**: Track and manage versions of shared code

## Ingot Structure

Every ingot has:

1. A **manifest file** (`fe.toml`) that defines metadata and dependencies
2. A **source directory** (`src/`) containing Fe source files
3. An **entrypoint** (`src/lib.fe`) that defines what the ingot exports

```
my-ingot/
├── fe.toml        # Manifest with name, version, dependencies
└── src/
    ├── lib.fe     # Entrypoint - exports public items
    └── utils.fe   # Additional source files
```

## Ingots vs Contracts

An ingot is a collection of code. It may contain contracts, but it's not limited to them:

- **Contracts** are deployed to the blockchain
- **Ingots** organize code and can contain contracts, structs, functions, and more

A single ingot might contain:
- Multiple contracts
- Shared utility functions
- Common type definitions
- Message definitions for contract interfaces

## Using Ingots

When you create a Fe project, you're creating an ingot. When you add dependencies, you're pulling in other ingots. The ingot system makes it easy to:

- Start new projects with a standard structure
- Share common patterns across projects
- Build on community-developed libraries

The following sections cover the details of project structure, dependency management, and publishing your own ingots.
