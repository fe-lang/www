# Tasks: Add Contracts Documentation

## 1. Research
- [x] 1.1 Review Fe compiler for contract syntax and semantics
- [x] 1.2 Study contract field declarations and storage binding
- [x] 1.3 Understand init block constraints and capabilities
- [x] 1.4 Review contract composition patterns in Fe

## 2. Documentation Content

### 2.1 Contract Declaration
- [x] 2.1.1 Document `contract` keyword syntax
- [x] 2.1.2 Document contract fields
- [x] 2.1.3 Document contract visibility (pub)
- [x] 2.1.4 Document what contracts cannot have (no impl blocks)

### 2.2 Contract-Level Effects
- [x] 2.2.1 Document effect dependencies in contracts
- [x] 2.2.2 Document how contracts provide effects to handlers via `with`
- [x] 2.2.3 Document multiple effect fields

### 2.3 Storage Fields
- [x] 2.3.1 Document storage field syntax
- [x] 2.3.2 Document storage types (structs, maps)
- [x] 2.3.3 Document storage initialization
- [x] 2.3.4 Document StorageMap operations

### 2.4 The init Block
- [x] 2.4.1 Document init block syntax
- [x] 2.4.2 Document init parameters
- [x] 2.4.3 Document storage initialization in init
- [x] 2.4.4 Document direct field access in init

### 2.5 Receive Blocks in Contracts
- [x] 2.5.1 Document recv block placement in contracts
- [x] 2.5.2 Document accessing storage from handlers
- [x] 2.5.3 Show complete contract examples

### 2.6 Contract Composition
- [x] 2.6.1 Document helper functions with effects
- [x] 2.6.2 Document organizing large contracts
- [x] 2.6.3 Document access control pattern
- [x] 2.6.4 Document pausable pattern

## 3. Integration
- [x] 3.1 Ensure all pages follow Starlight/Astro conventions
- [x] 3.2 Add proper frontmatter to all pages
- [x] 3.3 Verify sidebar entries exist in astro.config.mjs
- [x] 3.4 Build and preview to verify rendering

## 4. Review
- [x] 4.1 Cross-reference with Fe compiler to ensure accuracy
- [x] 4.2 Verify code examples are syntactically correct
