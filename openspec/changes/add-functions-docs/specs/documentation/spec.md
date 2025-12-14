## ADDED Requirements

### Requirement: Function Declaration Documentation
The documentation SHALL provide comprehensive coverage of function declaration using the `fn` keyword.

#### Scenario: User learns basic function syntax
- **WHEN** a user reads the Functions documentation
- **THEN** they SHALL find documentation for the `fn` keyword
- **AND** the documentation SHALL show the basic syntax: `fn name() { body }`
- **AND** examples SHALL demonstrate simple function declarations

#### Scenario: User learns function with parameters and return type
- **WHEN** a user reads about function declarations
- **THEN** they SHALL learn the full syntax: `fn name(params) -> ReturnType { body }`
- **AND** examples SHALL show functions with various parameter and return type combinations

### Requirement: Labeled Parameters Documentation
The documentation SHALL explain Fe's labeled parameter system for call-site clarity.

#### Scenario: User learns about labeled parameters
- **WHEN** a user reads the Parameters section
- **THEN** they SHALL understand that parameters can have external labels for call sites
- **AND** they SHALL learn the syntax: `label name: Type`
- **AND** they SHALL understand that the label is used at the call site while name is used in the function body
- **AND** examples SHALL demonstrate labeled parameter declaration and usage

#### Scenario: User learns about unlabeled parameters
- **WHEN** a user needs parameters without labels at the call site
- **THEN** they SHALL learn to use `_` as the label: `_ name: Type`
- **AND** examples SHALL show the difference between labeled and unlabeled calls

#### Scenario: User learns about mutable parameters
- **WHEN** a user reads about mutable parameters
- **THEN** they SHALL learn the `mut` keyword for parameters: `mut name: Type`
- **AND** they SHALL understand when mutable parameters are needed

### Requirement: Self Receiver Documentation
The documentation SHALL explain the `self` receiver for methods.

#### Scenario: User learns about self receiver
- **WHEN** a user reads about the self receiver
- **THEN** they SHALL understand that `self` makes a function a method
- **AND** they SHALL learn about `self` (immutable) vs `mut self` (mutable)
- **AND** examples SHALL show method declarations with different self receivers

### Requirement: Return Types Documentation
The documentation SHALL explain function return types.

#### Scenario: User learns about return types
- **WHEN** a user reads about return types
- **THEN** they SHALL learn the `-> Type` syntax for declaring return types
- **AND** they SHALL understand that functions without `->` return unit type
- **AND** they SHALL learn about the `return` keyword and implicit returns
- **AND** examples SHALL demonstrate both explicit and implicit returns

### Requirement: Visibility Documentation
The documentation SHALL explain function visibility with the `pub` keyword.

#### Scenario: User learns about public functions
- **WHEN** a user reads about visibility
- **THEN** they SHALL understand that functions are private by default
- **AND** they SHALL learn the `pub` keyword makes functions public
- **AND** examples SHALL show public and private function declarations

### Requirement: Generic Functions Documentation
The documentation SHALL introduce generic functions.

#### Scenario: User learns about generic functions
- **WHEN** a user reads about generic functions
- **THEN** they SHALL see the basic syntax: `fn name<T>(param: T) -> T`
- **AND** they SHALL be directed to the Traits & Generics section for full coverage
- **AND** a brief example SHALL demonstrate a simple generic function

### Requirement: Functions with Effects Documentation
The documentation SHALL introduce the `uses` clause for effects.

#### Scenario: User learns about functions with effects
- **WHEN** a user reads about effects in functions
- **THEN** they SHALL see the basic syntax: `fn name() uses EffectType { }`
- **AND** they SHALL be directed to the Effects section for full coverage
- **AND** a brief example SHALL demonstrate a function with effects
