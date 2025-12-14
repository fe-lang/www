## ADDED Requirements

### Requirement: Primitive Types Documentation Page
The documentation SHALL provide a comprehensive page explaining all primitive types available in Fe.

#### Scenario: User learns about boolean type
- **WHEN** a user reads the Primitive Types documentation
- **THEN** they SHALL find documentation for the `bool` type
- **AND** the documentation SHALL include valid values (`true`, `false`)
- **AND** the documentation SHALL include usage examples

#### Scenario: User learns about signed integer types
- **WHEN** a user reads the Primitive Types documentation
- **THEN** they SHALL find documentation for all signed integer types: `i8`, `i16`, `i32`, `i64`, `i128`, `i256`, `isize`
- **AND** each type SHALL include its bit width
- **AND** each type SHALL include its value range
- **AND** examples SHALL demonstrate declaration and usage

#### Scenario: User learns about unsigned integer types
- **WHEN** a user reads the Primitive Types documentation
- **THEN** they SHALL find documentation for all unsigned integer types: `u8`, `u16`, `u32`, `u64`, `u128`, `u256`, `usize`
- **AND** each type SHALL include its bit width
- **AND** each type SHALL include its value range
- **AND** examples SHALL demonstrate declaration and usage

#### Scenario: User learns about String type
- **WHEN** a user reads the Primitive Types documentation
- **THEN** they SHALL find documentation for the `String` type
- **AND** the documentation SHALL explain String usage in Fe
- **AND** examples SHALL demonstrate string literals and operations

### Requirement: Numeric Literal Documentation
The Primitive Types page SHALL document how to write numeric literals in Fe.

#### Scenario: User learns numeric literal syntax
- **WHEN** a user reads the numeric literals section
- **THEN** they SHALL learn about decimal literals (e.g., `42`)
- **AND** they SHALL learn about hexadecimal literals (e.g., `0xff`)
- **AND** they SHALL learn about underscores in literals for readability (e.g., `1_000_000`)
- **AND** they SHALL learn about type suffixes (e.g., `42u256`)

### Requirement: EVM-Specific Type Guidance
The documentation SHALL explain Fe's EVM-specific integer types.

#### Scenario: User understands u256/i256 for EVM
- **WHEN** a user reads about `u256` and `i256` types
- **THEN** they SHALL understand these are the native word size for the EVM
- **AND** they SHALL understand when to prefer these types for gas efficiency
- **AND** the documentation SHALL note that most EVM operations use 256-bit values
