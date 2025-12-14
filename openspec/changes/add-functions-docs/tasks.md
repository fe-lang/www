# Tasks: Add Functions Documentation

## 1. Research
- [x] 1.1 Review Fe compiler source for function syntax (`ast/item.rs`)
- [x] 1.2 Verify parameter syntax including labels (`ast/param.rs`)
- [x] 1.3 Confirm visibility and modifier behavior

## 2. Documentation Content
- [x] 2.1 Write Function Declaration section with basic syntax
- [x] 2.2 Write Parameters section covering:
  - Regular parameters
  - Labeled parameters (external vs internal names)
  - The `_` label for unlabeled call-site arguments
  - Mutable parameters with `mut`
- [x] 2.3 Write The self Receiver section for methods
- [x] 2.4 Write Return Types section (implicit and explicit returns)
- [x] 2.5 Write Visibility section (`pub` keyword, contracts)
- [x] 2.6 Write Generic Functions section (brief, link to traits)
- [x] 2.7 Write Functions with Effects section (brief, link to effects)
- [x] 2.8 Add Summary table for quick reference

## 3. Integration
- [x] 3.1 Ensure page follows Starlight/Astro conventions
- [x] 3.2 Add proper frontmatter (title, description)
- [x] 3.3 Verify sidebar entry exists in astro.config.mjs
- [x] 3.4 Build and preview to verify rendering

## 4. Review
- [x] 4.1 Cross-reference with Fe compiler to ensure accuracy
- [ ] 4.2 Verify code examples compile (requires Fe toolchain - skipped)
