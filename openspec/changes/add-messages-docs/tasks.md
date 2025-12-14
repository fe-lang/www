# Tasks: Add Messages & Receive Blocks Documentation

## 1. Research
- [x] 1.1 Review Fe compiler parser for msg syntax
- [x] 1.2 Review HIR for message and recv block definitions
- [x] 1.3 Study selector calculation and validation
- [x] 1.4 Understand the MsgVariant trait and desugaring

## 2. Documentation Content

### 2.1 Defining Messages
- [x] 2.1.1 Document `msg` keyword syntax
- [x] 2.1.2 Document message variants
- [x] 2.1.3 Document return types

### 2.2 Message Fields
- [x] 2.2.1 Document field syntax
- [x] 2.2.2 Document field types

### 2.3 Selectors
- [x] 2.3.1 Document selector attribute syntax
- [x] 2.3.2 Explain selector purpose (ABI compatibility)
- [x] 2.3.3 Document uniqueness requirements
- [x] 2.3.4 Document upcoming `sol_sig` const function

### 2.4 Receive Blocks
- [x] 2.4.1 Document named recv blocks
- [x] 2.4.2 Document bare recv blocks
- [x] 2.4.3 Document exhaustiveness checking

### 2.5 Handler Syntax
- [x] 2.5.1 Document pattern matching in handlers
- [x] 2.5.2 Document field destructuring
- [x] 2.5.3 Document return types
- [x] 2.5.4 Document uses clause in handlers

### 2.6 Multiple Message Types
- [x] 2.6.1 Document multiple recv blocks
- [x] 2.6.2 Document cross-message validation

### 2.7 Message Groups as Interfaces
- [x] 2.7.1 Document MsgVariant trait
- [x] 2.7.2 Explain message desugaring
- [x] 2.7.3 Document custom message types

## 3. Integration
- [x] 3.1 Ensure all pages follow Starlight/Astro conventions
- [x] 3.2 Add proper frontmatter to all pages
- [x] 3.3 Verify sidebar entries exist in astro.config.mjs
- [x] 3.4 Build and preview to verify rendering

## 4. Review
- [x] 4.1 Cross-reference with Fe compiler to ensure accuracy
- [x] 4.2 Verify code examples are syntactically correct
