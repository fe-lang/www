# Tasks: Add Events & Logging Documentation

## 1. Research
- [x] 1.1 Review Fe compiler for event syntax and semantics
- [x] 1.2 Study Log effect implementation
- [x] 1.3 Understand indexed field behavior
- [x] 1.4 Review EVM log structure for ABI compatibility

## 2. Documentation Content

### 2.1 Event Structs
- [x] 2.1.1 Document event struct syntax
- [x] 2.1.2 Document `#[indexed]` attribute
- [x] 2.1.3 Document field limitations (EVM topics)
- [x] 2.1.4 Provide common event patterns

### 2.2 Emitting Events
- [x] 2.2.1 Document `log.emit()` syntax
- [x] 2.2.2 Document event emission in handlers
- [x] 2.2.3 Document best practices for when to emit
- [x] 2.2.4 Provide practical examples

### 2.3 The Log Effect
- [x] 2.3.1 Document Log as an effect type
- [x] 2.3.2 Document declaring the Log effect
- [x] 2.3.3 Explain benefits of explicit logging
- [x] 2.3.4 Show integration with contract patterns

### 2.4 ABI Compatibility
- [x] 2.4.1 Document EVM log structure (topics, data)
- [x] 2.4.2 Document how Fe events map to logs
- [x] 2.4.3 Document event signatures and selectors
- [x] 2.4.4 Document compatibility with tools (ethers, web3)

## 3. Integration
- [x] 3.1 Ensure all pages follow Starlight/Astro conventions
- [x] 3.2 Add proper frontmatter to all pages
- [x] 3.3 Verify sidebar entries exist in astro.config.mjs
- [x] 3.4 Build and preview to verify rendering

## 4. Review
- [x] 4.1 Cross-reference with Fe compiler to ensure accuracy
- [x] 4.2 Verify code examples are syntactically correct
