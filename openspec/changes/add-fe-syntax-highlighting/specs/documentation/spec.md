## ADDED Requirements

### Requirement: Fe Syntax Highlighting
The documentation system SHALL provide syntax highlighting for Fe code blocks.

#### Scenario: Fe code blocks are highlighted
- **WHEN** a markdown file contains a code block with language identifier `fe`
- **THEN** the code block SHALL render with syntax highlighting for Fe language constructs

#### Scenario: Keywords are highlighted
- **WHEN** Fe code contains keywords (contract, msg, recv, init, fn, let, mut, const, pub, if, else, match, for, while, loop, return, uses, with, assert, revert)
- **THEN** keywords SHALL be highlighted distinctly from other code elements

#### Scenario: Types are highlighted
- **WHEN** Fe code contains type names (u256, u128, u64, u32, u16, u8, i256, bool, Address, String, Map, Option, Self)
- **THEN** type names SHALL be highlighted distinctly

#### Scenario: Attributes are highlighted
- **WHEN** Fe code contains attributes (#[selector = ...], #[indexed])
- **THEN** attributes SHALL be highlighted as metadata/annotations

#### Scenario: Reference validation
- **WHEN** syntax highlighting is applied
- **THEN** the complete ERC20 example (`src/content/docs/examples/erc20.md`) SHALL render correctly as it represents compiler-validated Fe syntax
