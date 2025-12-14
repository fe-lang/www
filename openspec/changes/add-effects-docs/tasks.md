# Tasks: Add Effects & the uses Clause Documentation

## 1. Research
- [x] 1.1 Review Fe compiler HIR for effect definitions
- [x] 1.2 Review parser AST for uses clause syntax
- [x] 1.3 Study effect propagation rules in type checker
- [x] 1.4 Understand effect environment and scoping

## 2. Documentation Content

### 2.1 What Are Effects?
- [x] 2.1.1 Define effects as capabilities
- [x] 2.1.2 Explain purpose of effect tracking
- [x] 2.1.3 Overview of the system

### 2.2 Declaring Effects
- [x] 2.2.1 Document `uses` keyword syntax
- [x] 2.2.2 Document single effect syntax
- [x] 2.2.3 Document named effects
- [x] 2.2.4 Document multiple effects
- [x] 2.2.5 Document effects on contracts

### 2.3 Mutability in Effects
- [x] 2.3.1 Document immutable effects
- [x] 2.3.2 Document mutable effects with `mut`
- [x] 2.3.3 Explain mutability matching rules

### 2.4 Effect Propagation
- [x] 2.4.1 Document how effects flow through calls
- [x] 2.4.2 Document the `with` expression
- [x] 2.4.3 Explain effect scoping

### 2.5 Built-in Effects
- [x] 2.5.1 Explain effects are user-defined
- [x] 2.5.2 Document common effect patterns

### 2.6 Storage as Effects
- [x] 2.6.1 Document contract fields as effects
- [x] 2.6.2 Explain field-based effect derivation

### 2.7 Why Effects Matter
- [x] 2.7.1 Explain security benefits
- [x] 2.7.2 Explain compile-time guarantees
- [x] 2.7.3 Show practical examples

## 3. Integration
- [x] 3.1 Ensure all pages follow Starlight/Astro conventions
- [x] 3.2 Add proper frontmatter to all pages
- [x] 3.3 Verify sidebar entries exist in astro.config.mjs
- [x] 3.4 Build and preview to verify rendering

## 4. Review
- [x] 4.1 Cross-reference with Fe compiler to ensure accuracy
- [ ] 4.2 Verify code examples compile (requires Fe toolchain - skipped)
