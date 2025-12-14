## ADDED Requirements

### Requirement: Appendices Reference Documentation
The documentation SHALL provide comprehensive reference appendices for Fe developers.

#### Scenario: User looks up keyword reference
- **WHEN** a user reads the Keyword Reference page
- **THEN** they find a complete list of Fe keywords
- **AND** each keyword has a description and category
- **AND** they understand what each keyword does

#### Scenario: User looks up built-in types
- **WHEN** a user reads the Built-in Types Reference page
- **THEN** they find all numeric types (u8-u256, i8-i256)
- **AND** they find bool, String, and other built-in types
- **AND** they understand the size and range of each type

#### Scenario: User looks up intrinsics
- **WHEN** a user reads the Intrinsics Reference page
- **THEN** they find available intrinsic functions
- **AND** they understand how to use each intrinsic
- **AND** they know any restrictions or requirements

#### Scenario: User learns selector calculation
- **WHEN** a user reads the Selector Calculation page
- **THEN** they understand what function selectors are
- **AND** they can calculate selectors manually
- **AND** they see examples of common ERC selectors

#### Scenario: Solidity developer migrates to Fe
- **WHEN** a Solidity developer reads the migration guide
- **THEN** they understand key differences (effects, explicit storage)
- **AND** they see side-by-side syntax comparisons
- **AND** they can translate Solidity patterns to Fe

#### Scenario: Rust developer learns Fe
- **WHEN** a Rust developer reads the migration guide
- **THEN** they recognize familiar concepts (traits, structs, impl)
- **AND** they understand EVM-specific features
- **AND** they know which Rust features are not available
