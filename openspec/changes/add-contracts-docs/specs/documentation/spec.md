## ADDED Requirements

### Requirement: Contract Declaration Documentation
The documentation SHALL explain how to declare contracts.

#### Scenario: User learns contract syntax
- **WHEN** a user reads the "Contract Declaration" section
- **THEN** they SHALL find documentation for the `contract` keyword
- **AND** they SHALL learn how to define contract fields
- **AND** examples SHALL show basic contract structure

### Requirement: Contract-Level Effects Documentation
The documentation SHALL explain effect dependencies in contracts.

#### Scenario: User learns contract effects
- **WHEN** a user reads the "Contract-Level Effects" section
- **THEN** they SHALL understand how contracts declare effect dependencies
- **AND** they SHALL learn how effects are provided to handlers via `with`
- **AND** examples SHALL show the relationship between contract fields and effects

### Requirement: Storage Fields Documentation
The documentation SHALL explain storage field syntax.

#### Scenario: User learns storage fields
- **WHEN** a user reads the "Storage Fields" section
- **THEN** they SHALL learn the syntax for declaring storage fields
- **AND** they SHALL understand what types can be stored
- **AND** examples SHALL demonstrate storage structs with StorageMap

### Requirement: Init Block Documentation
The documentation SHALL explain the init block.

#### Scenario: User learns init block syntax
- **WHEN** a user reads the "The init Block" section
- **THEN** they SHALL find documentation for `init()` syntax
- **AND** they SHALL understand init parameters
- **AND** examples SHALL show storage initialization

#### Scenario: User learns init constraints
- **WHEN** a user reads about init block behavior
- **THEN** they SHALL understand that init runs at deployment
- **AND** they SHALL learn what operations are allowed in init

### Requirement: Receive Blocks in Contracts Documentation
The documentation SHALL explain recv blocks within contracts.

#### Scenario: User learns contract recv blocks
- **WHEN** a user reads the "Receive Blocks in Contracts" section
- **THEN** they SHALL understand how recv blocks access contract state
- **AND** they SHALL learn the `with` syntax for providing effects
- **AND** examples SHALL show complete contract implementations

### Requirement: Contract Composition Documentation
The documentation SHALL explain contract organization patterns.

#### Scenario: User learns composition patterns
- **WHEN** a user reads the "Contract Composition" section
- **THEN** they SHALL learn how to organize helper functions
- **AND** they SHALL understand effect-based composition
- **AND** examples SHALL show well-structured contracts
