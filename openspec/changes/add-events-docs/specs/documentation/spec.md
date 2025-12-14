## ADDED Requirements

### Requirement: Events & Logging Documentation
The documentation SHALL provide comprehensive coverage of Fe's event system and logging capabilities.

#### Scenario: User learns event struct definition
- **WHEN** a user reads the Event Structs page
- **THEN** they understand how to define event structs
- **AND** they understand the `#[indexed]` attribute for filterable fields
- **AND** they understand EVM topic limitations (max 3 indexed fields)

#### Scenario: User learns to emit events
- **WHEN** a user reads the Emitting Events page
- **THEN** they understand the `log.emit()` syntax
- **AND** they know best practices for when to emit events
- **AND** they can write handlers that emit events

#### Scenario: User understands Log effect
- **WHEN** a user reads the Log Effect page
- **THEN** they understand why logging is an explicit effect
- **AND** they know how to declare the Log effect
- **AND** they understand the benefits of explicit logging

#### Scenario: User understands ABI compatibility
- **WHEN** a user reads the ABI Compatibility page
- **THEN** they understand how Fe events map to EVM logs
- **AND** they understand event signatures and topic encoding
- **AND** they can integrate with standard Ethereum tooling
