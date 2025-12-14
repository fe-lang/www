## ADDED Requirements

### Requirement: What are Ingots Documentation
The documentation SHALL explain what ingots are and their purpose.

#### Scenario: User learns about ingots
- **WHEN** a user reads the "What are Ingots?" section
- **THEN** they SHALL find a clear definition of what an ingot is
- **AND** they SHALL understand that ingots are Fe's unit of code organization
- **AND** they SHALL learn the benefits of using ingots for code reuse

### Requirement: Project Structure Documentation
The documentation SHALL explain how to structure a Fe project.

#### Scenario: User learns about fe.toml
- **WHEN** a user reads the "Project Structure" section
- **THEN** they SHALL find documentation for the `fe.toml` manifest file
- **AND** they SHALL learn about the required `[ingot]` section
- **AND** examples SHALL show the `name` and `version` fields

#### Scenario: User learns about directory structure
- **WHEN** a user reads about project layout
- **THEN** they SHALL learn that `src/` contains source files
- **AND** they SHALL learn that `src/lib.fe` is the required entrypoint
- **AND** they SHALL understand the file discovery pattern `src/**/*.fe`

### Requirement: Package Manager Documentation
The documentation SHALL explain Fe's package management.

#### Scenario: User learns about package management
- **WHEN** a user reads the "Package Manager" section
- **THEN** they SHALL find an overview of Fe's package management approach
- **AND** they SHALL understand available workflows

### Requirement: Dependencies Documentation
The documentation SHALL explain how to manage dependencies.

#### Scenario: User learns about local dependencies
- **WHEN** a user reads the "Dependencies" section
- **THEN** they SHALL find documentation for the `[dependencies]` section
- **AND** they SHALL learn the syntax for local path dependencies
- **AND** examples SHALL show `dep = "path/to/dep"` format
- **AND** examples SHALL show `dep = { path = "..." }` format

#### Scenario: User learns about remote dependencies
- **WHEN** a user reads about git dependencies
- **THEN** they SHALL learn the syntax for git remote dependencies
- **AND** examples SHALL show `source`, `rev`, and optional `path` fields
- **AND** they SHALL understand how to specify a git revision

#### Scenario: User learns to import from dependencies
- **WHEN** a user reads about using dependencies
- **THEN** they SHALL find examples of importing from dependencies
- **AND** they SHALL understand how dependency names map to import paths

### Requirement: Publishing Documentation
The documentation SHALL explain how to publish ingots.

#### Scenario: User learns about publishing
- **WHEN** a user reads the "Publishing Ingots" section
- **THEN** they SHALL find guidelines for preparing ingots for publication
- **AND** they SHALL learn about versioning conventions
