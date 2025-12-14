## ADDED Requirements

### Requirement: Conditional Expressions Documentation
The documentation SHALL provide comprehensive coverage of conditional expressions.

#### Scenario: User learns if expressions
- **WHEN** a user reads the Conditionals section
- **THEN** they SHALL find documentation for `if` expressions
- **AND** they SHALL learn that `if` is an expression that returns a value
- **AND** examples SHALL demonstrate basic if syntax: `if condition { }`

#### Scenario: User learns else branches
- **WHEN** a user reads about else branches
- **THEN** they SHALL learn the `else` syntax: `if condition { } else { }`
- **AND** they SHALL learn about `else if` chaining
- **AND** examples SHALL show using if/else as expressions to produce values

### Requirement: Pattern Matching Documentation
The documentation SHALL explain the match expression for pattern matching.

#### Scenario: User learns match expressions
- **WHEN** a user reads the Pattern Matching section
- **THEN** they SHALL find documentation for `match` expressions
- **AND** they SHALL learn the syntax: `match value { pattern => body }`
- **AND** examples SHALL demonstrate matching on various patterns

#### Scenario: User learns match arm patterns
- **WHEN** a user reads about match arms
- **THEN** they SHALL learn about literal patterns
- **AND** they SHALL learn about enum variant patterns
- **AND** they SHALL learn about the wildcard pattern `_`
- **AND** the documentation SHALL explain pattern exhaustiveness

### Requirement: Loop Documentation
The documentation SHALL explain all loop constructs.

#### Scenario: User learns for loops
- **WHEN** a user reads about for loops
- **THEN** they SHALL find documentation for `for` loops with `in` keyword
- **AND** the syntax `for pattern in iterable { }` SHALL be explained
- **AND** examples SHALL demonstrate iterating with pattern binding

#### Scenario: User learns while loops
- **WHEN** a user reads about while loops
- **THEN** they SHALL find documentation for `while` loops
- **AND** the syntax `while condition { }` SHALL be explained
- **AND** examples SHALL demonstrate condition-based loops

### Requirement: Loop Control Documentation
The documentation SHALL explain loop control statements.

#### Scenario: User learns break and continue
- **WHEN** a user reads about loop control
- **THEN** they SHALL find documentation for `break` to exit loops
- **AND** they SHALL find documentation for `continue` to skip iterations
- **AND** examples SHALL demonstrate both statements in context

### Requirement: Return Statement Documentation
The documentation SHALL explain early return from functions.

#### Scenario: User learns return statement
- **WHEN** a user reads about return
- **THEN** they SHALL find documentation for `return` without a value
- **AND** they SHALL find documentation for `return expr` with a value
- **AND** the documentation SHALL clarify when return is needed vs implicit return
