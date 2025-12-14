## ADDED Requirements

### Requirement: Struct Definition Documentation
The documentation SHALL explain how to define structs.

#### Scenario: User learns struct syntax
- **WHEN** a user reads the "Struct Definition" section
- **THEN** they SHALL find documentation for the `struct` keyword
- **AND** they SHALL learn how to declare fields with types
- **AND** they SHALL understand visibility modifiers (`pub`)
- **AND** examples SHALL show struct instantiation

### Requirement: Impl Blocks Documentation
The documentation SHALL explain impl blocks for structs.

#### Scenario: User learns impl block syntax
- **WHEN** a user reads the "Impl Blocks" section
- **THEN** they SHALL find documentation for the `impl` keyword
- **AND** they SHALL understand the `self` parameter
- **AND** they SHALL learn `mut self` for mutating methods
- **AND** examples SHALL show method definitions and calls

#### Scenario: User understands struct vs contract distinction
- **WHEN** a user reads about impl blocks
- **THEN** they SHALL understand that structs can have impl blocks
- **AND** they SHALL understand that contracts cannot have impl blocks

### Requirement: Associated Functions Documentation
The documentation SHALL explain associated functions.

#### Scenario: User learns associated functions
- **WHEN** a user reads the "Associated Functions" section
- **THEN** they SHALL understand functions without `self` parameter
- **AND** they SHALL learn constructor patterns like `new()`
- **AND** examples SHALL show calling associated functions with `::`

### Requirement: Storage Structs Documentation
The documentation SHALL explain storage structs.

#### Scenario: User learns storage struct patterns
- **WHEN** a user reads the "Storage Structs" section
- **THEN** they SHALL understand how structs serve as effect types
- **AND** they SHALL learn about StorageMap fields
- **AND** examples SHALL show storage structs used with contracts

### Requirement: Helper Structs Documentation
The documentation SHALL explain helper struct patterns.

#### Scenario: User learns helper struct patterns
- **WHEN** a user reads the "Helper Structs" section
- **THEN** they SHALL understand utility struct patterns
- **AND** they SHALL learn about data organization with structs
- **AND** examples SHALL show practical helper struct usage
