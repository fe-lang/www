# Change: Add Ingots & Package Management Documentation

## Why
Ingots are Fe's fundamental unit of code organization and distribution. Developers need comprehensive documentation to understand how to structure projects, manage dependencies, and share their code. This covers all of Part 3 in the guide.

## What Changes
- Complete documentation for `src/content/docs/ingots/what-are-ingots.md`
- Complete documentation for `src/content/docs/ingots/project-structure.md`
- Complete documentation for `src/content/docs/ingots/package-manager.md`
- Complete documentation for `src/content/docs/ingots/dependencies.md`
- Complete documentation for `src/content/docs/ingots/publishing.md`

### What are Ingots?
- Definition and purpose of ingots
- Comparison to packages in other languages
- Role in code organization and reuse

### Project Structure
- The `fe.toml` manifest file format
- Required `[ingot]` section with name and version
- The `src/` directory structure
- The `src/lib.fe` entrypoint requirement
- File discovery pattern (`src/**/*.fe`)

### The Package Manager
- Overview of Fe's package management
- Commands and workflows (placeholder - depends on tooling)

### Dependencies
- The `[dependencies]` section in fe.toml
- Local path dependencies: `dep = "path/to/dep"` or `dep = { path = "..." }`
- Git remote dependencies: `dep = { source = "https://...", rev = "...", path = "..." }`
- Importing from dependencies

### Publishing Ingots
- Guidelines for publishing (placeholder - depends on registry infrastructure)
- Versioning conventions

## Impact
- Affected specs: `documentation`
- Affected code: All files in `src/content/docs/ingots/`
- No breaking changes - this is additive documentation
