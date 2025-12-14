## ADDED Requirements

### Requirement: Complete ERC20 Example Documentation
The documentation SHALL provide a complete, annotated ERC20 token example based on the Fe compiler's test fixture.

#### Scenario: User learns from real ERC20 implementation
- **WHEN** a user reads the Complete ERC20 page
- **THEN** they see the full CoolCoin source code
- **AND** they understand contract-level effect declarations
- **AND** they understand storage struct patterns
- **AND** they understand message definitions with selectors

#### Scenario: User understands ERC20 walkthrough
- **WHEN** a user reads the walkthrough sections
- **THEN** they understand each component of the implementation
- **AND** they can apply the patterns to their own contracts
- **AND** they see how access control integrates with token operations

#### Scenario: User learns event patterns
- **WHEN** a user examines the event handling
- **THEN** they understand TransferEvent and ApprovalEvent structs
- **AND** they see how events are emitted via the Log effect
- **AND** they understand indexed field usage
