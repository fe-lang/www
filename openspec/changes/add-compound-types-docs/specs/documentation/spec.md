## ADDED Requirements

### Requirement: Tuple Documentation
The documentation SHALL explain tuple types and their usage.

#### Scenario: User learns tuple syntax
- **WHEN** a user reads the Tuples section
- **THEN** they SHALL find documentation for tuple type syntax `(T1, T2, ...)`
- **AND** they SHALL learn how to create tuple expressions
- **AND** examples SHALL demonstrate single-element tuples with trailing comma

#### Scenario: User learns tuple operations
- **WHEN** a user reads about tuple operations
- **THEN** they SHALL learn how to access elements by index (`.0`, `.1`, etc.)
- **AND** they SHALL learn how to destructure tuples in patterns
- **AND** examples SHALL show tuples in function return types

### Requirement: Struct Documentation
The documentation SHALL explain struct definitions and usage.

#### Scenario: User learns struct definition
- **WHEN** a user reads the Structs section
- **THEN** they SHALL find documentation for the `struct` keyword
- **AND** they SHALL learn how to define fields with types
- **AND** they SHALL learn about field visibility with `pub`

#### Scenario: User learns struct instantiation
- **WHEN** a user reads about creating structs
- **THEN** they SHALL learn the instantiation syntax `Struct { field: value }`
- **AND** they SHALL learn how to access fields with dot notation
- **AND** examples SHALL demonstrate struct patterns for destructuring

#### Scenario: User learns generic structs
- **WHEN** a user reads about generics
- **THEN** they SHALL learn how to define generic type parameters
- **AND** they SHALL learn about trait bounds on generics

### Requirement: Enum Documentation
The documentation SHALL explain enum definitions and pattern matching.

#### Scenario: User learns enum definition
- **WHEN** a user reads the Enums section
- **THEN** they SHALL find documentation for the `enum` keyword
- **AND** they SHALL learn about unit variants (no data)
- **AND** they SHALL learn about tuple variants (unnamed fields)
- **AND** they SHALL learn about struct variants (named fields)

#### Scenario: User learns enum pattern matching
- **WHEN** a user reads about using enums
- **THEN** they SHALL learn how to match on enum variants
- **AND** they SHALL learn that matches must be exhaustive
- **AND** examples SHALL show extracting data from variants

#### Scenario: User learns generic enums
- **WHEN** a user reads about generic enums
- **THEN** they SHALL learn how to define enums with type parameters
- **AND** examples SHALL show common patterns like Option and Result

### Requirement: Map Documentation
The documentation SHALL explain the StorageMap type for contract storage.

#### Scenario: User learns map basics
- **WHEN** a user reads the Maps section
- **THEN** they SHALL find documentation for `StorageMap<K, V>`
- **AND** they SHALL learn that maps are for contract storage
- **AND** they SHALL understand this is a library type, not a language primitive

#### Scenario: User learns map operations
- **WHEN** a user reads about map operations
- **THEN** they SHALL learn the `get(key)` method to retrieve values
- **AND** they SHALL learn the `set(key, value)` method to store values
- **AND** examples SHALL show declaring maps in contract structs

#### Scenario: User learns map constraints
- **WHEN** a user reads about map type requirements
- **THEN** they SHALL learn about key type requirements (StorageKey trait)
- **AND** they SHALL learn about value type requirements (LoadableScalar, StorableScalar)
