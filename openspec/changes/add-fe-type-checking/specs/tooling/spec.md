## ADDED Requirements

### Requirement: Fe Binary Distribution
The documentation repository SHALL include a pre-built Fe compiler binary for type-checking code examples.

#### Scenario: Binary is available for Linux
- **WHEN** a developer runs the type checker on Linux x86_64
- **THEN** the pre-built binary SHALL be used without additional setup

#### Scenario: Binary location is consistent
- **WHEN** the fe binary is needed
- **THEN** it SHALL be located at `bin/fe-linux-x86_64` or accessed via `scripts/fe`

#### Scenario: Non-Linux platforms receive guidance
- **WHEN** a developer runs the type checker on a non-Linux platform
- **THEN** the system SHALL display a message explaining the limitation and suggesting alternatives

### Requirement: Code Block Extraction
The system SHALL extract Fe code blocks from markdown documentation files for type checking.

#### Scenario: Complete examples are extracted
- **WHEN** a markdown file contains a code block marked as ` ```fe `
- **THEN** the code block contents SHALL be extracted to a temporary `.fe` file

#### Scenario: Snippets can be excluded
- **WHEN** a markdown file contains a code block marked as ` ```fe ignore `
- **THEN** the code block SHALL NOT be extracted for type checking

#### Scenario: Source location is preserved
- **WHEN** a code block is extracted
- **THEN** the original markdown file path and line number SHALL be recorded for error reporting

### Requirement: Type Checking Execution
The system SHALL run the Fe compiler's type checker on extracted code examples.

#### Scenario: Successful check
- **WHEN** all extracted code blocks pass type checking
- **THEN** the script SHALL exit with code 0

#### Scenario: Failed check
- **WHEN** one or more code blocks fail type checking
- **THEN** the script SHALL exit with a non-zero code
- **AND** SHALL display errors with references to the source markdown file and line

#### Scenario: Error message clarity
- **WHEN** a type error is found in a code block
- **THEN** the error message SHALL include:
  - The markdown file path
  - The line number where the code block starts
  - The Fe compiler's error message

### Requirement: Local Developer Workflow
Developers SHALL be able to run type checking locally via npm scripts.

#### Scenario: npm script availability
- **WHEN** a developer runs `npm run check:examples`
- **THEN** the type checking process SHALL execute

#### Scenario: Verbose output option
- **WHEN** a developer runs `npm run check:examples:verbose`
- **THEN** additional diagnostic output SHALL be displayed

### Requirement: CI Integration
The type checker SHALL run automatically in CI on pull requests and main branch pushes.

#### Scenario: PR validation
- **WHEN** a pull request is opened or updated
- **THEN** the type checker SHALL run as part of CI checks

#### Scenario: CI failure blocks merge
- **WHEN** type checking fails in CI
- **THEN** the CI check SHALL be marked as failed
- **AND** the PR SHALL be blocked from merging (if branch protection is enabled)

#### Scenario: Clear CI feedback
- **WHEN** type checking fails in CI
- **THEN** the error output SHALL clearly indicate which documentation file and code block failed

### Requirement: Code Block Conventions
Documentation authors SHALL follow conventions for marking code blocks.

#### Scenario: Complete example convention
- **WHEN** a code block contains a complete, compilable Fe program or declaration
- **THEN** it SHALL be marked as ` ```fe ` (no annotation)

#### Scenario: Snippet convention
- **WHEN** a code block contains an incomplete snippet for illustration
- **THEN** it SHALL be marked as ` ```fe ignore `

#### Scenario: Convention documentation
- **WHEN** a contributor writes documentation
- **THEN** the conventions SHALL be documented in a contributor guide
