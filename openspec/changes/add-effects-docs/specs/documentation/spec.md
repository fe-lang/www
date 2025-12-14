## ADDED Requirements

### Requirement: What Are Effects Documentation
The documentation SHALL explain what effects are and their purpose.

#### Scenario: User learns about effects
- **WHEN** a user reads the "What Are Effects?" section
- **THEN** they SHALL find a clear definition of effects as capabilities
- **AND** they SHALL understand that effects track resource access
- **AND** they SHALL learn the high-level purpose of the effect system

### Requirement: Declaring Effects Documentation
The documentation SHALL explain how to declare effects on functions and contracts.

#### Scenario: User learns uses clause syntax
- **WHEN** a user reads the "Declaring Effects" section
- **THEN** they SHALL find documentation for the `uses` keyword
- **AND** examples SHALL show single effect syntax: `fn foo() uses Effect { }`
- **AND** examples SHALL show named effects: `fn foo() uses e: Effect { }`
- **AND** examples SHALL show multiple effects: `fn foo() uses (E1, E2) { }`

#### Scenario: User learns contract effects
- **WHEN** a user reads about effects on contracts
- **THEN** they SHALL learn how to declare effects on contract definitions
- **AND** examples SHALL show the contract uses clause syntax

### Requirement: Mutability in Effects Documentation
The documentation SHALL explain mutable vs immutable effects.

#### Scenario: User learns effect mutability
- **WHEN** a user reads the "Mutability in Effects" section
- **THEN** they SHALL learn the difference between `uses Effect` and `uses mut Effect`
- **AND** they SHALL understand mutability matching rules
- **AND** examples SHALL demonstrate when to use mutable effects

### Requirement: Effect Propagation Documentation
The documentation SHALL explain how effects propagate through function calls.

#### Scenario: User learns effect propagation
- **WHEN** a user reads the "Effect Propagation" section
- **THEN** they SHALL understand that callers must provide required effects
- **AND** they SHALL learn the `with` expression for providing effects
- **AND** examples SHALL show effect scoping with nested `with` blocks

### Requirement: Built-in Effects Documentation
The documentation SHALL explain that effects are user-defined.

#### Scenario: User learns about effect types
- **WHEN** a user reads the "Built-in Effects" section
- **THEN** they SHALL understand that effects are user-defined types or traits
- **AND** they SHALL learn common effect patterns
- **AND** examples SHALL show defining custom effect types

### Requirement: Storage as Effects Documentation
The documentation SHALL explain how storage relates to effects.

#### Scenario: User learns storage effects
- **WHEN** a user reads the "Storage as Effects" section
- **THEN** they SHALL learn how contract fields provide effects
- **AND** they SHALL understand field-based effect derivation
- **AND** examples SHALL show accessing storage through effects

### Requirement: Why Effects Matter Documentation
The documentation SHALL explain the benefits of the effect system.

#### Scenario: User learns effect benefits
- **WHEN** a user reads the "Why Effects Matter" section
- **THEN** they SHALL understand the security benefits for smart contracts
- **AND** they SHALL learn about compile-time resource tracking
- **AND** they SHALL understand how effects prevent unauthorized access
