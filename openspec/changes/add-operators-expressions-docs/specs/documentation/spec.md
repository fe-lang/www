## ADDED Requirements

### Requirement: Arithmetic Operators Documentation
The documentation SHALL provide comprehensive coverage of arithmetic operators.

#### Scenario: User learns arithmetic operators
- **WHEN** a user reads the Arithmetic Operators section
- **THEN** they SHALL find documentation for: `+` (add), `-` (subtract), `*` (multiply), `/` (divide), `%` (modulo), `**` (power)
- **AND** examples SHALL demonstrate each operator with numeric types
- **AND** the documentation SHALL note that `**` is the exponentiation operator

### Requirement: Comparison Operators Documentation
The documentation SHALL explain all comparison operators.

#### Scenario: User learns comparison operators
- **WHEN** a user reads the Comparison Operators section
- **THEN** they SHALL find documentation for: `==`, `!=`, `<`, `<=`, `>`, `>=`
- **AND** examples SHALL show comparisons returning `bool`
- **AND** the documentation SHALL explain when each operator is appropriate

### Requirement: Logical Operators Documentation
The documentation SHALL explain logical operators for boolean logic.

#### Scenario: User learns logical operators
- **WHEN** a user reads the Logical Operators section
- **THEN** they SHALL find documentation for: `&&` (and), `||` (or), `!` (not)
- **AND** examples SHALL demonstrate boolean expressions
- **AND** the documentation SHALL explain short-circuit evaluation if applicable

### Requirement: Bitwise Operators Documentation
The documentation SHALL explain bitwise operators for bit manipulation.

#### Scenario: User learns bitwise operators
- **WHEN** a user reads the Bitwise Operators section
- **THEN** they SHALL find documentation for: `&` (and), `|` (or), `^` (xor), `~` (not), `<<` (left shift), `>>` (right shift)
- **AND** examples SHALL demonstrate bit manipulation
- **AND** the documentation SHALL explain common use cases

### Requirement: Unary Operators Documentation
The documentation SHALL explain unary operators.

#### Scenario: User learns unary operators
- **WHEN** a user reads the Unary Operators section
- **THEN** they SHALL find documentation for: `+` (positive), `-` (negation), `!` (logical not), `~` (bitwise not)
- **AND** examples SHALL demonstrate unary operator usage

### Requirement: Assignment Operators Documentation
The documentation SHALL explain assignment and compound assignment operators.

#### Scenario: User learns assignment operators
- **WHEN** a user reads the Assignment section
- **THEN** they SHALL find documentation for simple assignment: `=`
- **AND** they SHALL find documentation for compound assignment: `+=`, `-=`, `*=`, `/=`, `%=`, `&=`, `|=`, `^=`, `<<=`, `>>=`
- **AND** examples SHALL demonstrate both forms

### Requirement: Expression Types Documentation
The documentation SHALL explain the various expression types in Fe.

#### Scenario: User learns about expression types
- **WHEN** a user reads the Expression Types section
- **THEN** they SHALL learn about block expressions: `{ ... }`
- **AND** they SHALL learn about function calls: `func(args)`
- **AND** they SHALL learn about method calls: `obj.method(args)`
- **AND** they SHALL learn about field access: `obj.field`
- **AND** they SHALL learn about indexing: `arr[i]`
- **AND** they SHALL learn about tuple expressions: `(a, b, c)`
- **AND** they SHALL learn about array expressions: `[a, b, c]` and `[value; count]`

### Requirement: Operator Precedence Documentation
The documentation SHALL include an operator precedence table.

#### Scenario: User needs to understand precedence
- **WHEN** a user needs to know operator precedence
- **THEN** they SHALL find a precedence table showing relative priorities
- **AND** the table SHALL help users understand expression evaluation order
