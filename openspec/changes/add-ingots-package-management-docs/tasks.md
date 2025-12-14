# Tasks: Add Ingots & Package Management Documentation

## 1. Research
- [x] 1.1 Review Fe compiler source for ingot structure (`resolver/src/ingot.rs`)
- [x] 1.2 Review Fe compiler source for config parsing (`common/src/config.rs`)
- [x] 1.3 Verify fe.toml format and required fields
- [x] 1.4 Confirm dependency resolution mechanisms

## 2. Documentation Content

### 2.1 What are Ingots?
- [x] 2.1.1 Define what an ingot is
- [x] 2.1.2 Explain the purpose and benefits
- [x] 2.1.3 Compare to packages in other ecosystems

### 2.2 Project Structure
- [x] 2.2.1 Document fe.toml manifest format
- [x] 2.2.2 Document [ingot] section (name, version)
- [x] 2.2.3 Document src/ directory structure
- [x] 2.2.4 Document src/lib.fe entrypoint
- [x] 2.2.5 Explain file discovery pattern

### 2.3 The Package Manager
- [x] 2.3.1 Overview of package management in Fe
- [x] 2.3.2 Document available commands (fe build, fe check)
- [x] 2.3.3 Common workflows

### 2.4 Dependencies
- [x] 2.4.1 Document [dependencies] section
- [x] 2.4.2 Document local path dependencies
- [x] 2.4.3 Document git remote dependencies
- [x] 2.4.4 Show how to import from dependencies

### 2.5 Publishing Ingots
- [x] 2.5.1 Publishing guidelines
- [x] 2.5.2 Versioning conventions
- [x] 2.5.3 Best practices

## 3. Integration
- [x] 3.1 Ensure all pages follow Starlight/Astro conventions
- [x] 3.2 Add proper frontmatter to all pages
- [x] 3.3 Verify sidebar entries exist in astro.config.mjs
- [x] 3.4 Build and preview to verify rendering

## 4. Review
- [x] 4.1 Cross-reference with Fe compiler to ensure accuracy
- [ ] 4.2 Verify code examples compile (requires Fe toolchain - skipped)
