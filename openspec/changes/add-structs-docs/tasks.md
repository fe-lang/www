# Tasks: Add Structs & Impl Blocks Documentation

## 1. Research
- [x] 1.1 Review Fe compiler for struct syntax and semantics
- [x] 1.2 Study impl block capabilities and restrictions
- [x] 1.3 Understand self parameter behavior
- [x] 1.4 Review storage struct patterns

## 2. Documentation Content

### 2.1 Struct Definition
- [x] 2.1.1 Document `struct` keyword syntax
- [x] 2.1.2 Document field declarations
- [x] 2.1.3 Document visibility modifiers (pub)
- [x] 2.1.4 Document struct instantiation
- [x] 2.1.5 Document destructuring

### 2.2 Impl Blocks
- [x] 2.2.1 Document `impl` block syntax
- [x] 2.2.2 Document `self` parameter
- [x] 2.2.3 Document `mut self` for mutating methods
- [x] 2.2.4 Document method calls
- [x] 2.2.5 Document struct vs contract distinction

### 2.3 Associated Functions
- [x] 2.3.1 Document functions without self (static methods)
- [x] 2.3.2 Document constructor patterns (new, default)
- [x] 2.3.3 Document calling associated functions with ::
- [x] 2.3.4 Document factory functions

### 2.4 Storage Structs
- [x] 2.4.1 Document structs as effect types
- [x] 2.4.2 Document StorageMap fields
- [x] 2.4.3 Document relationship to contracts
- [x] 2.4.4 Document multiple storage structs

### 2.5 Helper Structs
- [x] 2.5.1 Document utility struct patterns
- [x] 2.5.2 Document data transfer objects
- [x] 2.5.3 Document struct composition
- [x] 2.5.4 Document builder pattern

## 3. Integration
- [x] 3.1 Ensure all pages follow Starlight/Astro conventions
- [x] 3.2 Add proper frontmatter to all pages
- [x] 3.3 Verify sidebar entries exist in astro.config.mjs
- [x] 3.4 Build and preview to verify rendering

## 4. Review
- [x] 4.1 Cross-reference with Fe compiler to ensure accuracy
- [x] 4.2 Verify code examples are syntactically correct
- [x] 4.3 Ensure clear distinction from contracts (which cannot have impl blocks)
